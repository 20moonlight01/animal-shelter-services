--liquibase formatted sql

--changeset 20moonlight01:45
--comment: Добавление внешнего ключа медзаписи к животному
--tag: v4
ALTER TABLE animal_health_records 
    ADD CONSTRAINT fk_animal_health_records_animal 
    FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE;

--rollback ALTER TABLE animal_health_records DROP CONSTRAINT IF EXISTS fk_animal_health_records_animal;