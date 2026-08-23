--liquibase formatted sql

--changeset 20moonlight01:34
--comment: Добавление внешнего ключа прибытия к животному
--tag: v3
ALTER TABLE animal_arrivals 
    ADD CONSTRAINT fk_animal_arrivals_animal 
    FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE;

--rollback ALTER TABLE animal_arrivals DROP CONSTRAINT IF EXISTS fk_animal_arrivals_animal;