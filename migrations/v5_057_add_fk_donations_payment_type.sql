--liquibase formatted sql

--changeset 20moonlight01:57
--comment: Добавление внешнего ключа пожертвования к типу оплаты
--tag: v5
ALTER TABLE donations 
    ADD CONSTRAINT fk_donations_payment_type 
    FOREIGN KEY (payment_type_id) REFERENCES payment_types(id) ON DELETE CASCADE;

--rollback ALTER TABLE donations DROP CONSTRAINT IF EXISTS fk_donations_payment_type;