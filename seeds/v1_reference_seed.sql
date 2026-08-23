DO $$
BEGIN
    RAISE NOTICE 'Seeding v1 data...';
    
    INSERT INTO animal_species (name) VALUES 
        ('Собака'), ('Кошка'), ('Птица'), ('Грызун'), ('Кролик')
    ON CONFLICT (name) DO NOTHING;
    
    INSERT INTO facility_types (name) VALUES 
        ('Вольер'), ('Клетка'), ('Изолятор'), ('Двор'), ('Фойе')
    ON CONFLICT (name) DO NOTHING;
    
    INSERT INTO diagnoses (name) VALUES 
        ('Здоров'), ('Вакцинация'), ('Травма'), ('Инфекция'), ('Кастрация'),
        ('Стерилизация'), ('Паразиты'), ('Аллергия'), ('Простуда'), ('Перелом')
    ON CONFLICT (name) DO NOTHING;
    
    INSERT INTO medications (name) VALUES 
        ('Антибиотик'), ('Обезболивающее'), ('Витамины'), ('Антигельминтик'),
        ('Противовоспалительное'), ('Антигистаминное'), ('Жаропонижающее'), ('Пробиотик')
    ON CONFLICT (name) DO NOTHING;
    
    INSERT INTO marital_statuses (name) VALUES 
        ('Холост/Не замужем'), ('Женат/Замужем'), ('Разведен/а'), ('Вдовец/Вдова')
    ON CONFLICT (name) DO NOTHING;
    
    INSERT INTO jobs (name) VALUES 
        ('Ветеринар'), ('Кинолог'), ('Администратор'), ('Волонтер'), ('Уборщик'),
        ('Менеджер'), ('Зоотехник'), ('Психолог')
    ON CONFLICT (name) DO NOTHING;
    
    INSERT INTO supply_items (name) VALUES 
        ('Корм сухой'), ('Корм влажный'), ('Наполнитель'), ('Игрушки'), ('Лекарства'),
        ('Амуниция'), ('Шампунь'), ('Клетка'), ('Переноска'), ('Миска')
    ON CONFLICT (name) DO NOTHING;
    
    INSERT INTO payment_types (name) VALUES 
        ('Наличные'), ('Карта'), ('Перевод'), ('Криптовалюта'), ('Благотворительный счет')
    ON CONFLICT (name) DO NOTHING;
    
    INSERT INTO request_states (name) VALUES 
        ('Новая'), ('На рассмотрении'), ('Одобрена'), ('Отклонена'), ('Завершена'), ('Отложена')
    ON CONFLICT (name) DO NOTHING;
    
    INSERT INTO animal_states (name) VALUES 
        ('Здоров'), ('На лечении'), ('Карантин'), ('Ищет дом'), ('Нашел дом'), ('Передержка')
    ON CONFLICT (name) DO NOTHING;
    
    INSERT INTO animal_breeds (name, animal_species_id)
    SELECT breed.name, s.id
    FROM (VALUES 
        ('Лабрадор', 'Собака'),
        ('Немецкая овчарка', 'Собака'),
        ('Дворняга', 'Собака'),
        ('Сиамская', 'Кошка'),
        ('Британская', 'Кошка'),
        ('Дворовая', 'Кошка'),
        ('Попугай', 'Птица'),
        ('Канарейка', 'Птица'),
        ('Хомяк', 'Грызун'),
        ('Морская свинка', 'Грызун'),
        ('Кролик', 'Кролик')
    ) AS breed(name, species_name)
    JOIN animal_species s ON s.name = breed.species_name
    ON CONFLICT (name, animal_species_id) DO NOTHING;
    
    INSERT INTO facilities (facility_type_id, location)
    SELECT 
        ft.id,
        CONCAT('Корпус ', ft.name, ' №', row_number() OVER ())
    FROM facility_types ft
    CROSS JOIN generate_series(1, 3)
    ON CONFLICT DO NOTHING;
    
    RAISE NOTICE 'v1 data seeding completed';
END $$;