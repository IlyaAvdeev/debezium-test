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

Тестовые данные в БД заливает изначальный скрипт. 
Репликация не запустится пока не загрузить конфигурации (далее).
Загружаем конфигурации:
```shell
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @postgresql-debezium.json
```
```shell
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @pg_jdbc-sink.json
```

Проверяем, что данные реплицировались в БД `db_pg_oltp`.


