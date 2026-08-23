--liquibase formatted sql

--changeset 20moonlight01:14
--comment: Добавление внешнего ключа помещений к типу
--tag: v1
ALTER TABLE facilities 
    ADD CONSTRAINT fk_facilities_type 
    FOREIGN KEY (facility_type_id) REFERENCES facility_types(id) ON DELETE CASCADE;

--rollback ALTER TABLE facilities DROP CONSTRAINT IF EXISTS fk_facilities_type;