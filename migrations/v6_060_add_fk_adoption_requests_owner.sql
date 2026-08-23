--liquibase formatted sql

--changeset 20moonlight01:60
--comment: Добавление внешнего ключа заявки к владельцу
--tag: v6
ALTER TABLE adoption_requests 
    ADD CONSTRAINT fk_adoption_requests_owner 
    FOREIGN KEY (owner_id) REFERENCES owners(id) ON DELETE CASCADE;

--rollback ALTER TABLE adoption_requests DROP CONSTRAINT IF EXISTS fk_adoption_requests_owner;