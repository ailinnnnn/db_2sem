SET search_path TO bakery_db;

INSERT INTO units (unit_name, description) VALUES
  ('кг', 'килограммы'),
  ('л', 'литры')
ON CONFLICT (unit_name) DO NOTHING;

INSERT INTO recipes (description, allergens)
SELECT 'Бородинский хлеб', ARRAY['мука ржаная', 'солод', 'кориандр']
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE description = 'Бородинский хлеб');

INSERT INTO couriers (phone_number, last_name, first_name, middle_name)
SELECT '+7(999)000-00-01', 'Смирнов', 'Алексей', 'Петрович'
WHERE NOT EXISTS (SELECT 1 FROM couriers WHERE phone_number = '+7(999)000-00-01');
