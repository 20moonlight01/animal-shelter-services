--liquibase formatted sql

--changeset 20moonlight01:6
--comment: Создание таблицы должностей
--tag: v1
CREATE TABLE IF NOT EXISTS jobs (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

--rollback DROP TABLE IF EXISTS jobs CASCADE;