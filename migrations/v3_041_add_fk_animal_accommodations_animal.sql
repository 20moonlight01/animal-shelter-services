--liquibase formatted sql

--changeset 20moonlight01:41
--comment: Добавление внешнего ключа размещения к животному
--tag: v3
ALTER TABLE animal_accommodations 
    ADD CONSTRAINT fk_animal_accommodations_animal 
    FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE;

--rollback ALTER TABLE animal_accommodations DROP CONSTRAINT IF EXISTS fk_animal_accommodations_animal;