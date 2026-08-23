--liquibase formatted sql

--changeset 20moonlight01:51
--comment: Добавление внешнего ключа поставки к поставщику
--tag: v5
ALTER TABLE supply_records 
    ADD CONSTRAINT fk_supply_records_supplier 
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE;

--rollback ALTER TABLE supply_records DROP CONSTRAINT IF EXISTS fk_supply_records_supplier;