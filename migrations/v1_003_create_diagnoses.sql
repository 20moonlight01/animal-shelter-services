--liquibase formatted sql

--changeset 20moonlight01:3
--comment: Создание таблицы диагнозов
--tag: v1
CREATE TABLE IF NOT EXISTS diagnoses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL UNIQUE
);

--rollback DROP TABLE IF EXISTS diagnoses CASCADE;