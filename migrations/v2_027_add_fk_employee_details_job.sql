--liquibase formatted sql

--changeset 20moonlight01:27
--comment: Добавление внешнего ключа деталей к должности
--tag: v2
ALTER TABLE employee_details 
    ADD CONSTRAINT fk_employee_details_job 
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE;

--rollback ALTER TABLE employee_details DROP CONSTRAINT IF EXISTS fk_employee_details_job;