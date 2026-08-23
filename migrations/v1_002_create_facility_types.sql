--liquibase formatted sql

--changeset 20moonlight01:2
--comment: Создание таблицы типов помещений
--tag: v1
CREATE TABLE IF NOT EXISTS facility_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

--rollback DROP TABLE IF EXISTS facility_types CASCADE;