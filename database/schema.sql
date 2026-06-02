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
    region_ids TEXT[], -- Массив регионов (например, '{mountains,yubk}')
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

-- 4. Таблица изображений (поддержка 0-4 картинок на растение)
CREATE TABLE images (
    image_id SERIAL PRIMARY KEY,
    plant_id INTEGER REFERENCES plants(plant_id) ON DELETE CASCADE,
    url VARCHAR(500),
    is_main BOOLEAN DEFAULT FALSE
);

-- Представление (ОБНОВЛЕНО: возвращает JSON-массив всех изображений)
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
    p.region_ids,
    
    -- Гео-данные в формате GeoJSON
    (SELECT json_agg(row_to_json(a))
     FROM (SELECT ST_AsGeoJSON(geom)::json as geometry FROM areas WHERE plant_id = p.plant_id) a) as areas_geo,
    
    -- НОВОЕ: Массив всех изображений. Сортировка ORDER BY is_main DESC гарантирует, 
    -- что главное изображение (is_main=TRUE) будет первым в массиве (индекс 0).
    -- Если картинок нет, вернется NULL.
    (SELECT json_agg(json_build_object('url', url, 'is_main', is_main) ORDER BY is_main DESC) 
     FROM images WHERE plant_id = p.plant_id) as images

FROM plants p
LEFT JOIN cat_status cs ON p.status_code = cs.code;

-- === ЗАПОЛНЕНИЕ ДАННЫМИ ===

-- Статусы
INSERT INTO cat_status (code, name, color, description) VALUES
(0, 'Вероятно исчезнувшие', '#8B0000', 'Критическая угроза'),
(1, 'Под угрозой исчезновения', '#FF0000', 'Высокая угроза'),
(2, 'Сокращающиеся', '#FFA500', 'Угроза сокращения'),
(3, 'Редкие', '#FFFF00', 'Редкий вид'),
(4, 'Неопределённые', '#FFFACD', 'Мало данных'),
(5, 'Восстанавливающиеся', '#008000', 'Стабильно');