--liquibase formatted sql

--changeset 20moonlight01:12
--comment: Добавление внешнего ключа пород к видам животных
--tag: v1
ALTER TABLE animal_breeds 
    ADD CONSTRAINT fk_animal_breeds_species 
    FOREIGN KEY (animal_species_id) REFERENCES animal_species(id) ON DELETE CASCADE;

--rollback ALTER TABLE animal_breeds DROP CONSTRAINT IF EXISTS fk_animal_breeds_species;