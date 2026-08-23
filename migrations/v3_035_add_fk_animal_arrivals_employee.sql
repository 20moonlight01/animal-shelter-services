--liquibase formatted sql

--changeset 20moonlight01:35
--comment: Добавление внешнего ключа прибытия к сотруднику
--tag: v3
ALTER TABLE animal_arrivals 
    ADD CONSTRAINT fk_animal_arrivals_employee 
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE;

--rollback ALTER TABLE animal_arrivals DROP CONSTRAINT IF EXISTS fk_animal_arrivals_employee;