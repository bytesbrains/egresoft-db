-- Crear una base de datos
CREATE DATABASE mi_bd;

-- Conectarse a la nueva base de datos
\c mi_bd

-- Crear una tabla
CREATE TABLE mi_tabla (
    id serial PRIMARY KEY,
    nombre VARCHAR (255),
    edad INT
);

-- Insertar un valor en la tabla
INSERT INTO mi_tabla (nombre, edad) VALUES ('Ejemplo', 30);