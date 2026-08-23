--liquibase formatted sql

--changeset 20moonlight01:32
--comment: Добавление внешнего ключа животных к состоянию
--tag: v3
ALTER TABLE animals 
    ADD CONSTRAINT fk_animals_state 
    FOREIGN KEY (animal_state_id) REFERENCES animal_states(id) ON DELETE CASCADE;

--rollback ALTER TABLE animals DROP CONSTRAINT IF EXISTS fk_animals_state;