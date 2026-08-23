--liquibase formatted sql

--changeset 20moonlight01:4
--comment: Создание таблицы лекарств
--tag: v1
CREATE TABLE IF NOT EXISTS medications (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL UNIQUE
);

--rollback DROP TABLE IF EXISTS medications CASCADE;