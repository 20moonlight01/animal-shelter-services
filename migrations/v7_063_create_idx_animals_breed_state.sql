--liquibase formatted sql

--changeset 20moonlight01:63
--comment: Индекс для быстрого поиска доступных животных
--tag: v7

CREATE INDEX IF NOT EXISTS idx_animals_breed_state ON animals (animal_state_id, animal_breed_id);

--rollback DROP INDEX IF EXISTS idx_animals_breed_state;