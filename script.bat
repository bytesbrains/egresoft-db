@echo off
rem Ejecutar la instancia de Docker PostgreSQL
docker-compose up -d

rem Revisar los procesos de Docker
docker ps

set "container_name=PostgresCont"
set "sql_file=/docker-entrypoint-initdb.d/postgresql/scripts/init.sql"

rem Ejecutar el contenedor y ejecutar el script SQL en PostgreSQL
docker exec -it %container_name% psql -h localhost -U postgres -f %sql_file%
