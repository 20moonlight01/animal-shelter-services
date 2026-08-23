--liquibase formatted sql

--changeset 20moonlight01:62
--comment: Добавление внешнего ключа заявки к состоянию заявки
--tag: v6
ALTER TABLE adoption_requests 
    ADD CONSTRAINT fk_adoption_requests_state 
    FOREIGN KEY (request_state_id) REFERENCES request_states(id) ON DELETE CASCADE;

--rollback ALTER TABLE adoption_requests DROP CONSTRAINT IF EXISTS fk_adoption_requests_state;