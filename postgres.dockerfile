FROM postgres:11
COPY create-testing-db.sql /docker-entrypoint-initdb.d/