--liquibase formatted sql

--changeset 20moonlight01:58
--comment: Создание enum типа для типа передачи животных
--tag: v6
CREATE TYPE adoption_type_enum AS ENUM ('FOSTER', 'PERMANENT');

--rollback DROP TYPE IF EXISTS adoption_type_enum CASCADE;