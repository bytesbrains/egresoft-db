# Ejecutar la instancia de Docker PostgreSQL
docker-compose up -d

# Variables de entorno
container_name="PostgresCont"
sql_file="docker-entrypoint-initdb.d/postgresql/scripts/init.sql"

# Definir el tiempo máximo de espera en segundos (10 segundos en este caso)
max_wait_seconds=60

# Función para verificar si el servidor PostgreSQL está listo
is_postgresql_ready() {
    docker exec $container_name pg_isready -h localhost -U postgres -q
}

# Esperar a que el contenedor esté en funcionamiento y el servidor PostgreSQL esté listo
while [ $max_wait_seconds -gt 0 ]; do
    if is_postgresql_ready; then
        break
    fi

    max_wait_seconds=$((max_wait_seconds - 1))
    sleep 1
done

if [ $max_wait_seconds -eq 0 ]; then
    echo "El contenedor no se inicializó correctamente en 60 segundos."
else
    echo "El contenedor se inicializó correctamente. Ejecutando el script SQL..."
    docker exec -it $container_name psql -U postgres -f $sql_file
fi
