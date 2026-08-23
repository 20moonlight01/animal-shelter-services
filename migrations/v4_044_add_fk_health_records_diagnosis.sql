--liquibase formatted sql

--changeset 20moonlight01:44
--comment: Добавление внешнего ключа медзаписи к диагнозу
--tag: v4
ALTER TABLE animal_health_records 
    ADD CONSTRAINT fk_animal_health_records_diagnosis 
    FOREIGN KEY (diagnosis_id) REFERENCES diagnoses(id) ON DELETE CASCADE;

--rollback ALTER TABLE animal_health_records DROP CONSTRAINT IF EXISTS fk_animal_health_records_diagnosis;