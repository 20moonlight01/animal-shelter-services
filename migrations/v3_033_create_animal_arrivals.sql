--liquibase formatted sql

--changeset 20moonlight01:33
--comment: Создание таблицы прибытия животных
--tag: v3
CREATE TABLE IF NOT EXISTS animal_arrivals (
    id SERIAL PRIMARY KEY,
    date TIMESTAMP NOT NULL,
    animal_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    commentary TEXT
);

--rollback DROP TABLE IF EXISTS animal_arrivals CASCADE;