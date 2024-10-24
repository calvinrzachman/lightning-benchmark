#!/bin/bash

# Postgres init scripts: https://github.com/docker-library/docs/tree/master/postgres#initialization-scripts
psql -v ON_ERROR_STOP=0 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER loop WITH PASSWORD 'loop';
    CREATE DATABASE loop;
    GRANT ALL PRIVILEGES ON DATABASE loop TO loop;

    CREATE DATABASE paymentservice;
    CREATE DATABASE psdb_invoices;
    CREATE DATABASE psdb_channelgraph;
    CREATE DATABASE lnscores;
    GRANT ALL PRIVILEGES ON DATABASE paymentservice TO loop;
    GRANT ALL PRIVILEGES ON DATABASE psdb_invoices TO loop;
    GRANT ALL PRIVILEGES ON DATABASE psdb_channelgraph TO loop;
    GRANT ALL PRIVILEGES ON DATABASE lnscores TO loop;

    CREATE USER pool WITH PASSWORD 'pool';
    CREATE DATABASE pool;
    GRANT ALL PRIVILEGES ON DATABASE pool TO pool;
EOSQL
