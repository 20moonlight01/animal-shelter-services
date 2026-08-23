--liquibase formatted sql

--changeset 20moonlight01:39
--comment: Добавление внешнего ключа передачи животных к сотруднику
--tag: v3
ALTER TABLE adoptions 
    ADD CONSTRAINT fk_adoptions_employee 
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE;

--rollback ALTER TABLE adoptions DROP CONSTRAINT IF EXISTS fk_adoptions_employee;