--liquibase formatted sql

--changeset 20moonlight01:31
--comment: Добавление внешнего ключа животных к породе
--tag: v3
ALTER TABLE animals 
    ADD CONSTRAINT fk_animals_breed 
    FOREIGN KEY (animal_breed_id) REFERENCES animal_breeds(id) ON DELETE CASCADE;

--rollback ALTER TABLE animals DROP CONSTRAINT IF EXISTS fk_animals_breed;