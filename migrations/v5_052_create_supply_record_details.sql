--liquibase formatted sql

--changeset 20moonlight01:52
--comment: Создание таблицы деталей поставок
--tag: v5
CREATE TABLE IF NOT EXISTS supply_record_details (
    id SERIAL PRIMARY KEY,
    supply_record_id INTEGER NOT NULL,
    supply_item_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

--rollback DROP TABLE IF EXISTS supply_record_details CASCADE;