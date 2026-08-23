# Проверка отказоустойчивости PostgreSQL

## Отказ primary PostgreSQL

![](images/1.png)
![](images/2.png)

Метрики демонстрируют:

- `patroni-node1` - лидер кластера перед началом эксперимента;
- оба узла доступны;
- статус репликации узла-реплики - `streaming`.

Отказ лидера эмулировался с помощью инструмента инъекции отказов `Pumba`: был остановлен контейнер с лидером.

```docker
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock gaiaadm/pumba kill --signal SIGKILL patroni-node1
```

### Как повела себя система

После остановки контейнера с лидером остановленный узел пропал из списка узлов. Запросы клиента, которые шли к базе данных через `HAProxy`, стали ловить ошибки. Через некоторое время статус узла сменился на лидера, и клиент снова стал получать ответы на запросы.

![](images/3.png)
![](images/4.png)
![](images/5.png)

Метрики демонстрируют:

- данные от `patroni-node1` не поступают;
- `patroni-node2` становится лидером;
- статус репликации `patroni-node2` меняется, т.к. это больше не реплика;
- в промежуток времени, когда меняется лидер, `HAProxy` демонстрирует отсутствие доступных серверов `postgres`, затем соединение восстанавливается.

**Логи `patroni-node2` (реплика -> лидер):**

```
2026-06-13 15:30:53,191 INFO: no action. I am (patroni-node2), a secondary, and following a leader (patroni-node1)

2026-06-13 15:31:02.257 UTC [115] FATAL:  could not receive data from WAL stream: server closed the connection unexpectedly

		This probably means the server terminated abnormally

		before or while processing the request.

2026-06-13 15:31:02.257 UTC [110] LOG:  invalid record length at 0/4000060: wanted 24, got 0

2026-06-13 15:31:02.261 UTC [308] FATAL:  could not connect to the primary server: connection to server at "patroni-node1" (172.18.0.5), port 5432 failed: Connection refused

		Is the server running on that host and accepting TCP/IP connections?

2026-06-13 15:31:02.261 UTC [110] LOG:  waiting for WAL to become available at 0/4000078

2026-06-13 15:31:03,734 INFO: no action. I am (patroni-node2), a secondary, and following a leader (patroni-node1)

2026-06-13 15:31:11.330 UTC [316] FATAL:  could not connect to the primary server: could not translate host name "patroni-node1" to address: Name does not resolve

2026-06-13 15:31:11.331 UTC [110] LOG:  waiting for WAL to become available at 0/4000078

2026-06-13 15:31:13,731 INFO: no action. I am (patroni-node2), a secondary, and following a leader (patroni-node1)
...
2026-06-13 15:31:42,327 WARNING: failed to resolve host patroni-node1: [Errno -2] Name does not resolve

2026-06-13 15:31:42,327 WARNING: Request failed to patroni-node1: GET http://patroni-node1:8008/patroni (HTTPConnectionPool(host='patroni-node1', port=8008): Max retries exceeded with url: /patroni (Caused by NewConnectionError("HTTPConnection(host='patroni-node1', port=8008): Failed to establish a new connection: getaddrinfo returns an empty list")))

2026-06-13 15:31:42,362 INFO: promoted self to leader by acquiring session lock

server promoting

2026-06-13 15:31:42.365 UTC [110] LOG:  received promote request

2026-06-13 15:31:46.341 UTC [347] FATAL:  could not connect to the primary server: could not translate host name "patroni-node1" to address: Name does not resolve

2026-06-13 15:31:46.342 UTC [110] LOG:  waiting for WAL to become available at 0/4000078

2026-06-13 15:31:46.342 UTC [110] LOG:  redo done at 0/4000028 system usage: CPU: user: 0.15 s, system: 0.01 s, elapsed: 306.52 s

2026-06-13 15:31:46.342 UTC [110] LOG:  last completed transaction was at log time 2026-06-13 15:26:12.071829+00

2026-06-13 15:31:46.384 UTC [110] LOG:  selected new timeline ID: 2

2026-06-13 15:31:46.436 UTC [110] LOG:  archive recovery complete

2026-06-13 15:31:46.441 UTC [108] LOG:  checkpoint starting: force

2026-06-13 15:31:46.445 UTC [106] LOG:  database system is ready to accept connections

2026-06-13 15:31:47,454 INFO: no action. I am (patroni-node2), the leader with the lock

2026-06-13 15:31:47.617 UTC [108] LOG:  checkpoint complete: wrote 1275 buffers (7.8%); 0 WAL file(s) added, 0 removed, 0 recycled; write=1.017 s, sync=0.138 s, total=1.177 s; sync files=177, longest=0.013 s, average=0.001 s; distance=32768 kB, estimate=32768 kB

2026-06-13 15:31:47.618 UTC [108] LOG:  checkpoint starting: immediate force wait

2026-06-13 15:31:47.651 UTC [108] LOG:  checkpoint complete: wrote 0 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.001 s, sync=0.001 s, total=0.034 s; sync files=0, longest=0.000 s, average=0.000 s; distance=0 kB, estimate=29491 kB

2026-06-13 15:31:47,683 INFO: no action. I am (patroni-node2), the leader with the lock
```

Узел-реплика отмечает отсутствие ответа от узла-лидера, какое-то время пытается подключиться, затем повышает себя до лидера и открывает подключение к базе данных.

**Логи `HAProxy`:**

```
Server postgres_servers/patroni-node1 is DOWN, reason: Layer4 timeout, check duration: 3002ms. 0 active and 0 backup servers left. 1 sessions active, 0 requeued, 0 remaining in queue.

backend postgres_servers has no server available!

172.18.0.8:41900 [13/Jun/2026:15:31:11.835] postgres_frontend postgres_servers/patroni-node1 1/-1/7044 0 DC 2/1/0/0/0 0/0

[WARNING]  (8) : Server postgres_servers/patroni-node1 is DOWN, reason: Layer4 timeout, check duration: 3002ms. 0 active and 0 backup servers left. 1 sessions active, 0 requeued, 0 remaining in queue.

[ALERT]    (8) : backend 'postgres_servers' has no server available!

172.18.0.8:38558 [13/Jun/2026:15:31:26.837] postgres_frontend postgres_servers/<NOSRV> -1/-1/0 0 SC 3/2/1/0/0 0/0

172.18.0.8:38560 [13/Jun/2026:15:31:26.838] postgres_frontend postgres_servers/<NOSRV> -1/-1/0 0 SC 3/2/0/0/0 0/0

172.18.0.10:51184 [13/Jun/2026:15:31:18.126] stats stats/<PROMEX> 0/0/15000 64539 LR 1/1/0/0/0 0/0

172.18.0.8:44306 [13/Jun/2026:15:31:41.830] postgres_frontend postgres_servers/<NOSRV> -1/-1/0 0 SC 3/2/1/0/0 0/0

172.18.0.8:44310 [13/Jun/2026:15:31:41.830] postgres_frontend postgres_servers/<NOSRV> -1/-1/0 0 SC 2/1/0/0/0 0/0

[WARNING]  (8) : Server postgres_servers/patroni-node2 is UP, reason: Layer7 check passed, code: 200, check duration: 11ms. 1 active and 0 backup servers online. 0 sessions requeued, 0 total in queue.

Server postgres_servers/patroni-node2 is UP, reason: Layer7 check passed, code: 200, check duration: 11ms. 1 active and 0 backup servers online. 0 sessions requeued, 0 total in queue.
```

`HAProxy` отмечает отсутствие доступных бэкенд-серверов, по прошествии некоторого времени становится доступным сервер другого узла.

**Логи `postgres-exporter` (клиент):**

```
time=2026-06-13T15:31:12.835Z level=ERROR source=postgres_exporter.go:713 msg="error scraping dsn" err="Error opening connection to database (postgresql://postgres_exporter:PASSWORD_REMOVED@haproxy:5432/animal_shelter?sslmode=disable): driver: bad connection" dsn="postgresql://postgres_exporter:PASSWORD_REMOVED@haproxy:5432/animal_shelter?sslmode=disable"

time=2026-06-13T15:31:18.881Z level=ERROR source=collector.go:191 msg="Error opening connection to database" err="error querying postgresql version: EOF"

time=2026-06-13T15:31:26.835Z level=INFO source=server.go:96 msg="Established new database connection" fingerprint=haproxy:5432

time=2026-06-13T15:31:26.839Z level=ERROR source=collector.go:191 msg="Error opening connection to database" err="error querying postgresql version: EOF"

time=2026-06-13T15:31:27.840Z level=ERROR source=postgres_exporter.go:713 msg="error scraping dsn" err="Error opening connection to database (postgresql://postgres_exporter:PASSWORD_REMOVED@haproxy:5432/animal_shelter?sslmode=disable): EOF" dsn="postgresql://postgres_exporter:PASSWORD_REMOVED@haproxy:5432/animal_shelter?sslmode=disable"

time=2026-06-13T15:31:41.826Z level=INFO source=server.go:96 msg="Established new database connection" fingerprint=haproxy:5432

time=2026-06-13T15:31:41.831Z level=ERROR source=collector.go:191 msg="Error opening connection to database" err="error querying postgresql version: EOF"

time=2026-06-13T15:31:42.832Z level=ERROR source=postgres_exporter.go:713 msg="error scraping dsn" err="Error opening connection to database (postgresql://postgres_exporter:PASSWORD_REMOVED@haproxy:5432/animal_shelter?sslmode=disable): EOF" dsn="postgresql://postgres_exporter:PASSWORD_REMOVED@haproxy:5432/animal_shelter?sslmode=disable"

time=2026-06-13T15:31:56.826Z level=INFO source=server.go:96 msg="Established new database connection" fingerprint=haproxy:5432
```

Клиент не может установить соединение с базой данных и ловит ошибки; когда лидером становится другой узел, он устанавливает новое соединение с базой данных и перестает писать об ошибках.

### Произошло ли автоматическое переключение

Через некоторое время (около **40 секунд**) после остановки лидера второй узел `Patroni` сменил свой статус на лидера.

### Были ли ошибки

В период фиксации отсутствия в системе лидера и его смены клиент не мог установить соединение с базой данных через `HAProxy` и получал ошибку.

### Восстановилась ли система автоматически

```docker
docker start patroni-node1
```

После смены лидера система вернулась к работе в штатном режиме. Когда контейнер со вторым узлом был запущен заново, второй узел получил статус реплики и начал синхронизироваться с узлом-лидером.

![](images/6.png)
![](images/7.png)

Метрики демонстрируют:

- данные от `patroni-node1` снова поступают;
- `patroni-node1` становится репликой;
- статус репликации `patroni-node1` - `streaming`.

**Логи `patroni-node1`:**

```
2026-06-13 15:43:36.757 UTC [66] FATAL:  the database system is starting up

2026-06-13 15:43:36.770 UTC [54] LOG:  redo starts at 0/2000028

2026-06-13 15:43:36.933 UTC [54] LOG:  completed backup recovery with redo LSN 0/2000028 and end LSN 0/3138AF0

2026-06-13 15:43:36.934 UTC [54] LOG:  consistent recovery state reached at 0/402AC00

2026-06-13 15:43:36.935 UTC [54] LOG:  invalid record length at 0/402AC00: wanted 24, got 0

2026-06-13 15:43:36.935 UTC [50] LOG:  database system is ready to accept read-only connections

2026-06-13 15:43:36.962 UTC [67] LOG:  started streaming WAL from primary at 0/4000000 on timeline 2

localhost:5432 - accepting connections

2026-06-13 15:43:37,794 INFO: Lock owner: patroni-node2; I am patroni-node1

2026-06-13 15:43:37,795 INFO: establishing a new patroni heartbeat connection to postgres

2026-06-13 15:43:37,999 INFO: no action. I am (patroni-node1), a secondary, and following a leader (patroni-node2)

2026-06-13 15:43:39,383 INFO: establishing a new patroni restapi connection to postgres

2026-06-13 15:43:47,709 INFO: no action. I am (patroni-node1), a secondary, and following a leader (patroni-node2)
```

Поднятый узел восстановился и открыл возможность посылать ему запросы на чтение (как реплика).

## Потеря связи с etcd

Состояние системы перед началом эксперимента совпадает с состоянием после завершения предыдущего эксперимента.

Потеря связи с `etcd` на 1 минуту эмулировалась с помощью инструмента инъекции отказов `Pumba`:

```docker
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock gaiaadm/pumba netem --duration 1m loss --percent 100 etcd
```

### Как повела себя система

При потере связи с `etcd` узлы потеряли доступ к распределенному координатору, больше не могли обновлять/проверять статус лидера кластера и стали писать об ошибках. Внешние клиенты потеряли возможность соединения с базой данных через `HAProxy`.

![](images/8.png)
![](images/9.png)
![](images/10.png)

Метрики демонстрируют (в период потери связи с `etcd`):

- отсутствие лидера в системе;
- оба узла теряют доступ к `etcd`;
- `HAProxy` демонстрирует отсутствие доступных серверов `postgres`.

**Логи `patroni-node1` (реплика):**

```
2026-06-13 16:04:10,699 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=0, status=None)) after connection broken by 'ConnectTimeoutError(<HTTPConnection(host='etcd', port=2379) at 0x75e5c956a630>, 'Connection to etcd timed out. (connect timeout=2.5)')': /v2/keys/service/new-animal-shelter/?recursive=true&quorum=false

2026-06-13 16:04:13,201 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=0, status=None)) after connection broken by 'ConnectTimeoutError(<HTTPConnection(host='etcd', port=2379) at 0x75e5c9569a00>, 'Connection to etcd timed out. (connect timeout=2.5)')': /v2/keys/service/new-animal-shelter/?recursive=true&quorum=false

2026-06-13 16:04:15,706 ERROR: Request to server http://etcd:2379 failed: MaxRetryError("HTTPConnectionPool(host='etcd', port=2379): Max retries exceeded with url: /v2/keys/service/new-animal-shelter/?recursive=true&quorum=false (Caused by ConnectTimeoutError(<HTTPConnection(host='etcd', port=2379) at 0x75e5c956a9f0>, 'Connection to etcd timed out. (connect timeout=2.5)'))")

2026-06-13 16:04:15,706 INFO: Reconnection allowed, looking for another server.

2026-06-13 16:04:18,211 WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=0, status=None)) after connection broken by 'ConnectTimeoutError(<HTTPConnection(host='etcd', port=2379) at 0x75e5c956bda0>, 'Connection to etcd timed out. (connect timeout=2.5)')': /v2/machines

2026-06-13 16:04:20,716 WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=0, status=None)) after connection broken by 'ConnectTimeoutError(<HTTPConnection(host='etcd', port=2379) at 0x75e5c956b830>, 'Connection to etcd timed out. (connect timeout=2.5)')': /v2/machines

2026-06-13 16:04:23,222 ERROR: Failed to get list of machines from http://etcd:2379/v2: MaxRetryError("HTTPConnectionPool(host='etcd', port=2379): Max retries exceeded with url: /v2/machines (Caused by ConnectTimeoutError(<HTTPConnection(host='etcd', port=2379) at 0x75e5c956b530>, 'Connection to etcd timed out. (connect timeout=2.5)'))")

2026-06-13 16:04:23,224 ERROR: get_cluster
...
etcd.EtcdConnectionFailed: No more machines in the cluster

2026-06-13 16:04:23,236 ERROR: Error communicating with DCS

2026-06-13 16:04:23,239 INFO: DCS is not accessible

2026-06-13 16:04:23,240 WARNING: Loop time exceeded, rescheduling immediately.

2026-06-13 16:04:25.289 UTC [67] LOG:  replication terminated by primary server

2026-06-13 16:04:25.289 UTC [67] DETAIL:  End of WAL reached on timeline 2 at 0/402AC78.

2026-06-13 16:04:25.289 UTC [67] FATAL:  could not send end-of-streaming message to primary: server closed the connection unexpectedly

		This probably means the server terminated abnormally

		before or while processing the request.

	no COPY in progress

2026-06-13 16:04:25.289 UTC [54] LOG:  invalid record length at 0/402AC78: wanted 24, got 0

2026-06-13 16:04:25.298 UTC [951] FATAL:  could not connect to the primary server: connection to server at "patroni-node2" (172.18.0.4), port 5432 failed: Connection refused

		Is the server running on that host and accepting TCP/IP connections?

2026-06-13 16:04:25.299 UTC [54] LOG:  waiting for WAL to become available at 0/402AC90
```

Узел-реплика (в данном случае) теряет соединение с `etcd` и, как следствие, не может общаться с узлом-лидером.

**Логи `HAProxy`:**

```
Server postgres_servers/patroni-node2 is DOWN, reason: Layer7 wrong status, code: 503, info: "Service Unavailable", check duration: 20ms. 0 active and 0 backup servers left. 0 sessions active, 0 requeued, 0 remaining in queue.

backend postgres_servers has no server available!

[WARNING]  (8) : Server postgres_servers/patroni-node2 is DOWN, reason: Layer7 wrong status, code: 503, info: "Service Unavailable", check duration: 20ms. 0 active and 0 backup servers left. 0 sessions active, 0 requeued, 0 remaining in queue.

[ALERT]    (8) : backend 'postgres_servers' has no server available!

172.18.0.8:57884 [13/Jun/2026:16:04:41.469] postgres_frontend postgres_servers/<NOSRV> -1/-1/0 0 SC 4/3/0/0/0 0/0

172.18.0.8:57882 [13/Jun/2026:16:04:41.468] postgres_frontend postgres_servers/<NOSRV> -1/-1/0 0 SC 2/1/0/0/0 0/0

172.18.0.10:51184 [13/Jun/2026:16:04:32.766] stats stats/<PROMEX> 0/0/15000 64620 LR 1/1/0/0/0 0/0

172.18.0.8:48214 [13/Jun/2026:16:04:56.472] postgres_frontend postgres_servers/<NOSRV> -1/-1/0 0 SC 3/2/1/0/0 0/0

172.18.0.8:48228 [13/Jun/2026:16:04:56.471] postgres_frontend postgres_servers/<NOSRV> -1/-1/0 0 SC 2/1/0/0/0 0/0

172.18.0.10:51184 [13/Jun/2026:16:04:47.761] stats stats/<PROMEX> 0/0/14996 64620 LR 1/1/0/0/0 0/0

[WARNING]  (8) : Server postgres_servers/patroni-node1 is UP, reason: Layer7 check passed, code: 200, check duration: 1ms. 1 active and 0 backup servers online. 0 sessions requeued, 0 total in queue.

Server postgres_servers/patroni-node1 is UP, reason: Layer7 check passed, code: 200, check duration: 1ms. 1 active and 0 backup servers online. 0 sessions requeued, 0 total in queue.
```

`HAProxy` отмечает отсутствие доступных бэкенд-серверов; когда соединение восстанавливается, становится доступным сервер другого узла.

**Логи `postgres-exporter` (клиент):**

```
time=2026-06-13T16:04:27.475Z level=ERROR source=postgres_exporter.go:713 msg="error scraping dsn" err="Error opening connection to database (postgresql://postgres_exporter:PASSWORD_REMOVED@haproxy:5432/animal_shelter?sslmode=disable): driver: bad connection" dsn="postgresql://postgres_exporter:PASSWORD_REMOVED@haproxy:5432/animal_shelter?sslmode=disable"

time=2026-06-13T16:04:41.467Z level=INFO source=server.go:96 msg="Established new database connection" fingerprint=haproxy:5432

time=2026-06-13T16:04:41.469Z level=ERROR source=collector.go:191 msg="Error opening connection to database" err="error querying postgresql version: EOF"

time=2026-06-13T16:04:42.470Z level=ERROR source=postgres_exporter.go:713 msg="error scraping dsn" err="Error opening connection to database (postgresql://postgres_exporter:PASSWORD_REMOVED@haproxy:5432/animal_shelter?sslmode=disable): EOF" dsn="postgresql://postgres_exporter:PASSWORD_REMOVED@haproxy:5432/animal_shelter?sslmode=disable"

time=2026-06-13T16:04:56.468Z level=INFO source=server.go:96 msg="Established new database connection" fingerprint=haproxy:5432

time=2026-06-13T16:04:56.474Z level=ERROR source=collector.go:191 msg="Error opening connection to database" err="error querying postgresql version: EOF"

time=2026-06-13T16:04:57.474Z level=ERROR source=postgres_exporter.go:713 msg="error scraping dsn" err="Error opening connection to database (postgresql://postgres_exporter:PASSWORD_REMOVED@haproxy:5432/animal_shelter?sslmode=disable): EOF" dsn="postgresql://postgres_exporter:PASSWORD_REMOVED@haproxy:5432/animal_shelter?sslmode=disable"

time=2026-06-13T16:05:11.465Z level=INFO source=server.go:96 msg="Established new database connection" fingerprint=haproxy:5432
```

Клиент не может установить соединение с базой данных и ловит ошибки; когда сеть восстанавливается, он устанавливает новое соединение с базой данных и перестает писать об ошибках.

### Произошло ли автоматическое переключение

Во время отсутствия связи с `etcd` автоматическое переключение на исправный узел было заблокировано, так как ни один из узлов кластера не мог получить подтверждение своей легитимности от `etcd`. Кластер находился в защитном безлидерном состоянии, защищая консистентность данных.

### Были ли ошибки

Появились ошибки - и внутри узлов, и на стороне клиента. `HAProxy` отдавал ошибку `503 Service Unavailable`, потому что `Patroni` перевел узлы в безопасный режим.

### Восстановилась ли система автоматически

После восстановления связи узлы снова смогли взаимодействовать друг с другом и начали предоставлять подключение.

![](images/8.png)
![](images/9.png)
![](images/10.png)

Метрики демонстрируют (после восстановления связи с `etcd`):

- узлы меняются ролями;
- оба узла восстанавливают доступ к `etcd`;
- соединение через `HAProxy` восстанавливается.

**Логи `patroni-node1`:**

```
2026-06-13 16:05:02,087 INFO: Got response from patroni-node2 http://patroni-node2:8008/patroni: {"state": "running", "postmaster_start_time": "2026-06-13 16:04:27.056418+00:00", "role": "replica", "server_version": 150017, "xlog": {"received_location": 67284088, "replayed_location": 67284088, "replayed_timestamp": null, "paused": false}, "timeline": 2, "replication": [{"usename": "replicator", "application_name": "patroni-node1", "client_addr": "172.18.0.5", "state": "streaming", "sync_state": "async", "sync_priority": 0}], "cluster_unlocked": true, "dcs_last_seen": 1781366702, "database_system_identifier": "7650901337525911582", "patroni": {"version": "4.1.2", "scope": "new-animal-shelter", "name": "patroni-node2"}}

2026-06-13 16:05:02,101 INFO: promoted self to leader by acquiring session lock

server promoting

2026-06-13 16:05:02.104 UTC [54] LOG:  received promote request

2026-06-13 16:05:02.105 UTC [953] FATAL:  terminating walreceiver process due to administrator command

2026-06-13 16:05:02.105 UTC [54] LOG:  redo done at 0/402AC00 system usage: CPU: user: 0.13 s, system: 0.03 s, elapsed: 1285.33 s

2026-06-13 16:05:02.105 UTC [54] LOG:  last completed transaction was at log time 2026-06-13 15:26:12.071829+00

2026-06-13 16:05:02.143 UTC [54] LOG:  selected new timeline ID: 3

2026-06-13 16:05:02.248 UTC [54] LOG:  archive recovery complete

2026-06-13 16:05:02.264 UTC [52] LOG:  checkpoint starting: force

2026-06-13 16:05:02.283 UTC [50] LOG:  database system is ready to accept connections

2026-06-13 16:05:02.419 UTC [52] LOG:  checkpoint complete: wrote 2 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.023 s, sync=0.005 s, total=0.156 s; sync files=2, longest=0.003 s, average=0.003 s; distance=0 kB, estimate=26680 kB

2026-06-13 16:05:03,167 INFO: no action. I am (patroni-node1), the leader with the lock
```

Когда сеть восстановилась, узлы снова смогли общаться друг с другом, произошли повторные выборы и узлы поменялись ролями. Соединение с базой данных снова стало доступно.

Если во время, когда связи с `etcd` нет, отключить узел, который был лидером, второй узел становится лидером после восстановления связи. Подключение к базе данных восстанавливается.

**Логи узла, который становится лидером:**

```
2026-06-13 16:34:37.569 UTC [1945] LOG:  waiting for WAL to become available at 0/404C578

2026-06-13 16:34:39,105 WARNING: Request failed to patroni-node1: GET http://patroni-node1:8008/patroni (HTTPConnectionPool(host='patroni-node1', port=8008): Max retries exceeded with url: /patroni (Caused by ConnectTimeoutError(<HTTPConnection(host='patroni-node1', port=8008) at 0x7f412b4fd8b0>, 'Connection to patroni-node1 timed out. (connect timeout=2)')))

2026-06-13 16:34:39,133 INFO: promoted self to leader by acquiring session lock

server promoting

2026-06-13 16:34:39.138 UTC [1945] LOG:  received promote request

2026-06-13 16:34:40,336 INFO: Lock owner: patroni-node2; I am patroni-node2

2026-06-13 16:34:40,376 INFO: updated leader lock during promote

2026-06-13 16:34:42.562 UTC [3402] FATAL:  could not connect to the primary server: could not translate host name "patroni-node1" to address: Name does not resolve

2026-06-13 16:34:42.562 UTC [1945] LOG:  waiting for WAL to become available at 0/404C578

2026-06-13 16:34:42.562 UTC [1945] LOG:  redo done at 0/404C4E8 system usage: CPU: user: 0.02 s, system: 0.05 s, elapsed: 1780.17 s

2026-06-13 16:34:42.580 UTC [1945] LOG:  selected new timeline ID: 4

2026-06-13 16:34:42.652 UTC [1945] LOG:  archive recovery complete

2026-06-13 16:34:42.660 UTC [1943] LOG:  checkpoint starting: force

2026-06-13 16:34:42.663 UTC [1941] LOG:  database system is ready to accept connections

2026-06-13 16:34:42.676 UTC [1943] LOG:  checkpoint complete: wrote 2 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.005 s, sync=0.002 s, total=0.017 s; sync files=2, longest=0.002 s, average=0.001 s; distance=0 kB, estimate=108 kB

2026-06-13 16:34:43,210 INFO: no action. I am (patroni-node2), the leader with the lock
```