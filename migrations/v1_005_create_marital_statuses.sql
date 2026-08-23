--liquibase formatted sql

--changeset 20moonlight01:5
--comment: Создание таблицы семейных положений
--tag: v1
CREATE TABLE IF NOT EXISTS marital_statuses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

--rollback DROP TABLE IF EXISTS marital_statuses CASCADE;