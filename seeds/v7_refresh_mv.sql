DO $$
BEGIN
    RAISE NOTICE 'Starting v7: Refreshing materialized views after seeding...';

    BEGIN
        PERFORM refresh_donations_stats();
        RAISE NOTICE 'Materialized view mv_donations_daily_stats refreshed successfully';
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Concurrent refresh failed, attempting standard refresh. Error: %', SQLERRM;
        REFRESH MATERIALIZED VIEW mv_donations_daily_stats;
        RAISE NOTICE 'Materialized view mv_donations_daily_stats refreshed (standard)';
    END;
RAISE NOTICE 'v7 views refresh completed';
END $$;