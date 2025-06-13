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

CREATE PUBLICATION dbz_publication
FOR TABLE debezium_info.heartbeat,public.fact_cost;