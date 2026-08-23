--liquibase formatted sql

--changeset 20moonlight01:18
--comment: Добавление внешнего ключа владельцев к сущностям
--tag: v2
ALTER TABLE owners 
    ADD CONSTRAINT fk_owners_entity 
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE;

--rollback ALTER TABLE owners DROP CONSTRAINT IF EXISTS fk_owners_entity;