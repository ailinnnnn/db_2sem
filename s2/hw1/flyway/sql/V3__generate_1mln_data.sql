SET search_path TO bakery_db;

INSERT INTO units (unit_name, description) VALUES ('г','граммы'),('мл','миллилитры'),('шт','штуки'),('кг','килограммы') ON CONFLICT DO NOTHING;

INSERT INTO bakeries (name, address, working_hours)
SELECT
  (ARRAY['Хлебный Дом','Свежее Утро','Пекарня №1','Буланжери','Зернышко','Тёплый Колос','Аромат','Французская Лавка','Домашний Хлеб','Ржаной Двор','Сдобная','Пекарь','Хлебница','Багет','Пышка'])[floor(random()*15)+1],
  (ARRAY['ул. Ленина','пр. Мира','ул. Советская','ул. Гагарина','ул. Кирова','ул. Пушкина','ул. Комсомольская','ул. Молодёжная','ул. Садовая','ул. Парковая','ул. Центральная','ул. Победы','ул. Калинина','ул. Горького','ул. Чехова'])[floor(random()*15)+1] || ', д. ' || (floor(random()*200)+1)::text,
  tsrange(current_date + time '08:00', current_date + time '22:00')
FROM generate_series(1, 15) i ON CONFLICT DO NOTHING;

INSERT INTO clients (phone_number, last_name, first_name, middle_name, birth_date, preferences)
SELECT
  '+7 (9' || (floor(random()*90)+10)::text || ') ' || (floor(random()*900)+100)::text || '-' || (floor(random()*90)+10)::text || '-' || (floor(random()*90)+10)::text,
  (ARRAY['Иванов','Петров','Сидоров','Козлов','Новиков','Морозов','Волков','Соколов','Кузнецов','Попов','Васильев','Смирнов','Михайлов','Фёдоров','Крылов','Максимов','Павлов','Алексеев','Титов','Лебедев'])[floor(random()*20)+1],
  (ARRAY['Александр','Дмитрий','Максим','Сергей','Андрей','Алексей','Артём','Илья','Кирилл','Михаил','Никита','Матвей','Роман','Егор','Арсений','Иван','Денис','Евгений','Владислав','Владимир'])[floor(random()*20)+1],
  (ARRAY['Александрович','Дмитриевич','Максимович','Сергеевич','Андреевич','Алексеевич','Артёмович','Ильич','Кириллович','Михайлович','Никитич','Матвеевич','Романович','Егорович','Арсеньевич','Иванович','Денисович','Евгеньевич','Владиславович','Владимирович'])[floor(random()*20)+1],
  (DATE '1960-01-01' + (floor(random()*20000))::int),
  jsonb_build_object('loyalty', floor(random()*3), 'discount', (random()*0.2)::numeric(4,2), 'newsletter', random()>0.5)
FROM generate_series(1, 250000) i ON CONFLICT DO NOTHING;

INSERT INTO couriers (phone_number, last_name, first_name, middle_name)
SELECT
  '+7 (9' || (floor(random()*90)+10)::text || ') ' || (floor(random()*900)+100)::text || '-' || (floor(random()*90)+10)::text || '-' || (floor(random()*90)+10)::text,
  (ARRAY['Иванов','Петров','Сидоров','Козлов','Новиков','Морозов','Волков','Соколов','Кузнецов','Попов'])[floor(random()*10)+1],
  (ARRAY['Алексей','Сергей','Дмитрий','Андрей','Максим','Иван','Артём','Роман','Егор','Никита'])[floor(random()*10)+1],
  (ARRAY['Алексеевич','Сергеевич','Дмитриевич','Андреевич','Максимович','Иванович','Артёмович','Романович','Егорович','Никитич'])[floor(random()*10)+1]
FROM generate_series(1, 150) i ON CONFLICT DO NOTHING;

INSERT INTO recipes (description, allergens)
SELECT
  (ARRAY['Классический','Домашний','Традиционный','Авторский','Постный','Сдобный','Бездрожжевой','Цельнозерновой','Французский','Итальянский'])[floor(random()*10)+1] || ' рецепт выпечки',
  ARRAY[(ARRAY['глютен','лактоза','орехи','яйца','соя','мёд','кунжут','горчица'])[floor(random()*8)+1]]
FROM generate_series(1, 25) i ON CONFLICT DO NOTHING;

INSERT INTO ingredients (name, calories, proteins, fats, carbohydrates)
SELECT
  (ARRAY['Мука пшеничная','Мука ржаная','Сахар-песок','Соль поваренная','Дрожжи прессованные','Молоко 3.2%','Масло сливочное 82%','Яйцо куриное','Вода очищенная','Разрыхлитель теста','Ванильный сахар','Корица молотая','Изюм светлый','Грецкий орех','Мёд цветочный','Сметана 20%','Творог 9%','Сыр твёрдый','Колбаса варёная','Капуста белокочанная','Дрожжи сухие','Масло подсолнечное','Кефир 1%','Сливки 10%','Яйцо перепелиное','Мука кукурузная','Крахмал картофельный','Лимонная кислота','Сода пищевая','Пряности'])[floor(random()*30)+1],
  random()*400, random()*25, random()*20, random()*60
FROM generate_series(1, 60) i ON CONFLICT DO NOTHING;

INSERT INTO baking_goods (name, size, unit_id, recipe_id, tags)
SELECT
  (ARRAY['Батон нарезной','Багет традиционный','Чиабатта','Круассан с миндалём','Булочка с корицей','Слойка яблочная','Пирожок с капустой','Пирожок с мясом','Ватрушка с творогом','Сочник','Рогалик','Калач московский','Лаваш тонкий','Фокачча с розмарином','Багет с семечками','Хлеб бородинский','Хлеб дарницкий','Булочка маковая','Слойка с вишней','Эклер шоколадный','Плюшка сахарная','Бублик','Сушка','Лепёшка','Хлебцы ржаные'])[floor(random()*25)+1],
  floor(random()*800+100),
  (floor(random()*4)+1)::int,
  (floor(random()*25)+1)::int,
  ARRAY[(ARRAY['свежее','хит','новинка','постное','безглютеновое','домашнее'])[floor(random()*6)+1]]
FROM generate_series(1, 600) i ON CONFLICT DO NOTHING;

INSERT INTO orders (client_id, bakery_id, type_of_order, metadata, price_range)
SELECT
  (floor(random() * 250000) + 1)::int,
  CASE WHEN random() < 0.7 THEN (floor(random() * 5) + 1) ELSE (floor(random() * 15) + 1) END,
  (ARRAY['Самовывоз','Доставка','Курьер'])[floor(random()*3)+1],
  jsonb_build_object('priority', floor(random()*5), 'source', (ARRAY['mobile','web','call','app'])[floor(random()*4)+1], 'promo', random()>0.8),
  numrange((floor(random()*200)+50)::numeric, (floor(random()*800)+300)::numeric)
FROM generate_series(1, 350000) i;

INSERT INTO order_baking_goods (order_id, baking_id, unit_id, quantity)
SELECT
  o.order_id,
  (floor(random()*600)+1)::int,
  (floor(random()*4)+1)::int,
  floor(random()*8+1)::numeric(10,2)
FROM orders o
CROSS JOIN LATERAL generate_series(1, CASE WHEN random()<0.5 THEN 1 WHEN random()<0.8 THEN 2 ELSE 3 END) gs
ON CONFLICT DO NOTHING;

UPDATE orders SET search_tsv = to_tsvector('russian', type_of_order || ' ' || COALESCE(metadata->>'source',''));
ANALYZE;
