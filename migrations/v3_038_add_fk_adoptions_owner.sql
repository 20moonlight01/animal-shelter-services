--liquibase formatted sql

--changeset 20moonlight01:38
--comment: Добавление внешнего ключа передачи животных к владельцу
--tag: v3
ALTER TABLE adoptions 
    ADD CONSTRAINT fk_adoptions_owner 
    FOREIGN KEY (owner_id) REFERENCES owners(id) ON DELETE CASCADE;

--rollback ALTER TABLE adoptions DROP CONSTRAINT IF EXISTS fk_adoptions_owner;