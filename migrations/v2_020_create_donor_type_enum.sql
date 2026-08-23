--liquibase formatted sql

--changeset 20moonlight01:20
--comment: Создание enum типа для типа благотворителя
--tag: v2
CREATE TYPE donor_type_enum AS ENUM ('INDIVIDUAL', 'LEGAL_ENTITY');

--rollback DROP TYPE IF EXISTS donor_type_enum CASCADE;