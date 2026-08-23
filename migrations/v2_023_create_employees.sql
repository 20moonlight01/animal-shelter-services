--liquibase formatted sql

--changeset 20moonlight01:23
--comment: Создание таблицы сотрудников
--tag: v2
CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    entity_id INTEGER NOT NULL,
    gender gender_enum NOT NULL,
    birth_date TIMESTAMP NOT NULL
);

--rollback DROP TABLE IF EXISTS employees CASCADE;