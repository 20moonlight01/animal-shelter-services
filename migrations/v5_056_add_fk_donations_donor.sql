--liquibase formatted sql

--changeset 20moonlight01:56
--comment: Добавление внешнего ключа пожертвования к благотворителю
--tag: v5
ALTER TABLE donations 
    ADD CONSTRAINT fk_donations_donor 
    FOREIGN KEY (donor_id) REFERENCES donors(id) ON DELETE CASCADE;

--rollback ALTER TABLE donations DROP CONSTRAINT IF EXISTS fk_donations_donor;