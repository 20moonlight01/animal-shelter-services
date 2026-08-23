CREATE SCHEMA IF NOT EXISTS faker;

CREATE OR REPLACE FUNCTION faker.name() 
RETURNS TEXT LANGUAGE plpython3u AS $$
    if 'fake' not in SD:
        from faker import Faker
        SD['fake'] = Faker('ru_RU')
    return SD['fake'].name()
$$;

CREATE OR REPLACE FUNCTION faker.email() 
RETURNS TEXT LANGUAGE plpython3u AS $$
    if 'fake' not in SD:
        from faker import Faker
        SD['fake'] = Faker('ru_RU')
    return SD['fake'].email()
$$;

CREATE OR REPLACE FUNCTION faker.phone_number() 
RETURNS TEXT LANGUAGE plpython3u AS $$
    if 'fake' not in SD:
        from faker import Faker
        SD['fake'] = Faker('ru_RU')
    return SD['fake'].phone_number()
$$;

CREATE OR REPLACE FUNCTION faker.address() 
RETURNS TEXT LANGUAGE plpython3u AS $$
    if 'fake' not in SD:
        from faker import Faker
        SD['fake'] = Faker('ru_RU')
    return SD['fake'].address()
$$;

CREATE OR REPLACE FUNCTION faker.first_name() 
RETURNS TEXT LANGUAGE plpython3u AS $$
    if 'fake' not in SD:
        from faker import Faker
        SD['fake'] = Faker('ru_RU')
    return SD['fake'].first_name()
$$;

CREATE OR REPLACE FUNCTION faker.last_name() 
RETURNS TEXT LANGUAGE plpython3u AS $$
    if 'fake' not in SD:
        from faker import Faker
        SD['fake'] = Faker('ru_RU')
    return SD['fake'].last_name()
$$;

CREATE OR REPLACE FUNCTION faker.date_of_birth(min_age INTEGER DEFAULT 18, max_age INTEGER DEFAULT 80) 
RETURNS DATE LANGUAGE plpython3u AS $$
    if 'fake' not in SD:
        from faker import Faker
        SD['fake'] = Faker('ru_RU')
    return SD['fake'].date_of_birth(minimum_age=min_age, maximum_age=max_age)
$$;

CREATE OR REPLACE FUNCTION faker.sentence(words INTEGER DEFAULT 5) 
RETURNS TEXT LANGUAGE plpython3u AS $$
    if 'fake' not in SD:
        from faker import Faker
        SD['fake'] = Faker('ru_RU')
    return SD['fake'].sentence(nb_words=words)
$$;