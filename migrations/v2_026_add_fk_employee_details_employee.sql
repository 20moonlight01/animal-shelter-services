--liquibase formatted sql

--changeset 20moonlight01:26
--comment: Добавление внешнего ключа деталей к сотруднику
--tag: v2
ALTER TABLE employee_details 
    ADD CONSTRAINT fk_employee_details_employee 
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE;

--rollback ALTER TABLE employee_details DROP CONSTRAINT IF EXISTS fk_employee_details_employee;