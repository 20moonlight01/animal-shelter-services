DO $$
DECLARE
    v_seed_count INTEGER;
    v_count INTEGER;
BEGIN
    SELECT value::INTEGER INTO v_seed_count FROM seed_config WHERE key = 'seed_count';
    
    RAISE NOTICE 'Seeding v4 data with SEED_COUNT=%', v_seed_count;
    
    v_count := 10 * v_seed_count;
    INSERT INTO animal_health_records (diagnosis_id, animal_id, vet_clinic_id, treatment_start_date, treatment_end_date)
    SELECT 
        1 + floor(random() * (SELECT COUNT(*) FROM diagnoses))::INTEGER,
        (SELECT id FROM animals ORDER BY random() LIMIT 1),
        (SELECT id FROM suppliers ORDER BY random() LIMIT 1),
        CURRENT_DATE - (random() * 730)::INTEGER,
        CASE WHEN random() < 0.6 THEN CURRENT_DATE - (random() * 365)::INTEGER + (1 + floor(random() * 90))::INTEGER ELSE NULL END
    FROM generate_series(1, v_count)
    ON CONFLICT DO NOTHING;
    RAISE NOTICE '  Created % health records', v_count;
    
    v_count := 15 * v_seed_count;
    INSERT INTO treatments (animal_health_record_id, medication_id, commentary, medication_start_date, medication_end_date)
    SELECT 
        (SELECT id FROM animal_health_records ORDER BY random() LIMIT 1),
        1 + floor(random() * (SELECT COUNT(*) FROM medications))::INTEGER,
        CASE WHEN random() < 0.5 THEN faker.sentence(6) ELSE NULL END,
        CURRENT_DATE - (random() * 730)::INTEGER,
        CURRENT_DATE - (random() * 365)::INTEGER + (1 + floor(random() * 60))::INTEGER
    FROM generate_series(1, v_count)
    ON CONFLICT DO NOTHING;
    RAISE NOTICE '  Created % treatments', v_count;
    
    RAISE NOTICE 'v4 data seeding completed';
END $$;