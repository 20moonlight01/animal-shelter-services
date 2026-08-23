--liquibase formatted sql

--changeset 20moonlight01:21
--comment: Создание таблицы благотворителей
--tag: v2
CREATE TABLE IF NOT EXISTS donors (
    id SERIAL PRIMARY KEY,
    entity_id INTEGER NOT NULL,
    type donor_type_enum NOT NULL
);

--rollback DROP TABLE IF EXISTS donors CASCADE;