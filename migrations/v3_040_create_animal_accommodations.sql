--liquibase formatted sql

--changeset 20moonlight01:40
--comment: Создание таблицы размещения животных
--tag: v3
CREATE TABLE IF NOT EXISTS animal_accommodations (
    id SERIAL PRIMARY KEY,
    animal_id INTEGER NOT NULL,
    accommodation_id INTEGER NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP
);

--rollback DROP TABLE IF EXISTS animal_accommodations CASCADE;