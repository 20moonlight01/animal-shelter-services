--liquibase formatted sql

--changeset 20moonlight01:10
--comment: Создание таблицы состояний животных
--tag: v1
CREATE TABLE IF NOT EXISTS animal_states (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

--rollback DROP TABLE IF EXISTS animal_states CASCADE;