DO $$
DECLARE
    v_seed_count INTEGER;
    v_count INTEGER;
BEGIN
    SELECT value::INTEGER INTO v_seed_count FROM seed_config WHERE key = 'seed_count';
    
    RAISE NOTICE 'Seeding v2 data with SEED_COUNT=%', v_seed_count;
    
    v_count := 15 * v_seed_count;
    INSERT INTO entities (name, contacts, address)
    SELECT 
        faker.name(),
        faker.phone_number() || ', ' || faker.email(),
        faker.address()
    FROM generate_series(1, v_count)
    ON CONFLICT DO NOTHING;
    RAISE NOTICE '  Created % entities', v_count;
    
    v_count := 5 * v_seed_count;
    INSERT INTO owners (entity_id, gender, birth_date, marital_status_id)
    SELECT 
        e.id,
        (ARRAY['MALE', 'FEMALE', 'OTHER'])[1 + floor(random() * 3)::INTEGER]::gender_enum,
        faker.date_of_birth(),
        1 + floor(random() * 4)::INTEGER
    FROM entities e
    ORDER BY e.id
    LIMIT v_count
    ON CONFLICT DO NOTHING;
    RAISE NOTICE '  Created % owners', v_count;
    
    v_count := 2 * v_seed_count;
    INSERT INTO donors (entity_id, type)
    SELECT 
        e.id,
        (ARRAY['INDIVIDUAL', 'LEGAL_ENTITY'])[1 + floor(random() * 2)::INTEGER]::donor_type_enum
    FROM entities e
    OFFSET (5 * v_seed_count)
    LIMIT v_count
    ON CONFLICT DO NOTHING;
    RAISE NOTICE '  Created % donors', v_count;
    
    v_count := 3 * v_seed_count;
    INSERT INTO employees (entity_id, gender, birth_date)
    SELECT 
        e.id,
        (ARRAY['MALE', 'FEMALE', 'OTHER'])[1 + floor(random() * 3)::INTEGER]::gender_enum,
        faker.date_of_birth(min_age := 18, max_age := 65)
    FROM entities e
    OFFSET (7 * v_seed_count)
    LIMIT v_count
    ON CONFLICT DO NOTHING;
    RAISE NOTICE '  Created % employees', v_count;
    
    INSERT INTO employee_details (employee_id, job_id, working_start_date, working_end_date)
    SELECT 
        e.id,
        1 + floor(random() * (SELECT COUNT(*) FROM jobs))::INTEGER,
        CURRENT_DATE - (random() * 365 * 5)::INTEGER,
        CASE WHEN random() < 0.15 THEN CURRENT_DATE - (random() * 365)::INTEGER ELSE NULL END
    FROM employees e
    ON CONFLICT DO NOTHING;
    
    v_count := 1 * v_seed_count;
    INSERT INTO suppliers (entity_id, cooperation_start_date, cooperation_end_date)
    SELECT 
        e.id,
        CURRENT_DATE - (random() * 365 * 3)::INTEGER,
        CASE WHEN random() < 0.2 THEN CURRENT_DATE - (random() * 365)::INTEGER ELSE NULL END
    FROM entities e
    OFFSET (10 * v_seed_count)
    LIMIT v_count
    ON CONFLICT DO NOTHING;
    RAISE NOTICE '  Created % suppliers', v_count;
    
    RAISE NOTICE 'v2 data seeding completed';
END $$;