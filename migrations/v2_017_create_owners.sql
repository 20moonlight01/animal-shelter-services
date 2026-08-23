--liquibase formatted sql

--changeset 20moonlight01:17
--comment: Создание таблицы владельцев
--tag: v2
CREATE TABLE IF NOT EXISTS owners (
    id SERIAL PRIMARY KEY,
    entity_id INTEGER NOT NULL,
    gender gender_enum NOT NULL,
    birth_date TIMESTAMP NOT NULL,
    marital_status_id INTEGER NOT NULL
);

--rollback DROP TABLE IF EXISTS owners CASCADE;