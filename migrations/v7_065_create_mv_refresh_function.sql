--liquibase formatted sql

--changeset 20moonlight01:65 splitStatements:false
--comment: Функция для конкурентного обновления материализованного представления
--tag: v7

CREATE OR REPLACE FUNCTION refresh_donations_stats()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_donations_daily_stats;
END;
$$ LANGUAGE plpgsql;

--rollback DROP FUNCTION IF EXISTS refresh_donations_stats();