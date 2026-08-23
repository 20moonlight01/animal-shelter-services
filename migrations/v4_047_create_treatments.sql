--liquibase formatted sql

--changeset 20moonlight01:47
--comment: Создание таблицы лечений
--tag: v4
CREATE TABLE IF NOT EXISTS treatments (
    id SERIAL PRIMARY KEY,
    animal_health_record_id INTEGER NOT NULL,
    medication_id INTEGER NOT NULL,
    commentary TEXT,
    medication_start_date TIMESTAMP NOT NULL,
    medication_end_date TIMESTAMP
);

--rollback DROP TABLE IF EXISTS treatments CASCADE;