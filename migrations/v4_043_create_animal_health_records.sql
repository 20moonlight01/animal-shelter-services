--liquibase formatted sql

--changeset 20moonlight01:43
--comment: Создание таблицы медицинских записей
--tag: v4
CREATE TABLE IF NOT EXISTS animal_health_records (
    id SERIAL PRIMARY KEY,
    diagnosis_id INTEGER NOT NULL,
    animal_id INTEGER NOT NULL,
    vet_clinic_id INTEGER NOT NULL,
    treatment_start_date TIMESTAMP NOT NULL,
    treatment_end_date TIMESTAMP
);

--rollback DROP TABLE IF EXISTS animal_health_records CASCADE;