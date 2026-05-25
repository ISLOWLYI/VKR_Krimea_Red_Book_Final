-- ГЕНЕРАЦИЯ АРЕАЛОВ (ГЕОМЕТРИЙ)
-- Примечание: Координаты аппроксимированы на основе описания мест обитания.

DO $$
DECLARE
    pid INTEGER;
    r RECORD; -- Объявляем переменную цикла как RECORD
BEGIN
    -- Папоротники (Горный Крым, Яйла, влажные леса)
    
    -- Гроздовник полулунный
    SELECT plant_id INTO pid FROM plants WHERE rus_name = 'Гроздовник полулунный';
    IF pid IS NOT NULL THEN
        INSERT INTO areas (plant_id, geom) VALUES (pid, ST_GeomFromText('POLYGON((34.25 44.65, 34.35 44.65, 34.35 44.75, 34.25 44.75, 34.25 44.65))', 4326));
    END IF;

    -- Ужовник обыкновенный
    SELECT plant_id INTO pid FROM plants WHERE rus_name = 'Ужовник обыкновенный';
    IF pid IS NOT NULL THEN
        INSERT INTO areas (plant_id, geom) VALUES (pid, ST_GeomFromText('POLYGON((34.10 44.50, 34.20 44.50, 34.20 44.60, 34.10 44.60, 34.10 44.50))', 4326));
    END IF;

    -- Хвощ речной
    SELECT plant_id INTO pid FROM plants WHERE rus_name = 'Хвощ речной';
    IF pid IS NOT NULL THEN
        INSERT INTO areas (plant_id, geom) VALUES (pid, ST_GeomFromText('POLYGON((34.30 44.80, 34.40 44.80, 34.40 44.90, 34.30 44.90, 34.30 44.80))', 4326));
    END IF;

    -- Костенец чёрный
    SELECT plant_id INTO pid FROM plants WHERE rus_name = 'Костенец чёрный';
    IF pid IS NOT NULL THEN
        INSERT INTO areas (plant_id, geom) VALUES (pid, ST_GeomFromText('POLYGON((34.00 44.50, 34.50 44.50, 34.50 44.70, 34.00 44.70, 34.00 44.50))', 4326));
    END IF;

    -- Краекучник орляковый (Ай-Петри)
    SELECT plant_id INTO pid FROM plants WHERE rus_name = 'Краекучник орляковый';
    IF pid IS NOT NULL THEN
        INSERT INTO areas (plant_id, geom) VALUES (pid, ST_GeomFromText('POLYGON((34.05 44.45, 34.15 44.45, 34.15 44.50, 34.05 44.50, 34.05 44.45))', 4326));
    END IF;

    -- Адиантум венерин волос (Водопады)
    SELECT plant_id INTO pid FROM plants WHERE rus_name = 'Адиантум венерин волос';
    IF pid IS NOT NULL THEN
        INSERT INTO areas (plant_id, geom) VALUES (pid, ST_GeomFromText('POLYGON((34.20 44.60, 34.30 44.60, 34.30 44.70, 34.20 44.70, 34.20 44.60))', 4326));
    END IF;

    -- Голосеменные
    
    -- Можжевельник высокий
    SELECT plant_id INTO pid FROM plants WHERE rus_name = 'Можжевельник высокий';
    IF pid IS NOT NULL THEN
        INSERT INTO areas (plant_id, geom) VALUES (pid, ST_GeomFromText('POLYGON((34.30 44.50, 34.60 44.50, 34.60 44.65, 34.30 44.65, 34.30 44.50))', 4326));
    END IF;

    -- Тис ягодный
    SELECT plant_id INTO pid FROM plants WHERE rus_name = 'Тис ягодный';
    IF pid IS NOT NULL THEN
        INSERT INTO areas (plant_id, geom) VALUES (pid, ST_GeomFromText('POLYGON((34.10 44.60, 34.40 44.60, 34.40 44.75, 34.10 44.75, 34.10 44.60))', 4326));
    END IF;

    -- Сосна брутийская
    SELECT plant_id INTO pid FROM plants WHERE rus_name = 'Сосна брутийская';
    IF pid IS NOT NULL THEN
        INSERT INTO areas (plant_id, geom) VALUES (pid, ST_GeomFromText('POLYGON((35.00 44.80, 35.20 44.80, 35.20 44.95, 35.00 44.95, 35.00 44.80))', 4326));
    END IF;

    -- Цветковые (Прибрежные и Степные)
    
    -- Взморник морской
    SELECT plant_id INTO pid FROM plants WHERE rus_name = 'Взморник морской';
    IF pid IS NOT NULL THEN
        INSERT INTO areas (plant_id, geom) VALUES (pid, ST_GeomFromText('POLYGON((33.50 45.20, 35.50 45.20, 35.50 45.30, 33.50 45.30, 33.50 45.20))', 4326));
    END IF;

    -- Колюченосник Сибторпа (Точечно)
    SELECT plant_id INTO pid FROM plants WHERE rus_name = 'Колюченосник Сибторпа';
    IF pid IS NOT NULL THEN
        INSERT INTO areas (plant_id, geom) VALUES (pid, ST_GeomFromText('POINT(33.60 45.10)', 4326));
    END IF;

    -- Бифора яйцевидная
    SELECT plant_id INTO pid FROM plants WHERE rus_name = 'Бифора яйцевидная';
    IF pid IS NOT NULL THEN
        INSERT INTO areas (plant_id, geom) VALUES (pid, ST_GeomFromText('POLYGON((34.50 44.80, 34.70 44.80, 34.70 44.90, 34.50 44.90, 34.50 44.80))', 4326));
    END IF;

    -- Подснежник складчатый
    SELECT plant_id INTO pid FROM plants WHERE rus_name = 'Подснежник складчатый';
    IF pid IS NOT NULL THEN
        INSERT INTO areas (plant_id, geom) VALUES (pid, ST_GeomFromText('POLYGON((34.00 44.50, 34.60 44.50, 34.60 44.70, 34.00 44.70, 34.00 44.50))', 4326));
    END IF;

    -- Лук тарханкутский (Тарханкут)
    SELECT plant_id INTO pid FROM plants WHERE rus_name = 'Лук тарханкутский';
    IF pid IS NOT NULL THEN
        INSERT INTO areas (plant_id, geom) VALUES (pid, ST_GeomFromText('POLYGON((32.50 45.30, 32.70 45.30, 32.70 45.45, 32.50 45.45, 32.50 45.30))', 4326));
    END IF;

    -- Ферула черноморская (Степной Крым)
    SELECT plant_id INTO pid FROM plants WHERE rus_name = 'Ферула черноморская';
    IF pid IS NOT NULL THEN
        INSERT INTO areas (plant_id, geom) VALUES (pid, ST_GeomFromText('POLYGON((33.00 45.00, 34.00 45.00, 34.00 45.50, 33.00 45.50, 33.00 45.00))', 4326));
    END IF;

    -- Заполнение для остальных видов без координат (генерация случайных точек в пределах Крыма)
    FOR r IN SELECT plant_id FROM plants WHERE plant_id NOT IN (SELECT plant_id FROM areas) LOOP
        -- Генерируем случайную точку в пределах Крыма для демонстрации
        -- Широта: 44.3 - 46.2, Долгота: 32.5 - 36.7
        INSERT INTO areas (plant_id, geom) 
        VALUES (r.plant_id, ST_SetSRID(ST_MakePoint(32.5 + random() * 4.2, 44.3 + random() * 1.9), 4326));
    END LOOP;

END $$;