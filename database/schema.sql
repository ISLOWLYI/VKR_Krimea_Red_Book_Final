-- Включение расширения PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Очистка старых данных (для безопасного перезапуска)
DROP TABLE IF EXISTS images CASCADE;
DROP TABLE IF EXISTS areas CASCADE;
DROP TABLE IF EXISTS plants CASCADE;
DROP TABLE IF EXISTS cat_status CASCADE;
DROP VIEW IF EXISTS v_plants_full;
DROP TRIGGER IF EXISTS plants_search_update ON plants;
DROP FUNCTION IF EXISTS plants_search_update();

-- 1. Таблица статусов
CREATE TABLE cat_status (
    code INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    color VARCHAR(7) NOT NULL,
    description TEXT
);

-- 2. Таблица растений
CREATE TABLE plants (
    plant_id SERIAL PRIMARY KEY,
    rus_name VARCHAR(255) NOT NULL,
    lat_name VARCHAR(255) NOT NULL,
    family VARCHAR(100),
    status_code INTEGER REFERENCES cat_status(code),
    description TEXT,
    search_vector tsvector
);

-- Индексы
CREATE INDEX idx_plants_rus_name ON plants(rus_name);
CREATE INDEX idx_plants_lat_name ON plants(lat_name);
CREATE INDEX idx_plants_status ON plants(status_code);
CREATE INDEX idx_plants_search ON plants USING GIN(search_vector);

-- Триггер поиска
CREATE OR REPLACE FUNCTION plants_search_update() RETURNS trigger AS $$
BEGIN
    NEW.search_vector := to_tsvector('russian', coalesce(NEW.rus_name, '') || ' ' || coalesce(NEW.lat_name, ''));
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER plants_search_update
BEFORE INSERT OR UPDATE ON plants
FOR EACH ROW EXECUTE FUNCTION plants_search_update();

-- 3. Таблица ареалов (геометрия)
CREATE TABLE areas (
    area_id SERIAL PRIMARY KEY,
    plant_id INTEGER REFERENCES plants(plant_id) ON DELETE CASCADE,
    geom GEOMETRY(GEOMETRY, 4326) NOT NULL
);
CREATE INDEX idx_areas_geom ON areas USING GIST(geom);
CREATE INDEX idx_areas_plant ON areas(plant_id);

-- 4. Таблица изображений
CREATE TABLE images (
    image_id SERIAL PRIMARY KEY,
    plant_id INTEGER REFERENCES plants(plant_id) ON DELETE CASCADE,
    url VARCHAR(500),
    is_main BOOLEAN DEFAULT FALSE
);

-- Представление
CREATE OR REPLACE VIEW v_plants_full AS
SELECT 
    p.plant_id,
    p.rus_name,
    p.lat_name,
    p.family,
    p.status_code,
    cs.name as status_name,
    cs.color as status_color,
    p.description,
    (SELECT json_agg(row_to_json(a)) 
     FROM (SELECT ST_AsGeoJSON(geom)::json as geometry FROM areas WHERE plant_id = p.plant_id) a) as areas_geo,
    (SELECT url FROM images WHERE plant_id = p.plant_id AND is_main = TRUE LIMIT 1) as main_image
FROM plants p
JOIN cat_status cs ON p.status_code = cs.code;

-- === ЗАПОЛНЕНИЕ ДАННЫМИ ===

-- Статусы
INSERT INTO cat_status (code, name, color, description) VALUES
(0, 'Вероятно исчезнувшие', '#8B0000', 'Критическая угроза'),
(1, 'Под угрозой исчезновения', '#FF0000', 'Высокая угроза'),
(2, 'Сокращающиеся', '#FFA500', 'Угроза сокращения'),
(3, 'Редкие', '#FFFF00', 'Редкий вид'),
(4, 'Неопределённые', '#FFFACD', 'Мало данных'),
(5, 'Восстанавливающиеся', '#008000', 'Стабильно');

-- РАСТЕНИЯ И РЕАЛЬНЫЕ АРЕАЛЫ (Координаты приближены к реальным местам обитания)

-- 1. Пион крымский (Горы Ай-Петри, Бахчисарайский р-н)
-- Статус: 2 (Сокращающиеся) - Оранжевый
INSERT INTO plants (rus_name, lat_name, family, status_code, description) VALUES
('Пион крымский', 'Paeonia taurica', 'Пионовые', 2, 'Эндемик Крыма. Растет на горных лугах и опушках буковых лесов. Цветет в мае-июне.');

-- Полигон Ай-Петри (продолговатый вдоль горной гряды)
INSERT INTO areas (plant_id, geom) VALUES 
(1, ST_GeomFromText('POLYGON((
    34.05 44.48, 34.08 44.49, 34.12 44.50, 34.15 44.51, 34.18 44.52, 
    34.20 44.53, 34.22 44.52, 34.24 44.51, 34.25 44.49, 34.24 44.47, 
    34.22 44.46, 34.18 44.45, 34.14 44.44, 34.10 44.45, 34.06 44.46, 
    34.05 44.48
))', 4326));

-- 2. Ирис карликовый (Степи near Джанкой/Красноперекопск)
-- Статус: 3 (Редкие) - Желтый
INSERT INTO plants (rus_name, lat_name, family, status_code, description) VALUES
('Ирис карликовый', 'Iris pumila', 'Ирисовые', 3, 'Степное растение. Встречается на целинных участках степей Северного Крыма.');

-- Полигон степной зоны (большой, неправильной формы)
INSERT INTO areas (plant_id, geom) VALUES 
(2, ST_GeomFromText('POLYGON((
    33.60 45.80, 33.80 45.78, 34.00 45.75, 34.20 45.78, 34.40 45.82, 
    34.50 45.90, 34.45 46.00, 34.30 46.05, 34.10 46.08, 33.90 46.05, 
    33.70 46.00, 33.60 45.90, 33.60 45.80
))', 4326));

-- 3. Хохлатка мэотийская (Южный берег, Судак -> Новый Свет)
-- Статус: 1 (Под угрозой) - Красный
INSERT INTO plants (rus_name, lat_name, family, status_code, description) VALUES
('Хохлатка мэотийская', 'Corydalis maeotis', 'Маковые', 1, 'Узкий эндемик. Растет на скальных осыпях Южного берега в районе Судака.');

-- Полигон вдоль побережья (вытянутый)
INSERT INTO areas (plant_id, geom) VALUES 
(3, ST_GeomFromText('POLYGON((
    34.90 44.82, 34.95 44.83, 35.00 44.84, 35.05 44.85, 35.10 44.86, 
    35.12 44.88, 35.10 44.90, 35.05 44.91, 35.00 44.90, 34.95 44.89, 
    34.90 44.88, 34.88 44.85, 34.90 44.82
))', 4326));

-- 4. Рябчик горный (Массив Чатыр-Даг)
-- Статус: 2 (Сокращающиеся) - Оранжевый
INSERT INTO plants (rus_name, lat_name, family, status_code, description) VALUES
('Рябчик горный', 'Fritillaria montana', 'Лилейные', 2, 'Луковичный эфемероид. Произрастает на горных плато и склонах Чатыр-Дага.');

-- Полигон Чатыр-Даг (форма массива)
INSERT INTO areas (plant_id, geom) VALUES 
(4, ST_GeomFromText('POLYGON((
    34.30 44.72, 34.35 44.71, 34.40 44.72, 34.45 44.74, 34.48 44.78, 
    34.45 44.82, 34.40 44.84, 34.35 44.83, 34.30 44.80, 34.28 44.76, 
    34.30 44.72
))', 4326));