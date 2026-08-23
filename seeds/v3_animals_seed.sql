DO $$
DECLARE
    v_seed_count INTEGER;
    v_count INTEGER;
BEGIN
    SELECT value::INTEGER INTO v_seed_count FROM seed_config WHERE key = 'seed_count';
    
    RAISE NOTICE 'Seeding v3 data with SEED_COUNT=%', v_seed_count;
    
    v_count := 10 * v_seed_count;
    INSERT INTO animals (name, animal_breed_id, gender, estimated_birth_date, animal_state_id)
    SELECT 
        faker.first_name(),
        b.id,
        (ARRAY['MALE', 'FEMALE', 'OTHER'])[1 + floor(random() * 3)::INTEGER]::gender_enum,
        faker.date_of_birth(min_age := 0, max_age := 15),
        1 + floor(random() * (SELECT COUNT(*) FROM animal_states))::INTEGER
    FROM animal_breeds b
    CROSS JOIN generate_series(1, GREATEST(1, v_count / NULLIF((SELECT COUNT(*) FROM animal_breeds), 0)))
    LIMIT v_count
    ON CONFLICT DO NOTHING;
    RAISE NOTICE '  Created % animals', v_count;
    
    v_count := 8 * v_seed_count;
    INSERT INTO animal_arrivals (date, animal_id, employee_id, commentary)
    SELECT 
        CURRENT_DATE - (random() * 730)::INTEGER,
        (SELECT id FROM animals ORDER BY random() LIMIT 1),
        (SELECT id FROM employees ORDER BY random() LIMIT 1),
        CASE WHEN random() < 0.3 THEN faker.sentence(8) ELSE NULL END
    FROM generate_series(1, v_count)
    ON CONFLICT DO NOTHING;
    RAISE NOTICE '  Created % arrivals', v_count;
    
    v_count := 6 * v_seed_count;
    INSERT INTO adoptions (date, animal_id, owner_id, employee_id)
    SELECT 
        CURRENT_DATE - (random() * 730)::INTEGER,
        (SELECT id FROM animals WHERE animal_state_id = (SELECT id FROM animal_states WHERE name = 'Нашел дом') ORDER BY random() LIMIT 1),
        (SELECT id FROM owners ORDER BY random() LIMIT 1),
        (SELECT id FROM employees ORDER BY random() LIMIT 1)
    FROM generate_series(1, v_count)
    WHERE EXISTS (SELECT 1 FROM animals WHERE animal_state_id = (SELECT id FROM animal_states WHERE name = 'Нашел дом'))
    ON CONFLICT DO NOTHING;
    RAISE NOTICE '  Created % adoptions', v_count;
    
    v_count := 12 * v_seed_count;
    INSERT INTO animal_accommodations (animal_id, accommodation_id, start_date, end_date)
    SELECT 
        (SELECT id FROM animals ORDER BY random() LIMIT 1),
        (SELECT id FROM facilities ORDER BY random() LIMIT 1),
        CURRENT_DATE - (random() * 365)::INTEGER,
        CASE WHEN random() < 0.7 THEN CURRENT_DATE - (random() * 365)::INTEGER + (1 + floor(random() * 60))::INTEGER ELSE NULL END
    FROM generate_series(1, v_count)
    ON CONFLICT DO NOTHING;
    RAISE NOTICE '  Created % accommodations', v_count;
    
    RAISE NOTICE 'v3 data seeding completed';
END $$;