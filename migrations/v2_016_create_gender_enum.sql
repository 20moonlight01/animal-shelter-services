--liquibase formatted sql

--changeset 20moonlight01:16
--comment: Создание enum типа для пола
--tag: v2
CREATE TYPE gender_enum AS ENUM ('MALE', 'FEMALE', 'OTHER');

--rollback DROP TYPE IF EXISTS gender_enum CASCADE;