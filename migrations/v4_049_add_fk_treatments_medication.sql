--liquibase formatted sql

--changeset 20moonlight01:49
--comment: Добавление внешнего ключа лечения к лекарству
--tag: v4
ALTER TABLE treatments 
    ADD CONSTRAINT fk_treatments_medication 
    FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE CASCADE;

--rollback ALTER TABLE treatments DROP CONSTRAINT IF EXISTS fk_treatments_medication;