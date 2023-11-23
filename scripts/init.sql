-- EGRESOFT DATASBE

-- CREACION DE LA BASE DE DATOS
CREATE DATABASE graduates;

-- Conexion al bytesbrains
\c graduates
-- Creación de dominios
CREATE DOMAIN tipo_telefono AS VARCHAR(10) CHECK (VALUE IN ('casa', 'celular', 'trabajo'));

CREATE DOMAIN tipo_archivo AS VARCHAR(10)
CHECK (VALUE IN ('pdf', 'doc', 'docx'));

-- Creación de tablas
-- TABLAS DE CARRERAS
CREATE TABLE carrera (
  id_carrera char(50),
  modalidad char(50),
  nombre varchar(50) NOT NULL,
  jefe_dpt CHAR(50) NOT NULL,
  cordinador CHAR(50) NOT NULL,
  evaluador VARCHAR(255) NOT NULL,
  CONSTRAINT pk_carrera PRIMARY KEY (id_carrera, modalidad),
  CONSTRAINT ck_carrera_modalidad
  CHECK (modalidad ~ '^[[:alpha:][:space:]]+$'),--Esta restriccion solo acepta Presencial o aDistancia
  CONSTRAINT ck_carrera_solo_alfabeto
  CHECK (nombre ~ '^[[:alpha:][:space:]]+$'
    AND jefe_dpt ~ '^[[:alpha:][:space:]]+$'
    AND cordinador ~ '^[[:alpha:][:space:]]+$'
    AND evaluador ~ '^[[:alpha:][:space:]]+$')--Esta rescriccion solo acepta caracteres Alfabeticos
);

CREATE TABLE especialidad (
  id_especialidad char(50) PRIMARY KEY,
  nombre char(50) NOT NULL,
  CONSTRAINT ck_especialidad_solo_alfabeto
  CHECK (nombre ~ '^[[:alpha:][:space:]]+$')--Esta rescriccion solo acepta caracteres Alfabeticos
);

CREATE TABLE plan_estudio (
  id_carrera char(50),
  modalidad char(50),
  id_especialidad char(50),
  periodo varchar(50) not null,
  CONSTRAINT pk_plan_estudio PRIMARY KEY (id_carrera, modalidad, id_especialidad),
  CONSTRAINT fk1_plan_estudio FOREIGN KEY (id_carrera, modalidad) 
  REFERENCES carrera (id_carrera, modalidad) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk2_plan_estudio FOREIGN KEY (id_especialidad) 
  REFERENCES especialidad (id_especialidad) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ck_plan_solo_alfabeto
  CHECK (modalidad ~ '^[[:alpha:][:space:]]+$'),--Esta restriccion solo acepta Presencial o aDistancia
  CONSTRAINT ck_plan_periodo 
  CHECK (periodo ~ '^[[:alpha:][:space:]]+[ -]+[[:alpha:][:space:]]+[ -]+[[:digit:][:space:]]{4}$')--solo acepta esta estructura mes-mes nnnn ejemplo Agosto-Diciembre 2023
);

--Tabla Usuario
CREATE TABLE usuarios (
  id_user char(50) PRIMARY KEY,
  tipo char(50) NOT NULL,
  correo VARCHAR(255),
 CONSTRAINT ck_usuarios_solo_alfabeto 
  CHECK (tipo ~ '^[[:alpha:][:space:]]+$'),--Esta rescriccion solo acepta tres opciones
  CONSTRAINT ck_correo
  CHECK (correo ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+(\.[a-zA-Z]{2,})+$')-- Restriccion que solo acepta correos
);

--Tabla administrativo
CREATE TABLE administrativo_basico (
  id_adm char(50) PRIMARY KEY,
  nombre varchar(255) NOT NULL,
  cargo CHAR(50) NOT NULL,
  fecha_nacimiento DATE NOT NULL,
  genero CHAR(50) NOT NULL,
  direccion json NOT NULL,
  correo json NOT NULL,
  telefono json NOT NULL,
  CONSTRAINT fk_administrativo FOREIGN KEY (id_adm)
  REFERENCES usuarios (id_user) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT ck_administrativo_solo_alfabeto
  CHECK (nombre ~ '^[[:alpha:][:space:]]+$'
  AND cargo ~ '^[[:alpha:][:space:]]+$'),--Esta rescriccion solo acepta caracteres Alfabeticos
  CONSTRAINT ck_administrativo_genero
  CHECK (valida_genero(genero))-- Restriccion para validar El genero
);

--Tabla empleador basico
CREATE TABLE empleador_basico (
  id_emp CHAR(50) PRIMARY KEY,
  nombre_empresa VARCHAR(255) NOT NULL,
  nombre_responsable VARCHAR(255) NOT NULL,
  cargo_responsable VARCHAR(255) NOT NULL,
  telefono json NOT NULL,
  correo json NOT NULL,
  direccion json NOT NULL,
  detalle TEXT,
  CONSTRAINT fk_empleador_basico FOREIGN KEY (id_emp)
  REFERENCES usuarios (id_user) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT ck_empleador_solo_alfabetico 
  CHECK (nombre_empresa ~ '^[[:alpha:][:space:]]+$'
  AND nombre_responsable ~ '^[[:alpha:][:space:]]+$'
  AND cargo_responsable ~ '^[[:alpha:][:space:]]+$')--Esta rescriccion solo acepta caracteres Alfabeticos
);

-- TABLAS DE EGRESADO
CREATE TABLE egresado_basico (
  id_egre char(50) PRIMARY KEY,
  id_carrera char(50),
  modalidad char(50),
  id_especialidad char(50),
  periodo_egreso CHAR(50) NOT NULL,
  nombre json NOT NULL,
  edad INT NOT NULL,
  curp VARCHAR(18) NOT NULL,
  sexo char(50) NOT NULL,
  telefono json NOT NULL,
  correo json NOT NULL,
  direccion json NOT NULL,
  CONSTRAINT fk1_egresado_basico FOREIGN KEY (id_egre)
  REFERENCES usuarios (id_user) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk2_egresado_basico FOREIGN KEY (id_carrera, modalidad) 
  REFERENCES carrera (id_carrera, modalidad) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk3_egresado_basico FOREIGN KEY (id_especialidad) 
  REFERENCES especialidad (id_especialidad) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ck_egresado_modalidad
  CHECK (modalidad ~ '^[[:alpha:][:space:]]+$'),--Esta restriccion solo acepta Presencial o Distancia
  CONSTRAINT ck_periodo_egreso 
  CHECK (periodo_egreso ~ '^[[:alpha:][:space:]]+[ -]+[[:alpha:][:space:]]+[ -]+[[:digit:][:space:]]{4}$'), --solo acepta esta estructura mes-mes nnnn ejemplo Agosto-Diciembre 2023
  CONSTRAINT ck_solo_existen_dos_generos 
  CHECK (valida_genero(sexo))-- Restriccion para validar El genero
);
--Tabla Experiencia laboral
CREATE TABLE experiencia_laboral (
  id_exp char(50) PRIMARY KEY,
  id_egre char(50),
  empresa VARCHAR(255) NOT NULL,
  cargo VARCHAR(255) NOT NULL,
  fecha_inicio DATE NOT NULL,
  estado CHAR(50) NOT NULL,
  fecha_fin DATE,
  correo json NOT NULL,
  telefono json NOT NULL,
  descripción TEXT NOT NULL,
  CONSTRAINT fk_experiencia_laboral FOREIGN KEY (id_egre) 
  REFERENCES egresado_basico (id_egre) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ck_exp_solo_alfabeto
  CHECK (empresa ~ '^[[:alpha:][:space:]]+$'
  AND cargo ~ '^[[:alpha:][:space:]]+$'),
  CONSTRAINT ck_exp_fecha 
  CHECK (EXTRACT(YEAR FROM fecha_inicio) >= 1950
  AND EXTRACT(YEAR FROM fecha_fin) >=1950),
  CONSTRAINT ck_exp_estado
  CHECK (estado ~ '^[[:alpha:][:space:]]+$')
);

-- Tabla de datos grandes, sirve para almacenar archivos como jpg, pdf, svg, png 
CREATE TABLE bigdat (
  id char(50),
  id_egre char(50),
  tipo char(50) NOT NULL,
  archivo BYTEA NOT NULL,
  CONSTRAINT pk_bigdat PRIMARY KEY (id, id_egre),
  CONSTRAINT fk_bigdat FOREIGN KEY (id_egre)
  REFERENCES egresado_basico (id_egre) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ck_bigdat_tipo 
  CHECK (tipo ~ '^[[:alpha:][:space:]]+$')
);
-- TABLAS DE ENCUESTA
CREATE TABLE encuesta (
  id_encuesta char(50),
  id_secc char(50),
  periodo_vigente char(50) not null,
  nombre_encuesta varchar(255) not null,
  nombre_secc varchar(255) not null,
  detalle TEXT,
  CONSTRAINT pk_encuesta PRIMARY KEY (id_encuesta, id_secc),
  CONSTRAINT ck_encuesta_periodo 
  CHECK (periodo_vigente ~ '^[[:alpha:][:space:]]+[ -]+[[:alpha:][:space:]]+[ -]+[[:digit:][:space:]]{4}$'),--solo acepta esta estructura mes-mes nnnn ejemplo Agosto-Diciembre 2023
  CONSTRAINT ck_encuesta_solo_alfabeto
  CHECK (nombre_encuesta ~ '^[[:alpha:][:digit:][:space:]]+$'
  AND nombre_secc ~ '^[[:alpha:][:digit:][:space:]]+$')
);

CREATE TABLE pregunta (
  id_pregunta char(50) PRIMARY KEY,
  id_encuesta char(50),
  id_secc char(50),
  tipo char(50) not null,
  pregunta json not null,
  CONSTRAINT fk1_pregunta FOREIGN KEY (id_encuesta, id_secc) 
  REFERENCES encuesta (id_encuesta, id_secc) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ck_pregunta_tipo 
  CHECK (tipo ~ '^[[:alpha:][:digit:][:space:]]+$')
  );

-- TABLA DEL PROCESO DE ENCUESTA
CREATE TABLE respuesta_Usuario (
  id_respuesta CHAR(50) PRIMARY KEY,
  id_user char(50),
  id_encuesta char(50),
  id_secc char(50),
  fecha_envio date not null,
  estado char(50) not null,
  fecha_respuesta date not null,
  borrador_progreso json NOT NULL,
  CONSTRAINT fk1_Ru FOREIGN KEY (id_user) 
  REFERENCES usuarios (id_user) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk2_Ru FOREIGN KEY (id_encuesta, id_secc) 
  REFERENCES encuesta (id_encuesta, id_secc) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ck_Ru_fecha 
  CHECK (EXTRACT(YEAR FROM fecha_envio) >= 1950
  AND EXTRACT(YEAR FROM fecha_respuesta) >=1950),
  CONSTRAINT ck_Ru_estado
  CHECK (estado ~ '^[[:alpha:][:space:]]+$')
);
--Tabla Respuesta detalladad
CREATE TABLE respuesta_detallada (
  id_respuesta char(50) PRIMARY KEY,
  id_pregunta char(50) not null,
  respuesta VARCHAR(50) not NULL,
  CONSTRAINT fk1_Rd FOREIGN KEY (id_respuesta) 
  REFERENCES respuesta_Usuario (id_respuesta) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk2_Rd FOREIGN KEY (id_pregunta) 
  REFERENCES pregunta (id_pregunta) ON DELETE CASCADE ON UPDATE CASCADE
);
--HISTORIAL
CREATE TABLE historial (
  id_historial serial PRIMARY KEY,
  usuario varchar(255) not null,
  hora timestamp not null,
  accion varchar (255)
);
CREATE OR REPLACE FUNCTION registrar_accion() RETURNS TRIGGER AS $$ BEGIN IF TG_OP = 'INSERT' THEN
INSERT INTO historial (usuario, hora, accion)
VALUES (
    user,
    now(),
    'ingreso datos en la tabla: ' || TG_ARGV [0]
  );
ELSIF TG_OP = 'UPDATE' THEN
INSERT INTO historial (usuario, hora, accion)
VALUES (
    user,
    now(),
    'actualizo datos en la tabla: ' || TG_ARGV [0]
  );
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER historial_trigger_carrera
AFTER
INSERT
  OR
UPDATE ON carrera FOR EACH ROW EXECUTE FUNCTION registrar_accion('carrera');
CREATE TRIGGER historial_trigger_especialidad
AFTER
INSERT
  OR
UPDATE ON especialidad FOR EACH ROW EXECUTE FUNCTION registrar_accion('especialidad');
CREATE TRIGGER historial_trigger_plan_estudio
AFTER
INSERT
  OR
UPDATE ON plan_estudio FOR EACH ROW EXECUTE FUNCTION registrar_accion('plan_estudio');
CREATE TRIGGER historial_trigger_usuarios
AFTER
INSERT
  OR
UPDATE ON usuarios FOR EACH ROW EXECUTE FUNCTION registrar_accion('usuarios');
CREATE TRIGGER historial_trigger_egresado_basico
AFTER
INSERT
  OR
UPDATE ON egresado_basico FOR EACH ROW EXECUTE FUNCTION registrar_accion('egresado_basico');
CREATE TRIGGER historial_trigger_empleador_basico
AFTER
INSERT
  OR
UPDATE ON empleador_basico FOR EACH ROW EXECUTE FUNCTION registrar_accion('empleador_basico');
CREATE TRIGGER historial_trigger_administrativo_basico
AFTER
INSERT
  OR
UPDATE ON administrativo_basico FOR EACH ROW EXECUTE FUNCTION registrar_accion('administrativo_basico');
CREATE TRIGGER historial_trigger_experiencia_laboral
AFTER
INSERT
  OR
UPDATE ON experiencia_laboral FOR EACH ROW EXECUTE FUNCTION registrar_accion('experiencia_laboral');
CREATE TRIGGER historial_trigger_bigdat
AFTER
INSERT
  OR
UPDATE ON bigdat FOR EACH ROW EXECUTE FUNCTION registrar_accion('bigdat');
CREATE TRIGGER historial_trigger_encuesta
AFTER
INSERT
  OR
UPDATE ON encuesta FOR EACH ROW EXECUTE FUNCTION registrar_accion('encuesta');
CREATE TRIGGER historial_trigger_pregunta
AFTER
INSERT
  OR
UPDATE ON pregunta FOR EACH ROW EXECUTE FUNCTION registrar_accion('pregunta');
CREATE TRIGGER historial_trigger_respuesta_Usuario
AFTER
INSERT
  OR
UPDATE ON respuesta_Usuario FOR EACH ROW EXECUTE FUNCTION registrar_accion('respuesta_Usuario');
CREATE TRIGGER historial_trigger_respuesta_detallada
AFTER
INSERT
  OR
UPDATE ON respuesta_detallada FOR EACH ROW EXECUTE FUNCTION registrar_accion('respuesta_detallada');
