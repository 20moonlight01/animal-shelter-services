--liquibase formatted sql

--changeset 20moonlight01:1
--comment: Создание таблицы видов животных
--tag: v1
CREATE TABLE IF NOT EXISTS animal_species (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

--rollback DROP TABLE IF EXISTS animal_species CASCADE;