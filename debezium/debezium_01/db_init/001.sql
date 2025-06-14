DROP DATABASE IF EXISTS postgres; --https://www.w3schools.com/sql/sql_drop_db.asp

\connect oltp;


CREATE ROLE kafka_replica WITH superuser login PASSWORD 'kafka_replica';

CREATE SCHEMA debezium_info;
CREATE TABLE debezium_info.heartbeat (id serial PRIMARY KEY, date_load TIMESTAMPTZ DEFAULT NOW() );

CREATE TABLE public.fact_cost (
id_fact_cost serial NOT NULL PRIMARY KEY,
transaction_ts timestamp NOT NULL,
sum_cost NUMERIC(10,3) NOT NULL
);

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

CREATE PUBLICATION dbz_publication
FOR TABLE debezium_info.heartbeat,public.fact_cost;