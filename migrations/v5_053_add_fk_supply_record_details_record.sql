--liquibase formatted sql

--changeset 20moonlight01:53
--comment: Добавление внешнего ключа деталей к записи поставки
--tag: v5
ALTER TABLE supply_record_details 
    ADD CONSTRAINT fk_supply_record_details_record 
    FOREIGN KEY (supply_record_id) REFERENCES supply_records(id) ON DELETE CASCADE;

--rollback ALTER TABLE supply_record_details DROP CONSTRAINT IF EXISTS fk_supply_record_details_record;