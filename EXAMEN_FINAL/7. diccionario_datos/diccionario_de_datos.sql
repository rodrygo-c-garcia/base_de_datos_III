create table ALIMENTO
(
    ID_ALIMENTO CHAR(10)      not null
        constraint PK_ALIMENTO
            primary key,
    NOMBRE      VARCHAR2(30)  not null,
    STOCK       NUMBER(38)    not null
        constraint CK_STOCK
            check (stock >= 0),
    CALOR       NUMBER(10, 2) not null
        constraint CK_CALOR
            check (calor >= 0)
)
    /

create table ESPECIE
(
    ID_ESPECIE      CHAR(10)     not null
        constraint PK_ESPECIE
            primary key,
    NOMBRE          VARCHAR2(30) not null
        constraint UQ_ESPECIE_NOMBRE
            unique,
    CARACTERISTICAS VARCHAR2(50) not null
)
    /

create table CLIENTE
(
    ID_CLIENTE CHAR(10)     not null
        constraint PK_CLIENTE
            primary key,
    NOMBRE     VARCHAR2(50) not null
)
    /

create table EMPLEADO
(
    ID_EMPLEADO        CHAR(10)     not null
        constraint PK_EMPLEADO
            primary key,
    NOMBRE             VARCHAR2(40) not null,
    FECHA_NACIMIENTO   DATE         not null,
    FECHA_CONTRATACION DATE         not null,
    TIPO               CHAR(10)     not null,
    constraint CK_FECHA
        check (fecha_nacimiento < fecha_contratacion)
)
    /

create trigger CHECK_FECHA_NACIMIENTO
    before insert or update
                         on EMPLEADO
                         for each row
BEGIN
    IF :NEW.fecha_nacimiento < ADD_MONTHS(SYSDATE, -1200) THEN
        RAISE_APPLICATION_ERROR(-20002, 'La fecha de nacimiento no puede ser mayor a 100 años atrás');
END IF;
END;
/

create trigger CHECK_FECHA_CONTRATACION
    before insert or update
                         on EMPLEADO
                         for each row
BEGIN
    IF :NEW.fecha_contratacion > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20003, 'La fecha de contratación no puede ser en el futuro');
END IF;
END;
/

create table CUIDADOR
(
    ID_EMPLEADO CHAR(10)     not null
        constraint PK_CUIDADOR
            primary key
        constraint FK_CUIDADOR
            references EMPLEADO,
    HABILIDAD   VARCHAR2(40) not null,
    EXPERIENCIA NUMBER(38)   not null
        constraint CK_EXPERIENCIA
            check (experiencia >= 0)
)
    /

create trigger CHECK_TIPO_EMPLEADO_CUIDADOR
    before insert or update
                         on CUIDADOR
                         for each row
BEGIN
    IF EXISTS (SELECT 1 FROM GUIA WHERE ID_empleado = :NEW.ID_empleado) THEN
        RAISE_APPLICATION_ERROR(-20007, 'El empleado no puede ser guía y cuidador al mismo tiempo');
END IF;
END;
/

create table GUIA
(
    ID_EMPLEADO CHAR(10)     not null
        constraint PK_GUIA
            primary key
        constraint FK_GUIA
            references EMPLEADO,
    NACION      VARCHAR2(40) not null,
    IDIOMAS     VARCHAR2(50) not null
)
    /

create trigger CHECK_TIPO_EMPLEADO_GUIA
    before insert or update
                         on GUIA
                         for each row
BEGIN
    IF EXISTS (SELECT 1 FROM CUIDADOR WHERE ID_empleado = :NEW.ID_empleado) THEN
        RAISE_APPLICATION_ERROR(-20008, 'El empleado no puede ser cuidador y guía al mismo tiempo');
END IF;
END;
/

create table TOUR
(
    ID_TOUR     CHAR(10)      not null
        constraint PK_TOUR
            primary key,
    NOMBRE      VARCHAR2(40)  not null,
    TIEMPO      NUMBER(10, 2) not null
        constraint CK_TIEMPO
            check (tiempo > 0),
    ID_EMPLEADO CHAR(10)      not null
        constraint FK_TOUR_GUIA
            references GUIA
)
    /

create trigger CHECK_EMPLEADO_GUIA
    before insert or update
                         on TOUR
                         for each row
BEGIN
    IF :NEW.ID_empleado IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM GUIA WHERE ID_empleado = :NEW.ID_empleado) THEN
            RAISE_APPLICATION_ERROR(-20006, 'El empleado asignado no es un guía válido');
END IF;
END IF;
END;
/

create trigger UPDATE_TOUR_RECORRIDO
    after update
    on TOUR
    for each row
BEGIN
    UPDATE RECORRIDO
    SET fecha = :NEW.fecha, hora = :NEW.hora
    WHERE ID_tour = :OLD.ID_tour;
END;
/

create table RECORRIDO
(
    ID_RECORRIDO CHAR(10)     not null
        constraint PK_RECORRIDO
            primary key,
    FECHA        DATE         not null,
    HORA         TIMESTAMP(6) not null
        constraint CK_HORA
            check (TO_CHAR(hora, 'HH24') BETWEEN '08' AND '18'),
    INCIDEN      NUMBER(38)   not null
        constraint CK_INCIDENCIAS
            check (inciden >= 0),
    ID_TOUR      CHAR(10)     not null
        constraint FK_RECORRIDO_TOUR
            references TOUR
)
    /

create trigger CHECK_FECHA
    before insert or update
                         on RECORRIDO
                         for each row
BEGIN
    IF :NEW.fecha < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20001, 'La fecha debe ser en el futuro');
END IF;
END;
/

create trigger CHECK_TOUR_TIME_OVERLAP
    before insert or update
                         on RECORRIDO
                         for each row
DECLARE
v_count INTEGER;
BEGIN
SELECT COUNT(*)
INTO v_count
FROM RECORRIDO r
         JOIN TOUR t ON r.ID_tour = t.ID_tour
WHERE t.ID_empleado = (SELECT ID_empleado FROM TOUR WHERE ID_tour = :NEW.ID_tour)
  AND r.fecha = :NEW.fecha
  AND r.hora = :NEW.hora
  AND r.ID_recorrido != :NEW.ID_recorrido;

IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'El guía ya tiene un tour en la misma fecha y hora');
END IF;
END;
/

create table REALIZA
(
    ID_CLIENTE   CHAR(10) not null
        constraint FK_REALIZA_CLIENTE
            references CLIENTE,
    ID_RECORRIDO CHAR(10) not null
        constraint FK_REALIZA_RECORRIDO
            references RECORRIDO,
    constraint PK_REALIZA
        primary key (ID_CLIENTE, ID_RECORRIDO)
)
    /

create table RECINTO
(
    ID_RECINTO CHAR(10)     not null
        constraint PK_RECINTO
            primary key,
    TIPO       VARCHAR2(40) not null,
    CAPACIDAD  NUMBER(38)   not null
        constraint CK_CAPACIDAD
            check (capacidad > 0)
)
    /

create table VISITA
(
    ID_RECINTO CHAR(10)     not null
        constraint FK_VISITA_RECINTO
            references RECINTO,
    ID_TOUR    CHAR(10)     not null
        constraint FK_VISITA_TOUR
            references TOUR,
    ORDEN      VARCHAR2(40) not null,
    constraint PK_VISITA
        primary key (ID_RECINTO, ID_TOUR)
)
    /

create table ANIMAL
(
    ID_ANIMAL   CHAR(10)     not null
        constraint PK_ANIMAL
            primary key,
    NOMBRE      VARCHAR2(40) not null,
    ID_ESPECIE  CHAR(10)     not null
        constraint FK_ANIMAL_ESPECIE
            references ESPECIE,
    ID_EMPLEADO CHAR(10)     not null
        constraint FK_ANIMAL_CUIDADOR
            references CUIDADOR,
    ID_RECINTO  CHAR(10)     not null
        constraint FK_ANIMAL_RECINTO
            references RECINTO
)
    /

create trigger CHECK_EMPLEADO_CUIDADOR
    before insert or update
                         on ANIMAL
                         for each row
DECLARE
v_exists NUMBER(1);
BEGIN
    IF :NEW.ID_empleado IS NOT NULL THEN
SELECT 1 INTO v_exists FROM CUIDADOR WHERE ID_empleado = :NEW.ID_empleado;
IF v_exists IS NULL THEN
            RAISE_APPLICATION_ERROR(-20005, 'El empleado asignado no es un cuidador válido');
END IF;
END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005, 'El empleado asignado no es un cuidador válido');
END;
/

create trigger CHECK_CAPACIDAD_RECINTO
    before insert or update
                         on ANIMAL
                         for each row
DECLARE
v_capacidad NUMBER;
    v_num_animals NUMBER;
BEGIN
SELECT capacidad INTO v_capacidad FROM RECINTO WHERE ID_recinto = :NEW.ID_recinto;
SELECT COUNT(*) INTO v_num_animals FROM ANIMAL WHERE ID_recinto = :NEW.ID_recinto;

IF v_num_animals >= v_capacidad THEN
        RAISE_APPLICATION_ERROR(-20010, 'La capacidad del recinto se ha excedido');
END IF;
END;
/

create table COME
(
    ID_ANIMAL   CHAR(10)      not null
        constraint FK_COME_ANIMAL
            references ANIMAL,
    ID_ALIMENTO CHAR(10)      not null
        constraint FK_COME_ALIMENTO
            references ALIMENTO,
    CANTIDAD    NUMBER        not null
        constraint CK_CANTIDAD
            check (cantidad > 0),
    FRECUENCIA  NUMBER(38, 2) not null
        constraint CK_FRECUENCIA
            check (frecuencia > 0),
    constraint PK_COME
        primary key (ID_ANIMAL, ID_ALIMENTO)
)
    /

create trigger UPDATE_STOCK_ALIMENTO
    after insert or update
                        on COME
                        for each row
BEGIN
UPDATE ALIMENTO
SET stock = stock - :NEW.cantidad
WHERE ID_alimento = :NEW.ID_alimento;

IF (SELECT stock FROM ALIMENTO WHERE ID_alimento = :NEW.ID_alimento) < 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Stock no puede ser negativo');
END IF;
END;
/

create PACKAGE zoo_animals AS
    -- Procedimiento para agregar un animal
    PROCEDURE add_animal(
        p_id_animal CHAR,
        p_nombre VARCHAR2,
        p_id_especie CHAR,
        p_id_empleado CHAR,
        p_id_recinto CHAR
    );
--     Procedimiento para actualizar un animal
    PROCEDURE update_animal(
        p_id_animal CHAR,
        p_nombre VARCHAR2,
        p_id_especie CHAR,
        p_id_empleado CHAR,
        p_id_recinto CHAR
    );
--     Procedimiento para eliminar un animal
    PROCEDURE delete_animal(p_id_animal CHAR);

    -- Función para obtener la información de un animal
    FUNCTION get_animal_info(p_id_animal CHAR) RETURN VARCHAR2;
END zoo_animals;
/

create PACKAGE BODY zoo_animals AS
--        Procedimiento para agregar un animal
    PROCEDURE add_animal(
        p_id_animal CHAR,
        p_nombre VARCHAR2,
        p_id_especie CHAR,
        p_id_empleado CHAR,
        p_id_recinto CHAR
        ) IS
BEGIN
INSERT INTO ANIMAL (ID_animal, nombre, ID_especie, ID_empleado, ID_recinto)
VALUES (p_id_animal, p_nombre, p_id_especie, p_id_empleado, p_id_recinto);
END add_animal;

--    Procedimiento para actualizar un animal
    PROCEDURE update_animal(
        p_id_animal CHAR,
        p_nombre VARCHAR2,
        p_id_especie CHAR,
        p_id_empleado CHAR,
        p_id_recinto CHAR
    ) IS
BEGIN
UPDATE ANIMAL
SET nombre = p_nombre,
    ID_especie = p_id_especie,
    ID_empleado = p_id_empleado,
    ID_recinto = p_id_recinto
WHERE ID_animal = p_id_animal;
END update_animal;

--   Procedimiento para eliminar un animal
    PROCEDURE delete_animal(p_id_animal CHAR) IS
BEGIN
DELETE FROM ANIMAL WHERE ID_animal = p_id_animal;
END delete_animal;

    FUNCTION get_animal_info(p_id_animal CHAR) RETURN VARCHAR2 IS
        v_info VARCHAR2(200);
BEGIN
SELECT 'Nombre: ' || nombre || ', Especie: ' || ID_especie || ', Cuidador: ' || ID_empleado || ', Recinto: ' || ID_recinto
INTO v_info
FROM ANIMAL
WHERE ID_animal = p_id_animal;
RETURN v_info;
END get_animal_info;
END zoo_animals;
/

create PACKAGE zoo_employees AS
    -- Procedimiento para agregar un nuevo empleado
    PROCEDURE add_employee(
        p_id_empleado CHAR,
        p_nombre VARCHAR2,
        p_fecha_nacimiento DATE,
        p_fecha_contratacion DATE,
        p_tipo CHAR
    );

    -- Procedimiento para actualizar la información de un empleado existente
    PROCEDURE update_employee(
        p_id_empleado CHAR,
        p_nombre VARCHAR2,
        p_fecha_nacimiento DATE,
        p_fecha_contratacion DATE,
        p_tipo CHAR
    );

    -- Procedimiento para eliminar un empleado
    PROCEDURE delete_employee(p_id_empleado CHAR);

    -- Función para obtener información detallada de un empleado
    FUNCTION get_employee_info(p_id_empleado CHAR) RETURN VARCHAR2;
END zoo_employees;
/

create PACKAGE BODY zoo_employees AS
    -- Implementación del procedimiento para agregar un nuevo empleado
    PROCEDURE add_employee(
        p_id_empleado CHAR,
        p_nombre VARCHAR2,
        p_fecha_nacimiento DATE,
        p_fecha_contratacion DATE,
        p_tipo CHAR
    ) IS
BEGIN
INSERT INTO EMPLEADO (ID_empleado, nombre, fecha_nacimiento, fecha_contratacion, tipo)
VALUES (p_id_empleado, p_nombre, p_fecha_nacimiento, p_fecha_contratacion, p_tipo);
END add_employee;

    -- Implementación del procedimiento para actualizar la información de un empleado existente
    PROCEDURE update_employee(
        p_id_empleado CHAR,
        p_nombre VARCHAR2,
        p_fecha_nacimiento DATE,
        p_fecha_contratacion DATE,
        p_tipo CHAR
    ) IS
BEGIN
UPDATE EMPLEADO
SET nombre = p_nombre,
    fecha_nacimiento = p_fecha_nacimiento,
    fecha_contratacion = p_fecha_contratacion,
    tipo = p_tipo
WHERE ID_empleado = p_id_empleado;
END update_employee;

    -- Implementación del procedimiento para eliminar un empleado
    PROCEDURE delete_employee(p_id_empleado CHAR) IS
BEGIN
DELETE FROM EMPLEADO WHERE ID_empleado = p_id_empleado;
END delete_employee;

    -- Implementación de la función para obtener información detallada de un empleado
    FUNCTION get_employee_info(p_id_empleado CHAR) RETURN VARCHAR2 IS
        v_info VARCHAR2(200);
BEGIN
SELECT 'Nombre: ' || nombre || ', Fecha de Nacimiento: ' || TO_CHAR(fecha_nacimiento, 'YYYY-MM-DD') || ', Fecha de Contratación: ' || TO_CHAR(fecha_contratacion, 'YYYY-MM-DD') || ', Tipo: ' || tipo
INTO v_info
FROM EMPLEADO
WHERE ID_empleado = p_id_empleado;
RETURN v_info;
END get_employee_info;
END zoo_employees;
/

create PACKAGE zoo_food AS
    -- Procedimiento para agregar un nuevo alimento
    PROCEDURE add_food(
        p_id_alimento CHAR,
        p_nombre VARCHAR2,
        p_stock NUMBER,
        p_calor NUMBER
    );

    -- Procedimiento para actualizar la información de un alimento existente
    PROCEDURE update_food(
        p_id_alimento CHAR,
        p_nombre VARCHAR2,
        p_stock NUMBER,
        p_calor NUMBER
    );

    -- Procedimiento para eliminar un alimento
    PROCEDURE delete_food(p_id_alimento CHAR);

    -- Función para obtener información detallada de un alimento
    FUNCTION get_food_info(p_id_alimento CHAR) RETURN VARCHAR2;
END zoo_food;
/

create PACKAGE BODY zoo_food AS
    -- Implementación del procedimiento para agregar un nuevo alimento
    PROCEDURE add_food(
        p_id_alimento CHAR,
        p_nombre VARCHAR2,
        p_stock NUMBER,
        p_calor NUMBER
    ) IS
BEGIN
INSERT INTO ALIMENTO (ID_alimento, nombre, stock, calor)
VALUES (p_id_alimento, p_nombre, p_stock, p_calor);
END add_food;

    -- Implementación del procedimiento para actualizar la información de un alimento existente
    PROCEDURE update_food(
        p_id_alimento CHAR,
        p_nombre VARCHAR2,
        p_stock NUMBER,
        p_calor NUMBER
    ) IS
BEGIN
UPDATE ALIMENTO
SET nombre = p_nombre,
    stock = p_stock,
    calor = p_calor
WHERE ID_alimento = p_id_alimento;
END update_food;

    -- Implementación del procedimiento para eliminar un alimento
    PROCEDURE delete_food(p_id_alimento CHAR) IS
BEGIN
DELETE FROM ALIMENTO WHERE ID_alimento = p_id_alimento;
END delete_food;

    -- Implementación de la función para obtener información detallada de un alimento
    FUNCTION get_food_info(p_id_alimento CHAR) RETURN VARCHAR2 IS
        v_info VARCHAR2(200);
BEGIN
SELECT 'Nombre: ' || nombre || ', Stock: ' || stock || ', Calorías: ' || calor
INTO v_info
FROM ALIMENTO
WHERE ID_alimento = p_id_alimento;
RETURN v_info;
END get_food_info;
END zoo_food;
/

create PACKAGE zoo_tours AS
    -- Procedimiento para agregar un nuevo tour
    PROCEDURE add_tour(
        p_id_tour CHAR,
        p_nombre VARCHAR2,
        p_tiempo NUMBER,
        p_id_empleado CHAR
    );

    -- Procedimiento para actualizar la información de un tour existente
    PROCEDURE update_tour(
        p_id_tour CHAR,
        p_nombre VARCHAR2,
        p_tiempo NUMBER,
        p_id_empleado CHAR
    );

    -- Procedimiento para eliminar un tour
    PROCEDURE delete_tour(p_id_tour CHAR);

    -- Función para obtener información detallada de un tour
    FUNCTION get_tour_info(p_id_tour CHAR) RETURN VARCHAR2;
END zoo_tours;
/

create PACKAGE BODY zoo_tours AS
    -- Implementación del procedimiento para agregar un nuevo tour
    PROCEDURE add_tour(
        p_id_tour CHAR,
        p_nombre VARCHAR2,
        p_tiempo NUMBER,
        p_id_empleado CHAR
    ) IS
BEGIN
INSERT INTO TOUR (ID_tour, nombre, tiempo, ID_empleado)
VALUES (p_id_tour, p_nombre, p_tiempo, p_id_empleado);
END add_tour;

    -- Implementación del procedimiento para actualizar la información de un tour existente
    PROCEDURE update_tour(
        p_id_tour CHAR,
        p_nombre VARCHAR2,
        p_tiempo NUMBER,
        p_id_empleado CHAR
    ) IS
BEGIN
UPDATE TOUR
SET nombre = p_nombre,
    tiempo = p_tiempo,
    ID_empleado = p_id_empleado
WHERE ID_tour = p_id_tour;
END update_tour;

    -- Implementación del procedimiento para eliminar un tour
    PROCEDURE delete_tour(p_id_tour CHAR) IS
BEGIN
DELETE FROM TOUR WHERE ID_tour = p_id_tour;
END delete_tour;

    -- Implementación de la función para obtener información detallada de un tour
    FUNCTION get_tour_info(p_id_tour CHAR) RETURN VARCHAR2 IS
        v_info VARCHAR2(4000);
BEGIN
SELECT 'Nombre: ' || nombre || ', Tiempo: ' || tiempo || ', Guía: ' || ID_empleado
INTO v_info
FROM TOUR
WHERE ID_tour = p_id_tour;

RETURN v_info;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Tour no encontrado.';
WHEN OTHERS THEN
            RETURN 'Error al obtener información del tour.';
END get_tour_info;

END zoo_tours;
/

