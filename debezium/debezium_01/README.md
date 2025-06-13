Убиваем контейнеры которые были до:

```shell
docker rm $(docker ps -aq)
```

Собираем образ debezium/connect:

```shell
docker-compose build
```

По завершении сборки запускаем:

```shell
docker-compose up -d
```

Последующие запросы выполняем На бд `oltp`:

```
SELECT  
    name,
    setting,
    context
FROM pg_settings
WHERE name IN ('wal_level','max_wal_senders','max_replication_slots');
```
этим запросом подтверждаем установку логической репликации.

Наполняем таблицу тестовыми данными:
```
WITH insert_100 as(
select 
    generate_series(1, 100, 1) AS test, 
    timestamp '2021-01-01 00:00:00' +
       random() * (timestamp '2021-12-01 00:00:00' -
                   timestamp '2021-01-01 23:59:59') AS transaction_ts,
    random()*1000::NUMERIC(10,3) AS sum_cost)
INSERT  INTO public.fact_cost (transaction_ts, sum_cost)
SELECT transaction_ts,
        sum_cost
FROM insert_100;
```

Загружаем конфигурации:
```shell
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @postgresql-debezium.json
```
```shell
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @pg_jdbc-sink.json
```

Проверяем, что данные реплицировались в БД `db_pg_oltp`.


