--liquibase formatted sql

--changeset 20moonlight01:64 splitStatements:false
--comment: Создание универсального материализованного представления для аналитики пожертвований
--tag: v7

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_matviews WHERE matviewname = 'mv_donations_daily_stats') THEN
        CREATE MATERIALIZED VIEW mv_donations_daily_stats AS
        SELECT 
            d.date::date as donation_day,
            dr.type as donor_type,
            pt.name as payment_method,
            COUNT(d.id) as transactions_count,
            SUM(d.amount) as total_amount,
            COUNT(DISTINCT d.donor_id) as unique_donors
        FROM donations d
        JOIN donors dr ON d.donor_id = dr.id
        JOIN payment_types pt ON d.payment_type_id = pt.id
        GROUP BY d.date::date, dr.type, pt.name;
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_donations_daily_day_type_pay 
ON mv_donations_daily_stats (donation_day, donor_type, payment_method);

--rollback DROP MATERIALIZED VIEW IF EXISTS mv_donations_daily_stats;