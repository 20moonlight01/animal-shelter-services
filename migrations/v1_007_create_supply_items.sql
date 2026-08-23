--liquibase formatted sql

--changeset 20moonlight01:7
--comment: Создание таблицы товаров для поставок
--tag: v1
CREATE TABLE IF NOT EXISTS supply_items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL UNIQUE
);

--rollback DROP TABLE IF EXISTS supply_items CASCADE;