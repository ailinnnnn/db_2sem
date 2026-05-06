CREATE SCHEMA IF NOT EXISTS bakery_db;
SET search_path TO bakery_db;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_user') THEN CREATE ROLE app_user WITH LOGIN PASSWORD 'app_secret'; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'readonly_user') THEN CREATE ROLE readonly_user WITH LOGIN PASSWORD 'ro_secret'; END IF;
END $$;

CREATE TABLE units (unit_id SERIAL PRIMARY KEY, unit_name VARCHAR(20) NOT NULL UNIQUE, description VARCHAR(100));
CREATE TABLE bakeries (bakery_id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL, address VARCHAR(150) NOT NULL);
CREATE TABLE workers (worker_id SERIAL PRIMARY KEY, role VARCHAR(100) NOT NULL, phone_number VARCHAR(20), first_name VARCHAR(50), second_name VARCHAR(50), date_of_birth DATE, bakery_id INT REFERENCES bakeries(bakery_id) ON DELETE CASCADE);
CREATE TABLE appliances (appliance_id SERIAL PRIMARY KEY, bakery_id INT NOT NULL REFERENCES bakeries(bakery_id) ON DELETE CASCADE, name VARCHAR(50) NOT NULL, document VARCHAR(50));
CREATE TABLE recipes (recipe_id SERIAL PRIMARY KEY, description VARCHAR(200));
CREATE TABLE ingredients (ingredient_id SERIAL PRIMARY KEY, name VARCHAR(50), calories NUMERIC(10,2), proteins NUMERIC(10,2), fats NUMERIC(10,2), carbohydrates NUMERIC(10,2));
CREATE TABLE clients (client_id SERIAL PRIMARY KEY, phone_number VARCHAR(20), last_name VARCHAR(80), first_name VARCHAR(80), middle_name VARCHAR(80), birth_date DATE);
CREATE TABLE couriers (courier_id SERIAL PRIMARY KEY, phone_number VARCHAR(20), last_name VARCHAR(80), first_name VARCHAR(80), middle_name VARCHAR(80));
CREATE TABLE orders (order_id SERIAL PRIMARY KEY, client_id INT NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE, bakery_id INT NOT NULL REFERENCES bakeries(bakery_id) ON DELETE CASCADE, type_of_order VARCHAR(50));
CREATE TABLE baking_goods (baking_id SERIAL PRIMARY KEY, name VARCHAR(100), size NUMERIC(10,2) NOT NULL, unit_id INT NOT NULL REFERENCES units(unit_id), recipe_id INT NOT NULL REFERENCES recipes(recipe_id) ON DELETE CASCADE);
CREATE TABLE recipes_ingredients (recipe_id INT NOT NULL REFERENCES recipes(recipe_id) ON DELETE CASCADE, ingredient_id INT NOT NULL REFERENCES ingredients(ingredient_id) ON DELETE CASCADE, quantity NUMERIC(10,2) NOT NULL, unit_id INT NOT NULL REFERENCES units(unit_id), PRIMARY KEY (recipe_id, ingredient_id));
CREATE TABLE recipes_appliances (recipe_id INT NOT NULL REFERENCES recipes(recipe_id) ON DELETE CASCADE, appliance_id INT NOT NULL REFERENCES appliances(appliance_id) ON DELETE CASCADE, PRIMARY KEY (recipe_id, appliance_id));
CREATE TABLE order_baking_goods (order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE, baking_id INT NOT NULL REFERENCES baking_goods(baking_id) ON DELETE CASCADE, quantity NUMERIC(10,2) NOT NULL, unit_id INT NOT NULL REFERENCES units(unit_id), PRIMARY KEY (order_id, baking_id));
CREATE TABLE delivery_orders (delivery_id SERIAL PRIMARY KEY, order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE, courier_id INT NOT NULL REFERENCES couriers(courier_id) ON DELETE CASCADE, address VARCHAR(150));

GRANT USAGE ON SCHEMA bakery_db TO app_user, readonly_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA bakery_db TO app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA bakery_db TO app_user;
GRANT SELECT ON ALL TABLES IN SCHEMA bakery_db TO readonly_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA bakery_db GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA bakery_db GRANT USAGE, SELECT ON SEQUENCES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA bakery_db GRANT SELECT ON TABLES TO readonly_user;
