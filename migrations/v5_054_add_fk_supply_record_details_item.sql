--liquibase formatted sql

--changeset 20moonlight01:54
--comment: Добавление внешнего ключа деталей к товару
--tag: v5
ALTER TABLE supply_record_details 
    ADD CONSTRAINT fk_supply_record_details_item 
    FOREIGN KEY (supply_item_id) REFERENCES supply_items(id) ON DELETE CASCADE;

--rollback ALTER TABLE supply_record_details DROP CONSTRAINT IF EXISTS fk_supply_record_details_item;