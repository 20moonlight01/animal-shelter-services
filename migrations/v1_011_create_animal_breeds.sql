--liquibase formatted sql

--changeset 20moonlight01:11
--comment: Создание таблицы пород животных
--tag: v1
CREATE TABLE IF NOT EXISTS animal_breeds (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    animal_species_id INTEGER NOT NULL,
    UNIQUE(name, animal_species_id)
);

--rollback DROP TABLE IF EXISTS animal_breeds CASCADE;