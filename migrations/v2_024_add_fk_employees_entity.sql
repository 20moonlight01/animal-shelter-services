--liquibase formatted sql

--changeset 20moonlight01:24
--comment: Добавление внешнего ключа сотрудников к сущностям
--tag: v2
ALTER TABLE employees 
    ADD CONSTRAINT fk_employees_entity 
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE;

--rollback ALTER TABLE employees DROP CONSTRAINT IF EXISTS fk_employees_entity;