--liquibase formatted sql

--changeset 20moonlight01:29
--comment: Добавление внешнего ключа поставщиков к сущностям
--tag: v2
ALTER TABLE suppliers 
    ADD CONSTRAINT fk_suppliers_entity 
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE;

--rollback ALTER TABLE suppliers DROP CONSTRAINT IF EXISTS fk_suppliers_entity;