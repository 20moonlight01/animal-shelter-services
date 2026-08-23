--liquibase formatted sql

--changeset 20moonlight01:30
--comment: Создание таблицы животных
--tag: v3
CREATE TABLE IF NOT EXISTS animals (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    animal_breed_id INTEGER NOT NULL,
    gender gender_enum NOT NULL,
    estimated_birth_date TIMESTAMP NOT NULL,
    animal_state_id INTEGER NOT NULL
);

--rollback DROP TABLE IF EXISTS animals CASCADE;