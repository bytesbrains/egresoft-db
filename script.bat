@echo off
REM Ejecutar la instancia de Docker PostgreSQL
docker-compose up -d

REM Variables de entorno
set "container_name=PostgresCont"
set "sql_file=docker-entrypoint-initdb.d\postgresql\scripts\init.sql"

REM Definir el tiempo máximo de espera en segundos (60 segundos en este caso)
set "max_wait_seconds=60"

:LOOP
REM Función para verificar si el servidor PostgreSQL está listo
docker exec %container_name% pg_isready -h localhost -U postgres -q >nul 2>&1

IF %ERRORLEVEL% EQU 0 (
    REM El servidor PostgreSQL está listo
    goto :EXECUTE_SQL
) ELSE (
    SET /A max_wait_seconds-=1
    IF %max_wait_seconds% GTR 0 (
        REM Esperar 1 segundo y volver a verificar
        TIMEOUT /T 1 >nul
        goto :LOOP
    ) ELSE (
        REM El contenedor no se inicializó correctamente en 60 segundos
        echo El contenedor no se inicializó correctamente en 60 segundos.
        goto :EOF
    )
)

:EXECUTE_SQL
REM El contenedor se inicializó correctamente. Ejecutando el script SQL...
docker exec -it %container_name% psql -U postgres -f %sql_file%
