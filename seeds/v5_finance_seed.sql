DO $$
DECLARE
    v_seed_count INTEGER;
    v_count INTEGER;
BEGIN
    SELECT value::INTEGER INTO v_seed_count FROM seed_config WHERE key = 'seed_count';
    
    RAISE NOTICE 'Seeding v5 data with SEED_COUNT=%', v_seed_count;
    
    v_count := 4 * v_seed_count;
    INSERT INTO supply_records (date, supplier_id, cost)
    SELECT 
        CURRENT_DATE - (random() * 365)::INTEGER,
        (SELECT id FROM suppliers ORDER BY random() LIMIT 1),
        round((random() * 50000 + 1000)::numeric, 2)
    FROM generate_series(1, v_count)
    ON CONFLICT DO NOTHING;
    RAISE NOTICE '  Created % supply records', v_count;
    
    INSERT INTO supply_record_details (supply_record_id, supply_item_id, quantity, price)
    SELECT 
        (SELECT id FROM supply_records ORDER BY random() LIMIT 1),
        1 + floor(random() * (SELECT COUNT(*) FROM supply_items))::INTEGER,
        1 + floor(random() * 100)::INTEGER,
        round((random() * 1000 + 10)::numeric, 2)
    FROM generate_series(1, v_count * 3)
    ON CONFLICT DO NOTHING;
    
    v_count := 5 * v_seed_count;
    INSERT INTO donations (date, amount, donor_id, payment_type_id, purpose)
    SELECT 
        CURRENT_DATE - (random() * 730)::INTEGER,
        round((random() * 10000 + 100)::numeric, 2),
        (SELECT id FROM donors ORDER BY random() LIMIT 1),
        1 + floor(random() * (SELECT COUNT(*) FROM payment_types))::INTEGER,
        CASE WHEN random() < 0.4 THEN faker.sentence(4) ELSE NULL END
    FROM generate_series(1, v_count)
    ON CONFLICT DO NOTHING;
    RAISE NOTICE '  Created % donations', v_count;
    
    RAISE NOTICE 'v5 data seeding completed';
END $$;