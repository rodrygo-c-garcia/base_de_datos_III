--
-- Por :      Ariel Rodrigo Colque Garcia
-- Carrera :      Ingenieria en Ciencias de la Computacion
-- Materia :      Base de Datos III

-- TABLE: ALIMENTO
CREATE TABLE ALIMENTO(
    ID_alimento    CHAR(10)         NOT NULL,
    nombre         VARCHAR2(30)     NOT NULL CONSTRAINT UQ_alimento_nombre UNIQUE,
    stock          NUMBER(38, 0)    NOT NULL,
    calor          NUMBER(10, 2)    NOT NULL,
    CONSTRAINT PK_alimento PRIMARY KEY (ID_alimento),
    CONSTRAINT CK_stock CHECK (stock >= 0),
    CONSTRAINT CK_calor CHECK (calor >= 0)
);

-- TABLE: ESPECIE
CREATE TABLE ESPECIE(
    ID_especie         CHAR(10)        NOT NULL,
    nombre             VARCHAR2(30)    NOT NULL CONSTRAINT UQ_especie_nombre UNIQUE,
    caracteristicas    VARCHAR2(50)    NOT NULL,
    CONSTRAINT PK_especie PRIMARY KEY (ID_especie)
);


-- TABLE: CLIENTE
CREATE TABLE CLIENTE(
    ID_cliente    CHAR(10)        NOT NULL,
    nombre        VARCHAR2(50)    NOT NULL,
    CONSTRAINT PK_cliente PRIMARY KEY (ID_cliente)
);

-- TABLE: EMPLEADO
CREATE TABLE EMPLEADO(
     ID_empleado           CHAR(10)        NOT NULL,
     nombre                VARCHAR2(40)    NOT NULL,
     fecha_nacimiento      DATE            NOT NULL,
     fecha_contratacion    DATE            NOT NULL,
     tipo                   CHAR(10)        NOT NULL,
     CONSTRAINT PK_empleado PRIMARY KEY (ID_empleado),
     CONSTRAINT CK_fecha CHECK (fecha_nacimiento < fecha_contratacion)
);

-- TABLE: CUIDADOR
CREATE TABLE CUIDADOR(
    ID_empleado    CHAR(10)         NOT NULL,
    habilidad      VARCHAR2(40)     NOT NULL,
    experiencia    NUMBER(38, 0)    NOT NULL,
    CONSTRAINT PK_cuidador PRIMARY KEY (ID_empleado),
    CONSTRAINT FK_cuidador FOREIGN KEY (ID_empleado) REFERENCES EMPLEADO(ID_empleado),
    CONSTRAINT CK_experiencia CHECK (experiencia >= 0)
);


-- TABLE: GUIA
CREATE TABLE GUIA(
    ID_empleado    CHAR(10)        NOT NULL,
    nacion         VARCHAR2(40)    NOT NULL,
    idiomas        VARCHAR2(50)    NOT NULL,
    CONSTRAINT PK_guia PRIMARY KEY (ID_empleado),
    CONSTRAINT FK_guia FOREIGN KEY (ID_empleado) REFERENCES EMPLEADO(ID_empleado)
);


-- TABLE: TOUR
CREATE TABLE TOUR(
    ID_tour        CHAR(10)         NOT NULL,
    nombre         VARCHAR2(40)     NOT NULL,
    tiempo         NUMBER(10, 2)    NOT NULL CONSTRAINT CK_tiempo CHECK (tiempo > 0),
    ID_empleado    CHAR(10)         NOT NULL,
    CONSTRAINT PK_TOUR PRIMARY KEY (ID_tour),
    CONSTRAINT FK_tour_guia FOREIGN KEY (ID_empleado) REFERENCES GUIA(ID_empleado)
);

-- TABLE: RECORRIDO
CREATE TABLE RECORRIDO(
    ID_recorrido    CHAR(10)         NOT NULL,
    fecha           DATE             NOT NULL,
    hora            TIMESTAMP(6)     NOT NULL,
    inciden         NUMBER(38, 0)    NOT NULL,
    ID_tour         CHAR(10)         NOT NULL,
    CONSTRAINT PK_recorrido PRIMARY KEY (ID_recorrido),
    CONSTRAINT CK_hora CHECK (TO_CHAR(hora, 'HH24') BETWEEN '08' AND '18'),
    CONSTRAINT CK_incidencias CHECK (inciden >= 0),
    CONSTRAINT FK_recorrido_tour FOREIGN KEY (ID_tour) REFERENCES TOUR(ID_tour)
);

-- TABLE: Realiza
CREATE TABLE Realiza(
    ID_cliente      CHAR(10)    NOT NULL,
    ID_recorrido    CHAR(10)    NOT NULL,
    CONSTRAINT PK_realiza PRIMARY KEY (ID_cliente, ID_recorrido),
    CONSTRAINT FK_realiza_cliente FOREIGN KEY (ID_cliente) REFERENCES CLIENTE(ID_cliente),
    CONSTRAINT FK_realiza_recorrido FOREIGN KEY (ID_recorrido) REFERENCES RECORRIDO(ID_recorrido)
);


-- TABLE: RECINTO
CREATE TABLE RECINTO(
    ID_recinto    CHAR(10)         NOT NULL,
    tipo          VARCHAR2(40)     NOT NULL,
    capacidad     NUMBER(38, 0)    NOT NULL CONSTRAINT CK_capacidad CHECK (capacidad > 0),
    CONSTRAINT PK_recinto PRIMARY KEY (ID_recinto)
);


-- TABLE: Visita
CREATE TABLE Visita(
    ID_recinto    CHAR(10)        NOT NULL,
    ID_tour       CHAR(10)        NOT NULL,
    orden         VARCHAR2(40)    NOT NULL,
    CONSTRAINT PK_visita PRIMARY KEY (ID_recinto, ID_tour),
    CONSTRAINT FK_visita_recinto FOREIGN KEY (ID_recinto) REFERENCES RECINTO(ID_recinto),
    CONSTRAINT FK_visita_tour FOREIGN KEY (ID_tour) REFERENCES TOUR(ID_tour)
);

-- TABLE: ANIMAL
CREATE TABLE ANIMAL(
    ID_animal      CHAR(10)        NOT NULL,
    nombre         VARCHAR2(40)    NOT NULL,
    ID_especie     CHAR(10)        NOT NULL,
    ID_empleado    CHAR(10)        NOT NULL,
    ID_recinto     CHAR(10)        NOT NULL,
    CONSTRAINT PK_animal PRIMARY KEY (ID_animal),
    CONSTRAINT FK_animal_especie FOREIGN KEY (ID_especie) REFERENCES ESPECIE(ID_especie),
    CONSTRAINT FK_animal_cuidador FOREIGN KEY (ID_empleado) REFERENCES CUIDADOR(ID_empleado),
    CONSTRAINT FK_animal_recinto FOREIGN KEY (ID_recinto) REFERENCES RECINTO(ID_recinto)
);

-- TABLE: Come
CREATE TABLE Come(
    ID_animal   CHAR(10)         NOT NULL,
    ID_alimento    CHAR(10)         NOT NULL,
    cantidad       INTEGER    NOT NULL CONSTRAINT CK_cantidad CHECK (cantidad > 0),
    frecuencia     NUMBER(38, 2)    NOT NULL CONSTRAINT CK_frecuencia CHECK (frecuencia > 0),
    CONSTRAINT PK_come PRIMARY KEY (ID_animal, ID_alimento),
    CONSTRAINT FK_come_animal FOREIGN KEY (ID_animal) REFERENCES ANIMAL(ID_animal),
    CONSTRAINT FK_come_alimento FOREIGN KEY (ID_alimento) REFERENCES ALIMENTO(ID_alimento)
);


-- INSERCION DE DATOS
-- ALIMENTO
INSERT INTO ALIMENTO (ID_alimento, nombre, stock, calor) VALUES ('A001', 'Afrecho', 100, 50.0);
INSERT INTO ALIMENTO (ID_alimento, nombre, stock, calor) VALUES ('A002', 'Alfalfa', 200, 60.0);
INSERT INTO ALIMENTO (ID_alimento, nombre, stock, calor) VALUES ('A003', 'Frutas', 300, 70.0);
SELECT * FROM ALIMENTO;

-- ESPECIE

INSERT INTO ESPECIE (ID_especie, nombre, caracteristicas) VALUES ('E001', 'León', 'Carnívoro, vive en la sabana');
INSERT INTO ESPECIE (ID_especie, nombre, caracteristicas) VALUES ('E002', 'Elefante', 'Herbívoro, vive en la sabana y selva');
INSERT INTO ESPECIE (ID_especie, nombre, caracteristicas) VALUES ('E003', 'Águila', 'Carnívoro, vive en montañas y bosques');
SELECT * FROM ESPECIE;


-- Cliente
INSERT INTO CLIENTE (ID_cliente, nombre) VALUES ('C001', 'Rodrigo Garcia');
INSERT INTO CLIENTE (ID_cliente, nombre) VALUES ('C002', 'Ana Perez');
INSERT INTO CLIENTE (ID_cliente, nombre) VALUES ('C003', 'Carlos Morales');

-- Empleado
INSERT INTO EMPLEADO (ID_empleado, nombre, fecha_nacimiento, fecha_contratacion, tipo) VALUES ('E001', 'Juan Perez', TO_DATE('1980-01-01', 'YYYY-MM-DD'), TO_DATE('2010-01-01', 'YYYY-MM-DD'), 'cuidador');
INSERT INTO EMPLEADO (ID_empleado, nombre, fecha_nacimiento, fecha_contratacion, tipo) VALUES ('E002', 'Maria Garcia', TO_DATE('1985-02-02', 'YYYY-MM-DD'), TO_DATE('2015-02-02', 'YYYY-MM-DD'), 'cuidador');
INSERT INTO EMPLEADO (ID_empleado, nombre, fecha_nacimiento, fecha_contratacion, tipo) VALUES ('E003', 'Carlos Morales', TO_DATE('1990-03-03', 'YYYY-MM-DD'), TO_DATE('2020-03-03', 'YYYY-MM-DD'), 'cuidador');
INSERT INTO EMPLEADO (ID_empleado, nombre, fecha_nacimiento, fecha_contratacion, tipo) VALUES ('E004', 'Ana Rodriguez', TO_DATE('1982-04-04', 'YYYY-MM-DD'), TO_DATE('2012-04-04', 'YYYY-MM-DD'), 'guia');
INSERT INTO EMPLEADO (ID_empleado, nombre, fecha_nacimiento, fecha_contratacion, tipo) VALUES ('E005', 'Pedro Sanchez', TO_DATE('1983-05-05', 'YYYY-MM-DD'), TO_DATE('2013-05-05', 'YYYY-MM-DD'), 'guia');
INSERT INTO EMPLEADO (ID_empleado, nombre, fecha_nacimiento, fecha_contratacion, tipo) VALUES ('E006', 'Laura Lopez', TO_DATE('1984-06-06', 'YYYY-MM-DD'), TO_DATE('2014-06-06', 'YYYY-MM-DD'), 'guia');
SELECT * FROM EMPLEADO;

-- CUIDADOR
INSERT INTO CUIDADOR (ID_empleado, habilidad, experiencia) VALUES ('E001', 'Cuidado de felinos', 10);
INSERT INTO CUIDADOR (ID_empleado, habilidad, experiencia) VALUES ('E002', 'Cuidado de aves', 5);
INSERT INTO CUIDADOR (ID_empleado, habilidad, experiencia) VALUES ('E003', 'Cuidado de marsupiales', 15);

-- GUIA
INSERT INTO GUIA (ID_empleado, nacion, idiomas) VALUES ('E004', 'Bolivia', 'Español, Inglés');
INSERT INTO GUIA (ID_empleado, nacion, idiomas) VALUES ('E005', 'Perú', 'Español, Francés');
INSERT INTO GUIA (ID_empleado, nacion, idiomas) VALUES ('E006', 'Chile', 'Español, Alemán');

-- TOUR
INSERT INTO TOUR (ID_tour, nombre, tiempo, ID_empleado) VALUES ('T001', 'Tour de la Sabana', 2.5, 'E004');
INSERT INTO TOUR (ID_tour, nombre, tiempo, ID_empleado) VALUES ('T002', 'Tour de la Selva', 3.0, 'E005');
INSERT INTO TOUR (ID_tour, nombre, tiempo, ID_empleado) VALUES ('T003', 'Tour de las Montañas', 4.0, 'E006');
SELECT * FROM TOUR;

-- RECORRIDO
INSERT INTO RECORRIDO (ID_recorrido, fecha, hora, inciden, ID_tour) VALUES ('R001', TO_DATE('2022-01-01', 'YYYY-MM-DD'), TO_TIMESTAMP('10:00:00', 'HH24:MI:SS'), 0, 'T001');
INSERT INTO RECORRIDO (ID_recorrido, fecha, hora, inciden, ID_tour) VALUES ('R002', TO_DATE('2022-02-02', 'YYYY-MM-DD'), TO_TIMESTAMP('11:00:00', 'HH24:MI:SS'), 1, 'T002');
INSERT INTO RECORRIDO (ID_recorrido, fecha, hora, inciden, ID_tour) VALUES ('R003', TO_DATE('2022-03-03', 'YYYY-MM-DD'), TO_TIMESTAMP('12:00:00', 'HH24:MI:SS'), 2, 'T003');
SELECT * FROM RECORRIDO;

-- REALIZA
INSERT INTO Realiza (ID_cliente, ID_recorrido) VALUES ('C001', 'R001');
INSERT INTO Realiza (ID_cliente, ID_recorrido) VALUES ('C002', 'R002');
INSERT INTO Realiza (ID_cliente, ID_recorrido) VALUES ('C003', 'R003');

-- RECINTO
INSERT INTO RECINTO (ID_recinto, tipo, capacidad) VALUES ('R001', 'Acuático', 20);
INSERT INTO RECINTO (ID_recinto, tipo, capacidad) VALUES ('R002', 'Terrestre', 30);
INSERT INTO RECINTO (ID_recinto, tipo, capacidad) VALUES ('R003', 'Aéreo', 15);

-- VISITA
INSERT INTO Visita (ID_recinto, ID_tour, orden) VALUES ('R001', 'T001', 'Primero');
INSERT INTO Visita (ID_recinto, ID_tour, orden) VALUES ('R002', 'T002', 'Segundo');
INSERT INTO Visita (ID_recinto, ID_tour, orden) VALUES ('R003', 'T003', 'Tercero');

-- ANIMAL
INSERT INTO ANIMAL (ID_animal, nombre, ID_especie, ID_empleado, ID_recinto) VALUES ('A001', 'Alex', 'E001', 'E001', 'R001');
INSERT INTO ANIMAL (ID_animal, nombre, ID_especie, ID_empleado, ID_recinto) VALUES ('A002', 'Dumbo', 'E002', 'E002', 'R002');
INSERT INTO ANIMAL (ID_animal, nombre, ID_especie, ID_empleado, ID_recinto) VALUES ('A003', 'Eagle Eye', 'E003', 'E003', 'R003');

-- COME
INSERT INTO Come (ID_animal, ID_alimento, cantidad, frecuencia) VALUES ('A001', 'A001', 5, 2.0);
INSERT INTO Come (ID_animal, ID_alimento, cantidad, frecuencia) VALUES ('A002', 'A002', 10, 1.5);
INSERT INTO Come (ID_animal, ID_alimento, cantidad, frecuencia) VALUES ('A003', 'A003', 8, 2.5);


