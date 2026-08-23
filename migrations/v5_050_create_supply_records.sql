--liquibase formatted sql

--changeset 20moonlight01:50
--comment: Создание таблицы записей поставок
--tag: v5
CREATE TABLE IF NOT EXISTS supply_records (
    id SERIAL PRIMARY KEY,
    date TIMESTAMP NOT NULL,
    supplier_id INTEGER NOT NULL,
    cost DECIMAL(10,2) NOT NULL
);

--rollback DROP TABLE IF EXISTS supply_records CASCADE;