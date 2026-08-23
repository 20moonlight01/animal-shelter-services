--liquibase formatted sql

--changeset 20moonlight01:19
--comment: Добавление внешнего ключа владельцев к семейному положению
--tag: v2
ALTER TABLE owners 
    ADD CONSTRAINT fk_owners_marital_status 
    FOREIGN KEY (marital_status_id) REFERENCES marital_statuses(id) ON DELETE CASCADE;

--rollback ALTER TABLE owners DROP CONSTRAINT IF EXISTS fk_owners_marital_status;