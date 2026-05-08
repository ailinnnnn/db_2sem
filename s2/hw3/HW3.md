запускаем контейнер и бд:
```
docker compose -f s2/hw1/docker/docker-compose.yml up -d
docker exec -it bakery_db psql -U admin -d bakery_db
```
## 1) GIN индексы
#### 1.GIN для массива категорий товаров
создаем индекс
```
CREATE INDEX idx_gin_baking_categories ON bakery_db.baking_goods USING gin(categories);
```
тестируем и выполняем запрос
```
EXPLAIN (ANALYZE, BUFFERS)
SELECT good_id, name, categories
FROM bakery_db.baking_goods
WHERE categories @> ARRAY['выпечка'];

SELECT good_id, name, categories
FROM bakery_db.baking_goods
WHERE categories @> ARRAY['выпечка'];
```
результат: отбирает товары, у которых в массиве `tags` содержится 'свежее', оператор `@>`проверяет вхождение элемента в массив.
![](attachment/21ee373b8ea6e3f5586ac7b3d977650b.png)
![](attachment/5ff9c88e548cba82e0ca420e53690e79.png)

#### 2.GIN для метаданных заказов

создаем индекс
```
CREATE INDEX idx_gin_orders_metadata ON bakery_db.orders USING gin(metadata);
```
тестируем и выполняем запрос
```
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, metadata
FROM bakery_db.orders
WHERE metadata @> '{"source": "mobile"}';

SELECT order_id, metadata
FROM bakery_db.orders
WHERE metadata @> '{"source": "mobile"}';
```
результат: пекарни, принимающие онлайн-оплату
![](attachment/0a3d16c4381a2df7e6e41459eed0bb98.png)
![](attachment/ae3a71c9c296c7faff54fa91d0592eb9.png)
#### 3.GIN для JSONB настроек клиентов

создаем индекс
```
CREATE INDEX idx_gin_clients_preferences ON bakery_db.clients USING gin(preferences);
```
тестируем и выполняем запрос
```
EXPLAIN (ANALYZE, BUFFERS)
SELECT client_id, last_name, preferences
FROM bakery_db.clients
WHERE preferences @> '{"newsletter": true}';

SELECT client_id, last_name, preferences
FROM bakery_db.clients
WHERE preferences @> '{"newsletter": true}';
```
результат: поиск клиентов с настройкой `newsletter`, у которых в JSONB-объекте `preferences` указано согласие на рассылку, оператор `@>` проверяет наличие пары ключ-значение внутри документа.
![](attachment/0f873c283aa9d9a8781c1f4c2ea9a132.png)
![](attachment/38199566a774b857403c6f5fd1a18139.png)

#### 4.GIN для массива аллергенов рецептов

создаем индекс
```
CREATE INDEX idx_gin_recipes_description ON bakery_db.recipes 
USING GIN (to_tsvector('russian', description));
```
тестируем и выполняем запрос
```
EXPLAIN (ANALYZE, BUFFERS)
SELECT recipe_id, title, description 
FROM bakery_db.recipes 
WHERE to_tsvector('russian', description) @@ to_tsquery('russian', 'дрожжи & тесто');

SELECT recipe_id, title, description 
FROM bakery_db.recipes 
WHERE to_tsvector('russian', description) @@ to_tsquery('russian', 'дрожжи & тесто');
```
результат: ищет рецепты, содержащие хотя бы один из указанных аллергенов, оператор `&&` находит пересечение массивов, что удобно для фильтрации по списку ограничений.
![](attachment/2e1ee8598c607be26c472a214155ab26.png)

![](attachment/c9f68a469d7e01e3ae09294357f8dce2.png)
#### 5.GIN для полнотекстового поиска по заказам

создаем индекс
```
CREATE INDEX idx_gin_orders_search ON bakery_db.orders USING gin(search_tsv);
```
тестируем и выполняем запрос
```
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, search_tsv
FROM bakery_db.orders
WHERE search_tsv @@ to_tsquery('russian', 'доставка & web');

SELECT order_id, search_tsv
FROM bakery_db.orders
WHERE search_tsv @@ to_tsquery('russian', 'доставка & web');
```
результат: ищет заказы, где тип оформления - доставка, а источник - веб-сайт, оператор `@@`сопоставляет `tsvector` с поисковым запросом `tsquery`, игнорируя окончания и регистр
![](attachment/4b5d73072277596e44958da65f0342e4.png)
![](attachment/1332ff5f509dfe4410de874468ec3878.png)
## 2)GIST индексы
#### 1.GiST для поиска ближайших пекарен (координаты)
создаем индекс
```
CREATE INDEX idx_gist_bakeries_coords ON bakery_db.bakeries USING gist(coordinates);
```
тестируем и выполняем запрос
```
EXPLAIN (ANALYZE, BUFFERS)
SELECT bakery_id, name, coordinates
FROM bakery_db.bakeries
WHERE coordinates IS NOT NULL
ORDER BY coordinates <-> point(55.7558, 37.6173)
LIMIT 10;

SELECT bakery_id, name, coordinates
FROM bakery_db.bakeries
WHERE coordinates IS NOT NULL
ORDER BY coordinates <-> point(55.7558, 37.6173)
LIMIT 10;
```
результат: находит 5 ближайших пекарен к указанной точке, оператор `<->` вычисляет расстояние на лету, а GiST индекс позволяет не перебирать все точки, а сразу найти ближайших соседей.
![](attachment/2941d2f6bd05dec2eef538fa152f9465.png)
![](attachment/51b8df8c1c9d1cbaa1b54cc0755c4c5e.png)

#### 2.GiST для поиска клиентов в радиусе доставки (геометрия)
создаем индекс
```
CREATE INDEX idx_gist_bakeries_coords ON bakery_db.bakeries USING gist(coordinates);
```
тестируем и выполняем запрос
```
EXPLAIN (ANALYZE, BUFFERS)
SELECT bakery_id, name, coordinates
FROM bakery_db.bakeries
WHERE coordinates IS NOT NULL
ORDER BY coordinates <-> point(55.7558, 37.6173)
LIMIT 10;

SELECT bakery_id, name, coordinates
FROM bakery_db.bakeries
WHERE coordinates IS NOT NULL
ORDER BY coordinates <-> point(55.7558, 37.6173)
LIMIT 10;
```
результат: находит 10 ближайших пекарен к указанной точке, оператор `<->` вычисляет расстояние на лету, а GiST индекс позволяет не перебирать все точки, а сразу найти ближайших соседей.
![](attachment/fa6cf80face2768193c931020f2e71c7.png)
![](attachment/dd495e3e4f740e057244b31d6b735d08.png)

#### 3.GiST для поиска пересекающихся акций (Диапазоны дат)
создаем индекс
```
CREATE INDEX idx_gist_bakeries_coords ON bakery_db.bakeries USING gist(coordinates);
```
тестируем и выполняем запрос
```
EXPLAIN (ANALYZE, BUFFERS)
SELECT bakery_id, name, working_hours 
FROM bakery_db.bakeries 
WHERE tsrange('2026-05-08 12:00:00', '2026-05-08 13:00:00') <@ working_hours;

SELECT bakery_id, name, working_hours 
FROM bakery_db.bakeries 
WHERE tsrange('2026-05-08 12:00:00', '2026-05-08 13:00:00') <@ working_hours;
```
результат: находит 5 ближайших пекарен к указанной точке, оператор `<->` вычисляет расстояние на лету, а GiST индекс позволяет не перебирать все точки, а сразу найти ближайших соседей.
![](attachment/02ffd8ecd4eb4d6c14d7de92bb53017d.png)
![](attachment/b8ca68bcc06e2571942c30862165b293.png)

#### 4.GiST для клиентов в зоне доставки (геометрия круга)
создаем индекс
```
CREATE INDEX idx_gist_clients_location ON bakery_db.clients USING gist(location);
```
тестируем и выполняем запрос
```
EXPLAIN (ANALYZE, BUFFERS)
SELECT client_id, last_name, location
FROM bakery_db.clients
WHERE location IS NOT NULL
  AND location <@ circle(point(55.7512, 37.6184), 5000);

SELECT client_id, last_name, location
FROM bakery_db.clients
WHERE location IS NOT NULL
  AND location <@ circle(point(55.7512, 37.6184), 5000);
```
результат: ищет клиентов, находящихся в радиусе 5 км от центра (круг с центром в Москве и радиусом 5000 метров), позволяет делать выборку для SMS-рассылок по географии.
![](attachment/c915bf0e0d6fb216c3ca18342fbd297e.png)
![](attachment/46c76a5eb84db07e942ae39123001c2b.png)

#### 5.GiST для поиска ближайших пекарен (координаты)
создаем индекс
```
CREATE INDEX idx_gist_bakeries_coords ON bakery_db.bakeries USING gist(coordinates);
```
тестируем и выполняем запрос
```
EXPLAIN (ANALYZE, BUFFERS)
SELECT bakery_id, name, coordinates
FROM bakery_db.bakeries
WHERE coordinates IS NOT NULL
ORDER BY coordinates <-> point(55.7558, 37.6173)
LIMIT 10;

SELECT bakery_id, name, coordinates
FROM bakery_db.bakeries
WHERE coordinates IS NOT NULL
ORDER BY coordinates <-> point(55.7558, 37.6173)
LIMIT 10;
```
результат: находит 5 ближайших пекарен к указанной точке, оператор `<->` вычисляет расстояние на лету, а GiST индекс позволяет не перебирать все точки, а сразу найти ближайших соседей.
![](attachment/ff3ce6d4839fde4979c23e160bf84f65.png)
![](attachment/0a3213e3a7be4e1bd146bcd23f891004.png)
вывод: GIST выполнило в 4 раз быстрее чем GIN индекс








## 3) JOIN запросы

#### 1. Hash Join: Клиенты и их заказы
```
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    c.client_id,
    f.created_at,
    f.rating
FROM bakery_db.clients c
INNER JOIN bakery_db.customer_feedback f
ON f.client_id = c.client_id
LIMIT 100;

SELECT
    c.client_id,
    f.created_at,
    f.rating
FROM bakery_db.clients c
INNER JOIN bakery_db.customer_feedback f
ON f.client_id = c.client_id
LIMIT 100;
```
результат: соединение клиентов с их заказами через Hash Join, PostgreSQL строит хеш-таблицу для меньшей таблицы и сканирует вторую
![](attachment/49ccdcb2c8945dd941d8b204ab5de2b4.png)
![](attachment/7167e104ed1eee421d4ed8c12dc6be40.png)

#### 2. Nested Loop: Заказы клиентов с индексами
```
CREATE INDEX idx_clients_client_id ON bakery_db.clients(client_id);
CREATE INDEX idx_orders_client_id ON bakery_db.orders(client_id);

ANALYZE bakery_db.clients;
ANALYZE bakery_db.orders;

EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    c.last_name,
    c.first_name,
    o.order_id,
    o.type_of_order
FROM bakery_db.clients c
JOIN bakery_db.orders o ON c.client_id = o.client_id
WHERE c.client_id < 1000
ORDER BY c.client_id;

SELECT 
    c.last_name,
    c.first_name,
    o.order_id,
    o.type_of_order
FROM bakery_db.clients c
JOIN bakery_db.orders o ON c.client_id = o.client_id
WHERE c.client_id < 1000
ORDER BY c.client_id;
```
результат: Nested Loop с индексом, для каждого клиента из внешней таблицы делается быстрый поиск по индексу во внутренней
![](attachment/d3fbfc4761dca5c06f1d1192c065297f.png)![](attachment/c926707b2bd29b4de4070a1ef4281904.png)

#### 3. Merge Join: Клиенты и их отзывы
```
CREATE INDEX idx_orders_client_id ON bakery_db.orders(client_id);
CREATE INDEX idx_clients_client_id ON bakery_db.clients(client_id);

ANALYZE bakery_db.orders;
ANALYZE bakery_db.clients;

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    o.order_id,
    o.type_of_order,
    c.last_name,
    c.first_name,
    c.phone_number
FROM bakery_db.orders o
JOIN bakery_db.clients c ON o.client_id = c.client_id
ORDER BY o.client_id, o.order_id
LIMIT 1000;

SELECT
    o.order_id,
    o.type_of_order,
    c.last_name,
    c.first_name,
    c.phone_number
FROM bakery_db.orders o
JOIN bakery_db.clients c ON o.client_id = c.client_id
ORDER BY o.client_id, o.order_id
LIMIT 1000;
```
результат: объединяет заказы с клиентами через Merge Join. Обе таблицы отсортированы по `client_id` через B-tree индексы.
![](attachment/fd8e1236d718b72b9e0c32af6fe73bfb.png)
![](attachment/d077b20c3764996f26d36497d79bf3f0.png)
#### 4. Multiple JOIN: Детализация заказов
```
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    o.order_id,
    c.last_name || ' ' || c.first_name AS client_name,
    bg.name AS product_name,
    obg.quantity,
    u.unit_name
FROM bakery_db.orders o
JOIN bakery_db.clients c ON o.client_id = c.client_id
JOIN bakery_db.order_baking_goods obg ON o.order_id = obg.order_id
JOIN bakery_db.baking_goods bg ON obg.baking_id = bg.baking_id
JOIN bakery_db.units u ON obg.unit_id = u.unit_id
WHERE o.order_id BETWEEN 1 AND 100
ORDER BY o.order_id;

SELECT 
    o.order_id,
    c.last_name || ' ' || c.first_name AS client_name,
    bg.name AS product_name,
    obg.quantity,
    u.unit_name
FROM bakery_db.orders o
JOIN bakery_db.clients c ON o.client_id = c.client_id
JOIN bakery_db.order_baking_goods obg ON o.order_id = obg.order_id
JOIN bakery_db.baking_goods bg ON obg.baking_id = bg.baking_id
JOIN bakery_db.units u ON obg.unit_id = u.unit_id
WHERE o.order_id BETWEEN 1 AND 100
ORDER BY o.order_id;
```
результат: соединение 4 таблиц для полной детализации заказов с товарами и клиентами.
![](attachment/8b5d0de8619793245e1875d9e9866954.png)
![](attachment/8c2b21fc2f7bfedb0092c326058aecba.png)

#### 5. LEFT JOIN: Все заказы с доставкой
```
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    o.order_id,
    o.type_of_order,
    d.address AS delivery_address,
    cou.last_name AS courier_last_name
FROM bakery_db.orders o
LEFT JOIN bakery_db.delivery_orders d ON o.order_id = d.order_id
LEFT JOIN bakery_db.couriers cou ON d.courier_id = cou.courier_id
WHERE o.type_of_order = 'Доставка'
ORDER BY o.order_id;

SELECT 
    o.order_id,
    o.type_of_order,
    d.address AS delivery_address,
    cou.last_name AS courier_last_name
FROM bakery_db.orders o
LEFT JOIN bakery_db.delivery_orders d ON o.order_id = d.order_id
LEFT JOIN bakery_db.couriers cou ON d.courier_id = cou.courier_id
WHERE o.type_of_order = 'Доставка'
ORDER BY o.order_id;
```
результат: LEFT JOIN показывает все заказы с доставкой, даже если курьер ещё не назначен.
![](attachment/eca3c91a8ca145e751c8d14dca47c3e3.png)
![](attachment/86a7d2cd1a6cf10c2860294ab11c0788.png)
#### 6. GRAFANA
![](attachment/1e8300379e6542a87ff8e24b820f774e.png)![](attachment/137e39d89fe5fa2574e6754437d8caf8.png)
