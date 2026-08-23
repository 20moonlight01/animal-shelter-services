--liquibase formatted sql

--changeset 20moonlight01:13
--comment: Создание таблицы помещений
--tag: v1
CREATE TABLE IF NOT EXISTS facilities (
    id SERIAL PRIMARY KEY,
    facility_type_id INTEGER NOT NULL,
    location VARCHAR(255) NOT NULL
);

--rollback DROP TABLE IF EXISTS facilities CASCADE;