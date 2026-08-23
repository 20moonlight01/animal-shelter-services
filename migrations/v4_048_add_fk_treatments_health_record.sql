--liquibase formatted sql

--changeset 20moonlight01:48
--comment: Добавление внешнего ключа лечения к медзаписи
--tag: v4
ALTER TABLE treatments 
    ADD CONSTRAINT fk_treatments_health_record 
    FOREIGN KEY (animal_health_record_id) REFERENCES animal_health_records(id) ON DELETE CASCADE;

--rollback ALTER TABLE treatments DROP CONSTRAINT IF EXISTS fk_treatments_health_record;