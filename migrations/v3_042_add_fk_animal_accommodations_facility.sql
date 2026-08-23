--liquibase formatted sql

--changeset 20moonlight01:42
--comment: Добавление внешнего ключа размещения к помещению
--tag: v3
ALTER TABLE animal_accommodations 
    ADD CONSTRAINT fk_animal_accommodations_facility 
    FOREIGN KEY (accommodation_id) REFERENCES facilities(id) ON DELETE CASCADE;

--rollback ALTER TABLE animal_accommodations DROP CONSTRAINT IF EXISTS fk_animal_accommodations_facility;