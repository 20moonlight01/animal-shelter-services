--liquibase formatted sql

--changeset 20moonlight01:25
--comment: Создание таблицы деталей работы сотрудников
--tag: v2
CREATE TABLE IF NOT EXISTS employee_details (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    job_id INTEGER NOT NULL,
    working_start_date TIMESTAMP NOT NULL,
    working_end_date TIMESTAMP
);

--rollback DROP TABLE IF EXISTS employee_details CASCADE;