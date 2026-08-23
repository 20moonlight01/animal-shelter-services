--liquibase formatted sql

--changeset 20moonlight01:9
--comment: Создание таблицы состояний заявок
--tag: v1
CREATE TABLE IF NOT EXISTS request_states (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

--rollback DROP TABLE IF EXISTS request_states CASCADE;