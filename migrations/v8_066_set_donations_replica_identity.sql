--liquibase formatted sql

--changeset 20moonlight01:66
--comment: Включение полной репликации строк для CDC Debezium
ALTER TABLE donations REPLICA IDENTITY FULL;

--rollback ALTER TABLE donations REPLICA IDENTITY DEFAULT;