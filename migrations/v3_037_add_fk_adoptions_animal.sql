--liquibase formatted sql

--changeset 20moonlight01:37
--comment: Добавление внешнего ключа передачи животных к животному
--tag: v3
ALTER TABLE adoptions 
    ADD CONSTRAINT fk_adoptions_animal 
    FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE;

--rollback ALTER TABLE adoptions DROP CONSTRAINT IF EXISTS fk_adoptions_animal;