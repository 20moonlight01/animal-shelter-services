--liquibase formatted sql

--changeset 20moonlight01:61
--comment: Добавление внешнего ключа заявки к животному
--tag: v6
ALTER TABLE adoption_requests 
    ADD CONSTRAINT fk_adoption_requests_animal 
    FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE;

--rollback ALTER TABLE adoption_requests DROP CONSTRAINT IF EXISTS fk_adoption_requests_animal;