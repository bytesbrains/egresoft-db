# Ejecutar la instancia de docker postgresql
docker-compose up -d

# Revisar los procesos de docker
docker ps

# variables de entorno
container_name="PostgresCont"
sql_file="/docker-entrypoint-initdb.d/postgresql/scripts/init.sql"

# Ejecutar el contenedor y ejecutar el script sql en postgresql
docker exec -it $container_name psql -h localhost -U postgres -f $sql_file