--liquibase formatted sql

--changeset 20moonlight01:22
--comment: Добавление внешнего ключа благотворителей к сущностям
--tag: v2
ALTER TABLE donors 
    ADD CONSTRAINT fk_donors_entity 
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE;

--rollback ALTER TABLE donors DROP CONSTRAINT IF EXISTS fk_donors_entity;