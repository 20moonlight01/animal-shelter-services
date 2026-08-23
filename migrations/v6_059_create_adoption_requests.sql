--liquibase formatted sql

--changeset 20moonlight01:59
--comment: Создание таблицы заявок на передачу животных
--tag: v6
CREATE TABLE IF NOT EXISTS adoption_requests (
    id SERIAL PRIMARY KEY,
    date TIMESTAMP NOT NULL,
    owner_id INTEGER NOT NULL,
    animal_id INTEGER NOT NULL,
    adoption_type adoption_type_enum NOT NULL,
    request_state_id INTEGER NOT NULL
);

--rollback DROP TABLE IF EXISTS adoption_requests CASCADE;