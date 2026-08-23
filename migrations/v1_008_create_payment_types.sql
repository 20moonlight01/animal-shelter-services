--liquibase formatted sql

--changeset 20moonlight01:8
--comment: Создание таблицы типов оплаты
--tag: v1
CREATE TABLE IF NOT EXISTS payment_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

--rollback DROP TABLE IF EXISTS payment_types CASCADE;