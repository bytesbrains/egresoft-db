-- EGRESOFT DATASBE

-- CREACION DE LA BASE DE DATOS
CREATE DATABASE graduates;

-- Conexion al bytesbrains
\c graduates
-- Creación de dominios
CREATE DOMAIN tipo_telefono AS VARCHAR(10) CHECK (VALUE IN ('casa', 'celular', 'trabajo'));

CREATE DOMAIN tipo_archivo AS VARCHAR(10)
CHECK (VALUE IN ('pdf', 'doc', 'docx'));

--Funcion para validar genero
CREATE OR REPLACE FUNCTION valida_genero(sexo CHAR(50))
RETURNS BOOLEAN AS $$
BEGIN
    IF sexo IN ('Hombre', 'Mujer', 'Indefinido') THEN
        RETURN TRUE;
    ELSE
        RAISE EXCEPTION 'Solo existen dos géneros: Hombre y Mujer';
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Creación de tablas
-- TABLAS DE CARRERAS
CREATE TABLE carrera (
  id_carrera varchar(50),
  modalidad varchar(50),
  nombre varchar(50) NOT NULL,
  jefe_dpt varchar(50) NOT NULL,
  cordinador varchar(50) NOT NULL,
  evaluador VARCHAR(255) NOT NULL,
  CONSTRAINT pk_carrera PRIMARY KEY (id_carrera, modalidad),
  CONSTRAINT ck_carrera_id_carrera
  CHECK (id_carrera ~ '^[A-Z]{4}[-]20[0-9]{2}[-]2[0-9]{2}$'),--Esta restriccion solo permite el siguiente formato ABCD-2034-267
  CONSTRAINT ck_carrera_modalidad
  CHECK (modalidad in ('presencial', 'distancia')),--Esta restriccion solo acepta Presencial o aDistancia
  CONSTRAINT ck_carrera_solo_alfabeto
  CHECK (nombre ~ '^[[:alpha:][:space:]]+$'
    AND jefe_dpt ~ '^[[:alpha:][:space:]]+$'
    AND cordinador ~ '^[[:alpha:][:space:]]+$'
    AND evaluador ~ '^[[:alpha:][:space:]]+$')--Esta rescriccion solo acepta caracteres Alfabeticos
);

CREATE TABLE especialidad (
  id_especialidad varchar(50) PRIMARY KEY,
  nombre varchar(50) NOT NULL,
  CONSTRAINT ck_especialidad_solo_alfabeto
  CHECK (nombre ~ '^[[:alpha:][:space:]]+$')--Esta rescriccion solo acepta caracteres Alfabeticos
);

CREATE TABLE plan_estudio (
  id_carrera varchar(50),
  modalidad varchar(50),
  id_especialidad varchar(50),
  periodo varchar(50) not null,
  CONSTRAINT pk_plan_estudio PRIMARY KEY (id_carrera, modalidad, id_especialidad),
  CONSTRAINT fk1_plan_estudio FOREIGN KEY (id_carrera, modalidad) 
  REFERENCES carrera (id_carrera, modalidad) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk2_plan_estudio FOREIGN KEY (id_especialidad) 
  REFERENCES especialidad (id_especialidad) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ck_plan_id_carrera
  CHECK (id_carrera ~ '^[A-Z]{4}[-]20[0-9]{2}[-]2[0-9]{2}$'),--Esta restriccion solo permite el siguiente formato ABCD-2034-267
  CONSTRAINT ck_plan_solo_alfabeto
  CHECK (modalidad in ('presencial', 'distancia')),--Esta restriccion solo acepta Presencial o aDistancia
  CONSTRAINT ck_plan_periodo 
  CHECK (periodo ~ '^[a-zA-Z]+[ -]+[a-zA-Z]+[ -]+[0-9]{4}$')--solo acepta esta estructura mes-mes nnnn ejemplo Agosto-Diciembre 2023
);

--Tabla Usuario
CREATE TABLE usuarios (
  id_user varchar(50) PRIMARY KEY,
  tipo varchar(50) NOT NULL,
  correo VARCHAR(255),
  CONSTRAINT ck_usuarios_solo_alfabeto 
  CHECK (tipo in ('graduate', 'employer', 'admin')),--Esta rescriccion solo acepta tres opciones
  CONSTRAINT ck_correo
  CHECK (correo ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')-- Restriccion que solo acepta correos
);

--Tabla administrativo
CREATE TABLE administrativo_basico (
  id_adm varchar(50) PRIMARY KEY,
  nombre varchar(255) NOT NULL,
  cargo varchar(50) NOT NULL,
  fecha_nacimiento DATE NOT NULL,
  genero varchar(50) NOT NULL,
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
  id_emp varchar(50) PRIMARY KEY,
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
  id_egre varchar(50) PRIMARY KEY,
  id_carrera varchar(50),
  modalidad varchar(50),
  id_especialidad varchar(50),
  periodo_egreso varchar(50) NOT NULL,
  nombre json NOT NULL,
  edad varchar(50) NOT NULL,
  curp VARCHAR(18) NOT NULL,
  sexo varchar(50) NOT NULL,
  telefono json NOT NULL,
  correo json NOT NULL,
  direccion json NOT NULL,
  CONSTRAINT fk1_egresado_basico FOREIGN KEY (id_egre)
  REFERENCES usuarios (id_user) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk2_egresado_basico FOREIGN KEY (id_carrera, modalidad) 
  REFERENCES carrera (id_carrera, modalidad) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk3_egresado_basico FOREIGN KEY (id_especialidad) 
  REFERENCES especialidad (id_especialidad) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ck_egresado_id_carrera
  CHECK (id_carrera ~ '^[A-Z]{4}[-]20[0-9]{2}[-]2[0-9]{2}$'),--Esta restriccion solo permite el siguiente formato ABCD-2034-267
  CONSTRAINT ck_egresado_modalidad
  CHECK (modalidad in ('presencial', 'distansia')),--Esta restriccion solo acepta Presencial o Distancia
  CONSTRAINT ck_periodo_egreso 
  CHECK (periodo_egreso ~ '^[a-zA-Z]+[ -]+[a-zA-Z]+[ -]+[0-9]{4}$'), --solo acepta esta estructura mes-mes nnnn ejemplo Agosto-Diciembre 2023
  CONSTRAINT ck_solo_existen_dos_generos 
  CHECK (valida_genero(sexo)),-- Restriccion para validar El genero
  CONSTRAINT ck_egresado_solo_numeros 
  CHECK (edad ~ '^[0-9]+$')-- Restriccion que solo acepta numeros
);
--Tabla Experiencia laboral
CREATE TABLE experiencia_laboral (
  id_exp varchar(50) PRIMARY KEY,
  id_egre varchar(50),
  empresa VARCHAR(255) NOT NULL,
  cargo VARCHAR(255) NOT NULL,
  fecha_inicio DATE NOT NULL,
  estado varchar(50) NOT NULL,
  fecha_fin DATE,
  correo json NOT NULL,
  telefono json NOT NULL,
  descripción TEXT NOT NULL,
  CONSTRAINT fk_experiencia_laboral FOREIGN KEY (id_egre) 
  REFERENCES egresado_basico (id_egre) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ck_id_exp 
  CHECK (id_exp ~ '^EXP[0-9]+$')
  CONSTRAINT ck_exp_solo_alfabeto
  CHECK (empresa ~ '^[[:alpha:][:space:]]+$'
  AND cargo ~ '^[[:alpha:][:space:]]+$'),
  CONSTRAINT ck_exp_fecha 
  CHECK (EXTRACT(YEAR FROM fecha_inicio) >= 1950
  AND EXTRACT(YEAR FROM fecha_fin) >=1950),-- Esta restriccion solo acepta fechas a partir del año 1950
  CONSTRAINT ck_exp_estado
  CHECK (estado in ('activo', 'finalizado'))--Esta restriccion solo acepta dos opciones
);
-- Tabla de datos grandes, sirve para almacenar archivos como jpg, pdf, svg, png 
CREATE TABLE bigdat (
  id varchar(50),
  id_egre varchar(50),
  tipo varchar(50) NOT NULL,
  archivo BYTEA NOT NULL,
  CONSTRAINT pk_curriculum PRIMARY KEY (id, id_egre),
  CONSTRAINT fk_curriculum FOREIGN KEY (id_egre)
  REFERENCES egresado_basico (id_egre) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ck_bigdat_id
  CHECK (id ~ '^(BGD)[0-9]+$'),
  CONSTRAINT ck_bigdat_tipo 
  CHECK (tipo in ('jpg', 'pdf', 'svg', 'png'))
);
-- TABLAS DE ENCUESTA
CREATE TABLE encuesta (
  id_encuesta varchar(50),
  id_secc varchar(50),
  periodo_vigente varchar(50) not null,
  nombre_encuesta varchar(255) not null,
  nombre_secc varchar(255) not null,
  detalle TEXT,
  CONSTRAINT pk_encuesta PRIMARY KEY (id_encuesta, id_secc),
  CONSTRAINT ck_pk_encuesta 
  CHECK (id_encuesta ~ '^(ENC)[0-9]+$'
  AND id_secc ~ '^(SEC)[0-9]+$'),
  CONSTRAINT ck_encuesta_periodo 
  CHECK (periodo_vigente ~ '^[a-zA-Z]+[ -]+[a-zA-Z]+[ -]+[0-9]{4}$'),--solo acepta esta estructura mes-mes nnnn ejemplo Agosto-Diciembre 2023
  CONSTRAINT ck_encuesta_solo_alfanumerico
  CHECK (nombre_encuesta ~ '^[[:alpha:][:alnum:][:space:]]+$'
  AND nombre_secc ~ '^[[:alpha:][:alnum:][:space:]]+$')
);

CREATE TABLE pregunta (
  id_pregunta varchar(50) PRIMARY KEY,
  id_encuesta varchar(50),
  id_secc varchar(50),
  tipo varchar(50) not null,
  pregunta json not null,
  CONSTRAINT fk1_pregunta FOREIGN KEY (id_encuesta, id_secc) 
  REFERENCES encuesta (id_encuesta, id_secc) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ck_pregunta_id
  CHECK (id_pregunta ~ '^(P)[A-Z]{2}[0-9]+$'
  and id_encuesta ~ '^(ENC)[0-9]+$'
  AND id_secc ~ '^(SEC)[0-9]+$'),
  CONSTRAINT ck_pregunta_tipo 
  CHECK (tipo ~ '^[[:alpha:][:space:]]+$')
  );
-- TABLA DEL PROCESO DE ENCUESTA
CREATE TABLE respuesta_Usuario (
  id_respuesta varchar(50) PRIMARY KEY,
  id_user varchar(50),
  id_encuesta varchar(50),
  id_secc varchar(50),
  fecha_envio date not null,
  estado varchar(50) not null,
  fecha_respuesta date,
  borrador_progreso json NOT NULL,
  CONSTRAINT fk1_Ru FOREIGN KEY (id_user) 
  REFERENCES usuarios (id_user) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk2_Ru FOREIGN KEY (id_encuesta, id_secc) 
  REFERENCES encuesta (id_encuesta, id_secc) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ck_Ru_id
  CHECK (id_respuesta ~ '^(RSP)[0-9]+$'
  AND id_encuesta ~ '^(ENC)[0-9]+$'
  AND id_secc ~ '^(SEC)[0-9]+$'),
  CONSTRAINT ck_Ru_fecha 
  CHECK (EXTRACT(YEAR FROM fecha_envio) >= 1950
  AND EXTRACT(YEAR FROM fecha_respuesta) >=1950),
  CONSTRAINT ck_Ru_estado
  CHECK (estado in ('enviado', 'en progreso', 'contestando', 'finalizado'))
);
--Tabla Respuesta detalladad
CREATE TABLE respuesta_detallada (
  id_respuesta varchar(50) PRIMARY KEY,
  id_pregunta varchar(50) not null,
  respuesta VARCHAR(50) not NULL,
  CONSTRAINT fk1_Rd FOREIGN KEY (id_respuesta) 
  REFERENCES respuesta_Usuario (id_respuesta) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk2_Rd FOREIGN KEY (id_pregunta) 
  REFERENCES pregunta (id_pregunta) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT ck_Rd_id 
  CHECK (id_respuesta ~ '^(RSP)[0-9]+$'
  AND id_pregunta ~ '^(P)[A-Z]{2}[0-9]+$')
);
--HISTORIAL
CREATE TABLE historial (
  id_historial serial PRIMARY KEY,
  usuario varchar(255) not null,
  hora timestamp not null,
  accion varchar (255)
);
--Funcion para registrar acciones en las tablas
CREATE OR REPLACE FUNCTION registrar_accion()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO historial (usuario, hora, accion)
    VALUES (
      user,
      now(),
      'ingreso datos en la tabla: ' || TG_ARGV[0]
    );
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO historial (usuario, hora, accion)
    VALUES (
      user,
      now(),
      'actualizo datos en la tabla: ' || TG_ARGV[0]
    );
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO historial (usuario, hora, accion)
    VALUES (
      user,
      now(),
      'borro datos en la tabla: ' || TG_ARGV[0]
    );

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--Funcion para registrar cambio de rol
CREATE OR REPLACE FUNCTION registrar_cambio_rol()
RETURNS TRIGGER AS $$
DECLARE
  old_role_name TEXT;
  new_role_name TEXT;
  changing_user TEXT;
  target_user TEXT;
BEGIN
  SELECT rolname INTO old_role_name FROM pg_roles WHERE oid = current_setting('role')::oid;
  SELECT rolname INTO new_role_name FROM pg_roles WHERE oid = SESSION_USER::oid;
  changing_user := SESSION_USER::TEXT;
  target_user := NEW.target_user::TEXT;
  IF TG_OP = 'SET ROLE' THEN
    INSERT INTO historial (usuario, hora, accion)
    VALUES (
      changing_user,
      now(),
      'cambio de rol desde ' || old_role_name || ' a ' || new_role_name || ' para ' || target_user
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Funcion para registrar sesiones
CREATE OR REPLACE FUNCTION registrar_session()
RETURNS TRIGGER AS $$
DECLARE
  changing_user TEXT;
  target_user TEXT;
BEGIN
  changing_user := SESSION_USER::TEXT;
  target_user := NEW.target_user::TEXT;
IF TG_OP = 'SET SESSION AUTHORIZATION' THEN
    INSERT INTO historial (usuario, hora, accion)
    VALUES (
      changing_user,
      now(),
      'cambio de autorización de sesión para ' || target_user
    );

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para INSERT en carrera
CREATE TRIGGER historial_trigger_insert_carrera
AFTER INSERT ON carrera
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('carrera');

-- Trigger para UPDATE en carrera
CREATE TRIGGER historial_trigger_update_carrera
AFTER UPDATE ON carrera
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('carrera');

-- Trigger para DELETE en carrera
CREATE TRIGGER historial_trigger_delete_carrera
AFTER DELETE ON carrera
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('carrera');

-- Trigger para INSERT en especialidad
CREATE TRIGGER historial_trigger_insert_especialidad
AFTER INSERT ON especialidad
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('especialidad');

-- Trigger para UPDATE en especialidad
CREATE TRIGGER historial_trigger_update_especialidad
AFTER UPDATE ON especialidad
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('especialidad');

-- Trigger para DELETE en especialidad
CREATE TRIGGER historial_trigger_delete_especialidad
AFTER DELETE ON especialidad
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('especialidad');

-- Trigger para INSERT en plan_estudio
CREATE TRIGGER historial_trigger_insert_plan_estudio
AFTER INSERT ON plan_estudio
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('plan_estudio');

-- Trigger para UPDATE en plan_estudio
CREATE TRIGGER historial_trigger_update_plan_estudio
AFTER UPDATE ON plan_estudio
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('plan_estudio');

-- Trigger para DELETE en plan_estudio
CREATE TRIGGER historial_trigger_delete_plan_estudio
AFTER DELETE ON plan_estudio
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('plan_estudio');

-- Trigger para INSERT en usuarios
CREATE TRIGGER historial_trigger_insert_usuarios
AFTER INSERT ON usuarios
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('usuarios');

-- Trigger para UPDATE en usuarios
CREATE TRIGGER historial_trigger_update_usuarios
AFTER UPDATE ON usuarios
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('usuarios');

-- Trigger para DELETE en usuarios
CREATE TRIGGER historial_trigger_delete_usuarios
AFTER DELETE ON usuarios
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('usuarios');

-- Trigger para INSERT en egresado_basico
CREATE TRIGGER historial_trigger_insert_egresado_basico
AFTER INSERT ON egresado_basico
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('egresado_basico');

-- Trigger para UPDATE en egresado_basico
CREATE TRIGGER historial_trigger_update_egresado_basico
AFTER UPDATE ON egresado_basico
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('egresado_basico');

-- Trigger para DELETE en egresado_basico
CREATE TRIGGER historial_trigger_delete_egresado_basico
AFTER DELETE ON egresado_basico
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('egresado_basico');

-- Trigger para INSERT en empleador_basico
CREATE TRIGGER historial_trigger_insert_empleador_basico
AFTER INSERT ON empleador_basico
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('empleador_basico');

-- Trigger para UPDATE en empleador_basico
CREATE TRIGGER historial_trigger_update_empleador_basico
AFTER UPDATE ON empleador_basico
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('empleador_basico');

-- Trigger para DELETE en empleador_basico
CREATE TRIGGER historial_trigger_delete_empleador_basico
AFTER DELETE ON empleador_basico
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('empleador_basico');

-- Trigger para INSERT en administrativo_basico
CREATE TRIGGER historial_trigger_insert_administrativo_basico
AFTER INSERT ON administrativo_basico
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('administrativo_basico');

-- Trigger para UPDATE en administrativo_basico
CREATE TRIGGER historial_trigger_update_administrativo_basico
AFTER UPDATE ON administrativo_basico
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('administrativo_basico');

-- Trigger para DELETE en administrativo_basico
CREATE TRIGGER historial_trigger_delete_administrativo_basico
AFTER DELETE ON administrativo_basico
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('administrativo_basico');

-- Trigger para INSERT en experiencia_laboral
CREATE TRIGGER historial_trigger_insert_experiencia_laboral
AFTER INSERT ON experiencia_laboral
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('experiencia_laboral');

-- Trigger para UPDATE en experiencia_laboral
CREATE TRIGGER historial_trigger_update_experiencia_laboral
AFTER UPDATE ON experiencia_laboral
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('experiencia_laboral');

-- Trigger para DELETE en experiencia_laboral
CREATE TRIGGER historial_trigger_delete_experiencia_laboral
AFTER DELETE ON experiencia_laboral
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('experiencia_laboral');

-- Trigger para INSERT en bigdat
CREATE TRIGGER historial_trigger_insert_bigdat
AFTER INSERT ON bigdat
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('bigdat');

-- Trigger para UPDATE en bigdat
CREATE TRIGGER historial_trigger_update_bigdat
AFTER UPDATE ON bigdat
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('bigdat');

-- Trigger para DELETE en bigdat
CREATE TRIGGER historial_trigger_delete_bigdat
AFTER DELETE ON bigdat
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('bigdat');

-- Trigger para INSERT en encuesta
CREATE TRIGGER historial_trigger_insert_encuesta
AFTER INSERT ON encuesta
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('encuesta');

-- Trigger para UPDATE en encuesta
CREATE TRIGGER historial_trigger_update_encuesta
AFTER UPDATE ON encuesta
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('encuesta');

-- Trigger para DELETE en encuesta
CREATE TRIGGER historial_trigger_delete_encuesta
AFTER DELETE ON encuesta
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('encuesta');

-- Trigger para INSERT en pregunta
CREATE TRIGGER historial_trigger_insert_pregunta
AFTER INSERT ON pregunta
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('pregunta');

-- Trigger para UPDATE en pregunta
CREATE TRIGGER historial_trigger_update_pregunta
AFTER UPDATE ON pregunta
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('pregunta');

-- Trigger para DELETE en pregunta
CREATE TRIGGER historial_trigger_delete_pregunta
AFTER DELETE ON pregunta
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('pregunta');

-- Trigger para INSERT en respuesta_usuario
CREATE TRIGGER historial_trigger_insert_respuesta_usuario
AFTER INSERT ON respuesta_usuario
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('respuesta_usuario');

-- Trigger para UPDATE en respuesta_usuario
CREATE TRIGGER historial_trigger_update_respuesta_usuario
AFTER UPDATE ON respuesta_usuario
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('respuesta_usuario');

-- Trigger para DELETE en respuesta_usuario
CREATE TRIGGER historial_trigger_delete_respuesta_usuario
AFTER DELETE ON respuesta_usuario
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('respuesta_usuario');

-- Trigger para INSERT en respuesta_detallada
CREATE TRIGGER historial_trigger_insert_respuesta_detallada
AFTER INSERT ON respuesta_detallada
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('respuesta_detallada');

-- Trigger para UPDATE en respuesta_detallada
CREATE TRIGGER historial_trigger_update_respuesta_detallada
AFTER UPDATE ON respuesta_detallada
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('respuesta_detallada');

-- Trigger para DELETE en respuesta_detallada
CREATE TRIGGER historial_trigger_delete_respuesta_detallada
AFTER DELETE ON respuesta_detallada
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('respuesta_detallada');
