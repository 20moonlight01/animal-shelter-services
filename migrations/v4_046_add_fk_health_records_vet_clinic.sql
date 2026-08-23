--liquibase formatted sql

--changeset 20moonlight01:46
--comment: Добавление внешнего ключа медзаписи к ветклинике (поставщику услуг)
--tag: v4
ALTER TABLE animal_health_records 
    ADD CONSTRAINT fk_animal_health_records_vet_clinic 
    FOREIGN KEY (vet_clinic_id) REFERENCES suppliers(id) ON DELETE CASCADE;

--rollback ALTER TABLE animal_health_records DROP CONSTRAINT IF EXISTS fk_animal_health_records_vet_clinic;