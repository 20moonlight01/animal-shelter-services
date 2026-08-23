DO $$
DECLARE
    v_seed_count INTEGER;
    v_count INTEGER;
BEGIN
    SELECT value::INTEGER INTO v_seed_count FROM seed_config WHERE key = 'seed_count';
    
    RAISE NOTICE 'Seeding v6 requests with SEED_COUNT=%', v_seed_count;
    
    v_count := 7 * v_seed_count;
    INSERT INTO adoption_requests (date, owner_id, animal_id, adoption_type, request_state_id)
    SELECT 
        CURRENT_DATE - (random() * 180)::INTEGER,
        (SELECT id FROM owners ORDER BY random() LIMIT 1),
        (SELECT id FROM animals WHERE animal_state_id != (SELECT id FROM animal_states WHERE name = 'Нашел дом') ORDER BY random() LIMIT 1),
        (ARRAY['FOSTER', 'PERMANENT'])[1 + floor(random() * 2)::INTEGER]::adoption_type_enum,
        1 + floor(random() * (SELECT COUNT(*) FROM request_states))::INTEGER
    FROM generate_series(1, v_count)
    WHERE EXISTS (SELECT 1 FROM animals WHERE animal_state_id != (SELECT id FROM animal_states WHERE name = 'Нашел дом'))
    ON CONFLICT DO NOTHING;
    RAISE NOTICE '  Created % adoption requests', v_count;
    
    RAISE NOTICE 'v6 data seeding completed';
END $$;