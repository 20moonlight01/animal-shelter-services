--liquibase formatted sql

--changeset 20moonlight01:36
--comment: Создание таблицы передачи животных
--tag: v3
CREATE TABLE IF NOT EXISTS adoptions (
    id SERIAL PRIMARY KEY,
    date TIMESTAMP NOT NULL,
    animal_id INTEGER NOT NULL,
    owner_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL
);

--rollback DROP TABLE IF EXISTS adoptions CASCADE;