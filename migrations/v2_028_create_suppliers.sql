--liquibase formatted sql

--changeset 20moonlight01:28
--comment: Создание таблицы поставщиков
--tag: v2
CREATE TABLE IF NOT EXISTS suppliers (
    id SERIAL PRIMARY KEY,
    entity_id INTEGER NOT NULL,
    cooperation_start_date TIMESTAMP NOT NULL,
    cooperation_end_date TIMESTAMP
);

--rollback DROP TABLE IF EXISTS suppliers CASCADE;