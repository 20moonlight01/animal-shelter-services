--liquibase formatted sql

--changeset 20moonlight01:15
--comment: Создание таблицы сущностей (общая информация)
--tag: v2
CREATE TABLE IF NOT EXISTS entities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contacts VARCHAR(500) NOT NULL,
    address TEXT
);

--rollback DROP TABLE IF EXISTS entities CASCADE;