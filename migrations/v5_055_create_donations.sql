--liquibase formatted sql

--changeset 20moonlight01:55
--comment: Создание таблицы пожертвований
--tag: v5
CREATE TABLE IF NOT EXISTS donations (
    id SERIAL PRIMARY KEY,
    date TIMESTAMP NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    donor_id INTEGER NOT NULL,
    payment_type_id INTEGER NOT NULL,
    purpose TEXT
);

--rollback DROP TABLE IF EXISTS donations CASCADE;