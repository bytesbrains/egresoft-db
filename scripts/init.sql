-- EGRESOFT DATASBE

-- CREACION DE LA BASE DE DATOS
CREATE DATABASE bytesbrains;

-- Conexion al bytesbrains
\c bytesbrains
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
  CONSTRAINT pk_carrera PRIMARY KEY (id_carrera, modalidad) 
);

CREATE TABLE especialidad (
  id_especialidad char(50) PRIMARY KEY,
  nombre char(50) NOT NULL,
  evaluador char(50) NOT NULL
);

CREATE TABLE plan_estudio (
  id_carrera char(50),
  modalidad char(50),
  id_especialidad char(50),
  periodo varchar(50)not null,
  CONSTRAINT fk1_carrera FOREIGN KEY (id_carrera, modalidad)
REFERENCES carrera (id_carrera, modalidad) 
ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk2_carrera FOREIGN KEY (id_especialidad)
REFERENCES especialidad (id_especialidad)
ON UPDATE CASCADE ON DELETE CASCADE
);

-- TABLAS DE EGRESADO
CREATE TABLE egresado_basico (
  id_egre char(50) PRIMARY KEY,
  id_carrera char(50),
  modalidad char(50),
  id_especialidad char(50),
  curp VARCHAR(18) NOT NULL,
  nombre VARCHAR(255) NOT NULL,
  apellidos VARCHAR(255)NOT NULL,
  fecha_egreso DATE NOT NULL,
  CONSTRAINT fk1_egresado_basico FOREIGN KEY (id_carrera, modalidad) 
REFERENCES carrera (id_carrera, modalidad) 
ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk2_egresado_basico FOREIGN KEY (id_especialidad) 
REFERENCES especialidad (id_especialidad) 
ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE contacto (
  id_contacto char(50) PRIMARY KEY,
  id_egre char(50),
  tipo_contacto varchar(255) not null,
  detalle varchar(255) not null,
  CONSTRAINT fk_contacto FOREIGN KEY (id_egre)
REFERENCES egresado_basico (id_egre) 
ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE experiencia_laboral (
  id_experiencia char(50) PRIMARY KEY,
  id_egre char(50),
  empresa VARCHAR(255) NOT NULL,
  cargo VARCHAR(255) NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NOT NULL,
  descripción TEXT NOT NULL,
  CONSTRAINT fk_experiencia_laboral FOREIGN KEY (id_egre) 
REFERENCES egresado_basico (id_egre) 
ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE curriculum (
  id_egre char(50) PRIMARY KEY,
  tipo char(50) NOT NULL,
  archivo BYTEA NOT NULL,
  CONSTRAINT fk_curriculum FOREIGN KEY (id_egre) 
REFERENCES egresado_basico (id_egre) 
ON UPDATE CASCADE ON DELETE CASCADE
);


-- TABLAS DE ENCUESTA
CREATE TABLE encuesta (
  id_encuesta char(50) PRIMARY KEY,
  id_especialidad char(50),
  seccion varchar(255) not null,
  nombre_encuesta varchar(255) not null,
  periodo varchar(255) not null,
  CONSTRAINT fk_encuesta FOREIGN KEY (id_especialidad) 
REFERENCES especialidad (id_especialidad) 
ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE pregunta (
  id_pregunta char(50) PRIMARY KEY,
  id_encuesta char(50),
  tipo char(20) not null,
  pregunta varchar(255) not null,
  CONSTRAINT fk_pregunta FOREIGN KEY (id_encuesta) 
REFERENCES encuesta (id_encuesta)ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE respuesta (
  id_pregunta char(50),
  opcion_respuesta varchar(255),
  CONSTRAINT fk_contenido FOREIGN KEY (id_pregunta) 
REFERENCES pregunta (id_pregunta)ON UPDATE CASCADE ON DELETE CASCADE
);


-- TABLA DEL PROCESO DE ENCUESTA
CREATE TABLE proceso_egresado_encuesta (
  id_egre char(50),
  id_encuesta char(50),
  id_pregunta char(50),
  fecha_envio date not null,
  respuesta varchar(255) not null,
  fecha_respuesta date not null,
  CONSTRAINT fk1_p_eg_en FOREIGN KEY (id_egre) 
REFERENCES egresado_basico (id_egre)ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk2_p_eg_en FOREIGN KEY (id_encuesta) 
REFERENCES encuesta (id_encuesta)ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk3_p_eg_en FOREIGN KEY (id_pregunta) 
REFERENCES pregunta (id_pregunta)ON UPDATE CASCADE ON DELETE CASCADE
);
 
--HISTORIAL
CREATE TABLE historial (
  id_historial serial PRIMARY KEY,
  usuario varchar(255) not null,
  hora timestamp not null,
  accion varchar (255)
);

CREATE OR REPLACE FUNCTION registrar_accion()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO historial ( usuario, hora, accion)
        VALUES (user, now(), 'ingreso datos en la tabla: ' || TG_ARGV[0]);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO historial ( usuario, hora, accion)
        VALUES (user, now(), 'actualizo datos en la tabla: ' || TG_ARGV[0]);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER historial_trigger_carrera
AFTER INSERT OR UPDATE ON carrera
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('carrera');

CREATE TRIGGER historial_trigger_especialidad
AFTER INSERT OR UPDATE ON especialidad
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('especialidad');

CREATE TRIGGER historial_trigger_plan_estudio
AFTER INSERT OR UPDATE ON plan_estudio
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('plan_estudio');

CREATE TRIGGER historial_trigger_egresado_basico
AFTER INSERT OR UPDATE ON egresado_basico
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('egresado_basico');

CREATE TRIGGER historial_trigger_contacto
AFTER INSERT OR UPDATE ON contacto
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('contacto');

CREATE TRIGGER historial_trigger_experiencia_laboral
AFTER INSERT OR UPDATE ON experiencia_laboral
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('experiencia_laboral');

CREATE TRIGGER historial_trigger_curruculum
AFTER INSERT OR UPDATE ON curriculum
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('curriculum');

CREATE TRIGGER historial_trigger_encuesta
AFTER INSERT OR UPDATE ON encuesta
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('encuesta');

CREATE TRIGGER historial_trigger_pregunta
AFTER INSERT OR UPDATE ON pregunta
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('pregunta');

CREATE TRIGGER historial_trigger_respuesta
AFTER INSERT OR UPDATE ON respuesta
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('respuesta');

CREATE TRIGGER historial_trigger_proceso
AFTER INSERT OR UPDATE ON proceso_egresado_encuesta
FOR EACH ROW
EXECUTE FUNCTION registrar_accion('Proceso_Egresado_Encuesta');

-----Carrera
INSERT INTO carrera (id_carrera, modalidad, nombre)
VALUES
  ('C001', 'Presencial', 'Ingeniería en Informática'),
  ('C002', 'Virtual', 'Licenciatura en Administración'),
  ('C003', 'Presencial', 'Arquitectura'),
  ('C004', 'Virtual', 'Licenciatura en Derecho'),
  ('C005', 'Presencial', 'Contabilidad'),
  ('C006', 'Presencial', 'Ingeniería Civil'),
  ('C007', 'Virtual', 'Licenciatura en Psicología'),
  ('C008', 'Presencial', 'Medicina'),
  ('C009', 'Virtual', 'Licenciatura en Marketing'),
  ('C010', 'Presencial', 'Diseño Gráfico');


-----Especilidad
INSERT INTO especialidad (id_especialidad, nombre, evaluador)
VALUES
  ('E001', 'Desarrollo de Software', 'Evaluador1'),
  ('E002', 'Recursos Humanos', 'Evaluador2'),
  ('E003', 'Arquitectura Sostenible', 'Evaluador3'),
  ('E004', 'Derecho Corporativo', 'Evaluador4'),
  ('E005', 'Auditoría Financiera', 'Evaluador5'),
  ('E006', 'Desarrollo Web Avanzado', 'Evaluador6'),
  ('E007', 'Psicología Clínica', 'Evaluador7'),
  ('E008', 'Cirugía General', 'Evaluador8'),
  ('E009', 'Marketing Digital', 'Evaluador9'),
  ('E010', 'Diseño de Identidad de Marca', 'Evaluador10');


-----Plan de estudio
INSERT INTO plan_estudio (id_carrera, modalidad, id_especialidad, periodo)
VALUES
  ('C001', 'Presencial', 'E001', '2022-1'),
  ('C002', 'Virtual', 'E002', '2022-2'),
  ('C003', 'Presencial', 'E003', '2022-1'),
  ('C004', 'Virtual', 'E004', '2022-2'),
  ('C005', 'Presencial', 'E005', '2022-1'),
  ('C006', 'Presencial', 'E006', '2022-2'),
  ('C007', 'Virtual', 'E007', '2022-1'),
  ('C008', 'Presencial', 'E008', '2022-2'),
  ('C009', 'Virtual', 'E009', '2022-1'),
  ('C010', 'Presencial', 'E010', '2022-2');



-----Egresado_Basico
INSERT INTO egresado_basico (id_egre, id_carrera, modalidad, id_especialidad, curp, nombre, apellidos, fecha_egreso)
VALUES
  ('E001', 'C001', 'Presencial', 'E001', 'ABC123456XYZ789', 'Juan', 'Pérez', '2022-05-15'),
  ('E002', 'C002', 'Virtual', 'E002', 'DEF789012UVW345', 'María', 'González', '2022-06-20'),
  ('E003', 'C003', 'Presencial', 'E003', 'GHI234567RST890', 'Carlos', 'López', '2022-07-25'),
  ('E004', 'C004', 'Virtual', 'E004', 'JKL456789LMN012', 'Sofía', 'Martínez', '2022-08-30'),
  ('E005', 'C005', 'Presencial', 'E005', 'OPQ567890ABC123', 'Luis', 'Ramírez', '2022-09-05'),
  ('E006', 'C006', 'Presencial', 'E006', 'XYZ123456ABC789', 'Laura', 'Sánchez', '2022-05-15'),
  ('E007', 'C007', 'Virtual', 'E007', 'UVW789012DEF345', 'Pedro', 'Martínez', '2022-06-20'),
  ('E008', 'C008', 'Presencial', 'E008', 'RST234567GHI890', 'Elena', 'López', '2022-07-25'),
  ('E009', 'C009', 'Virtual', 'E009', 'LMN456789JKL012', 'Daniel', 'Rodríguez', '2022-08-30'),
  ('E010', 'C010', 'Presencial', 'E010', 'ABC567890OPQ123', 'Isabella', 'García', '2022-09-05');


-----Contacto
INSERT INTO contacto (id_contacto, id_egre, tipo_contacto, detalle)
VALUES
  ('C001', 'E001', 'Correo Electrónico', 'juan@example.com'),
  ('C002', 'E002', 'Teléfono', '555-123-4567'),
  ('C003', 'E003', 'Correo Electrónico', 'carlos@example.com'),
  ('C004', 'E004', 'Teléfono', '555-789-0123'),
  ('C005', 'E005', 'Correo Electrónico', 'luis@example.com'),
  ('C006', 'E006', 'Correo Electrónico', 'laura@example.com'),
  ('C007', 'E007', 'Teléfono', '555-987-6543'),
  ('C008', 'E008', 'Correo Electrónico', 'elena@example.com'),
  ('C009', 'E009', 'Teléfono', '555-456-7890'),
  ('C010', 'E010', 'Correo Electrónico', 'isabella@example.com');

-----Experiencia_Laboral
INSERT INTO experiencia_laboral (id_experiencia, id_egre, empresa, cargo, fecha_inicio, fecha_fin, descripción)
VALUES
  ('EX001', 'E001', 'Empresa A', 'Desarrollador de Software', '2020-01-15', '2022-04-30', 'Desarrollo de aplicaciones web.'),
  ('EX002', 'E002', 'Empresa B', 'Recursos Humanos', '2019-05-20', '2022-06-30', 'Gestión de personal y selección de talento.'),
  ('EX003', 'E003', 'Empresa C', 'Arquitecto', '2018-06-25', '2022-07-31', 'Diseño de proyectos arquitectónicos sostenibles.'),
  ('EX004', 'E004', 'Empresa D', 'Abogado', '2017-07-30', '2022-08-31', 'Asesoramiento legal en derecho corporativo.'),
  ('EX005', 'E005', 'Empresa E', 'Auditor Financiero', '2016-08-05', '2022-09-15', 'Auditoría y análisis financiero.'),
  ('EX006', 'E006', 'Empresa F', 'Ingeniera Civil', '2019-01-15', '2022-04-30', 'Diseño y supervisión de proyectos de construcción.'),
  ('EX007', 'E007', 'Hospital G', 'Psicólogo Clínico', '2018-05-20', '2022-06-30', 'Terapia y evaluación psicológica.'),
  ('EX008', 'E008', 'Hospital H', 'Cirujano', '2017-06-25', '2022-07-31', 'Cirugías y atención médica.'),
  ('EX009', 'E009', 'Agencia de Marketing I', 'Especialista en Marketing Digital', '2016-07-30', '2022-08-31', 'Campañas y estrategias digitales.'),
  ('EX010', 'E010', 'Agencia de Diseño J', 'Diseñador Gráfico Senior', '2015-08-05', '2022-09-15', 'Diseño de identidades de marca y material gráfico.');

-----Curriculum
INSERT INTO curriculum (id_egre, tipo, archivo)
VALUES
  ('E001', 'PDF', 'ArchivoPDF1.pdf'),
  ('E002', 'Word', 'ArchivoWord1.docx'),
  ('E003', 'PDF', 'ArchivoPDF2.pdf'),
  ('E004', 'Word', 'ArchivoWord2.docx'),
  ('E005', 'PDF', 'ArchivoPDF3.pdf'),
  ('E006', 'PDF', 'ArchivoPDF4.pdf'),
  ('E007', 'Word', 'ArchivoWord3.docx'),
  ('E008', 'PDF', 'ArchivoPDF5.pdf'),
  ('E009', 'Word', 'ArchivoWord4.docx'),
  ('E010', 'PDF', 'ArchivoPDF6.pdf');


-----encuesta
INSERT INTO encuesta (id_encuesta, id_especialidad, seccion, nombre_encuesta, periodo)
VALUES
  ('ENC001', 'E001', 'Sección 1', 'Encuesta 1', '2022-1'),
  ('ENC002', 'E002', 'Sección 2', 'Encuesta 2', '2022-2'),
  ('ENC003', 'E003', 'Sección 1', 'Encuesta 3', '2022-1'),
  ('ENC004', 'E004', 'Sección 2', 'Encuesta 4', '2022-2'),
  ('ENC005', 'E005', 'Sección 1', 'Encuesta 5', '2022-1'),
  ('ENC006', 'E006', 'Sección 1', 'Encuesta 6', '2022-1'),
  ('ENC007', 'E007', 'Sección 2', 'Encuesta 7', '2022-2'),
  ('ENC008', 'E008', 'Sección 1', 'Encuesta 8', '2022-1'),
  ('ENC009', 'E009', 'Sección 2', 'Encuesta 9', '2022-2'),
  ('ENC010', 'E010', 'Sección 1', 'Encuesta 10', '2022-1');

-----pregunta
INSERT INTO pregunta (id_pregunta, id_encuesta, tipo, pregunta)
VALUES
  ('P001', 'ENC001', 'Opción Múltiple', '¿Cómo calificaría su experiencia en el programa?'),
  ('P002', 'ENC001', 'Abierta', '¿Qué sugerencias tiene para mejorar?'),
  ('P003', 'ENC002', 'Opción Múltiple', '¿Está satisfecho con los recursos de aprendizaje?'),
  ('P004', 'ENC002', 'Abierta', '¿Qué herramientas le gustaría tener?'),
  ('P005', 'ENC003', 'Opción Múltiple', '¿Qué tan útil fue la orientación académica?'),
  ('P006', 'ENC003', 'Abierta', '¿Qué información le habría gustado recibir?'),
  ('P007', 'ENC004', 'Opción Múltiple', '¿Está satisfecho con la asesoría legal?'),
  ('P008', 'ENC004', 'Abierta', '¿Qué temas legales le interesan más?'),
  ('P009', 'ENC005', 'Opción Múltiple', '¿Ha mejorado su equilibrio trabajo-vida?'),
  ('P010', 'ENC005', 'Abierta', '¿Cómo ha impactado su salud y bienestar?'),
  ('P011', 'ENC006', 'Opción Múltiple', '¿Cómo evaluaría la calidad de la construcción?'),
  ('P012', 'ENC006', 'Abierta', '¿Qué mejoras sugeriría en el diseño?'),
  ('P013', 'ENC007', 'Opción Múltiple', '¿Está satisfecho con el enfoque terapéutico?'),
  ('P014', 'ENC007', 'Abierta', '¿Qué áreas de mejora observa?'),
  ('P015', 'ENC008', 'Opción Múltiple', '¿Cómo calificaría la atención médica?'),
  ('P016', 'ENC008', 'Abierta', '¿Qué servicios adicionales desearía?'),
  ('P017', 'ENC009', 'Opción Múltiple', '¿Le ha resultado efectiva la estrategia de marketing?'),
  ('P018', 'ENC009', 'Abierta', '¿Qué áreas de su negocio le gustaría promocionar?'),
  ('P019', 'ENC010', 'Opción Múltiple', '¿Qué opinión tiene de la creatividad del diseño?'),
  ('P020', 'ENC010', 'Abierta', '¿Qué elementos visuales prefiere para su marca?');

-----respuesta
INSERT INTO respuesta (id_pregunta, opcion_respuesta)
VALUES
  ('P001', 'Muy Satisfactorio'),
  ('P001', 'Satisfactorio'),
  ('P001', 'Neutral'),
  ('P001', 'Insatisfactorio'),
  ('P002', 'Me gustaría más interacción con los profesores.'),
  ('P002', 'Necesitamos más recursos digitales.'),
  ('P003', 'Muy Satisfecho'),
  ('P003', 'Satisfecho'),
  ('P003', 'Neutral'),
  ('P004', 'Más herramientas de investigación.'),
  ('P011', 'Excelente'),
  ('P011', 'Bueno'),
  ('P011', 'Regular'),
  ('P011', 'Necesita Mejora'),
  ('P012', 'Más espacio de almacenamiento.'),
  ('P012', 'Mayor eficiencia energética.'),
  ('P013', 'Muy Satisfecho'),
  ('P013', 'Satisfecho'),
  ('P013', 'Neutral'),
  ('P014', 'Necesidad de más personal especializado.');

-----Proceso_Egresado_Encuesta
INSERT INTO proceso_egresado_encuesta (id_egre, id_encuesta, id_pregunta, fecha_envio, respuesta, fecha_respuesta)
VALUES
  ('E001', 'ENC001', 'P001', '2022-05-01', 'Muy Satisfactorio', '2022-05-02'),
  ('E002', 'ENC001', 'P001', '2022-06-01', 'Satisfactorio', '2022-06-02'),
  ('E003', 'ENC001', 'P001', '2022-07-01', 'Neutral', '2022-07-02'),
  ('E004', 'ENC001', 'P001', '2022-08-01', 'Insatisfactorio', '2022-08-02'),
  ('E005', 'ENC001', 'P001', '2022-09-01', 'Muy Satisfactorio', '2022-09-02'),
  ('E006', 'ENC006', 'P011', '2022-05-01', 'Excelente', '2022-05-02'),
  ('E007', 'ENC006', 'P011', '2022-06-01', 'Bueno', '2022-06-02'),
  ('E008', 'ENC006', 'P011', '2022-07-01', 'Regular', '2022-07-02'),
  ('E009', 'ENC006', 'P011', '2022-08-01', 'Necesita Mejora', '2022-08-02'),
  ('E010', 'ENC006', 'P011', '2022-09-01', 'Excelente', '2022-09-02');
