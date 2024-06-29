-- paquete para Operaciones con Animales
-- especificacion
CREATE OR REPLACE PACKAGE zoo_animals AS
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


-- BODY
CREATE OR REPLACE PACKAGE BODY zoo_animals AS
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

-- PRUEBAS
BEGIN
    zoo_animals.add_animal('A004', 'Simba', 'E001', 'E001', 'R002');
END;
/

BEGIN
    zoo_animals.update_animal('A004', 'Simba', 'E001', 'E002', 'R003');
END;
/

BEGIN
    zoo_animals.delete_animal('A004');
END;
/

DECLARE
    animal_info VARCHAR2(200);
BEGIN
    animal_info := zoo_animals.get_animal_info('A003');
    DBMS_OUTPUT.PUT_LINE('Información del animal A003: ' || animal_info);
END;
/

ALTER TRIGGER CHECK_EMPLEADO_CUIDADOR COMPILE;






-- Paquete para Operaciones con Empleados
CREATE OR REPLACE PACKAGE zoo_employees AS
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

CREATE OR REPLACE PACKAGE BODY zoo_employees AS
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




-- Paquete para Operaciones con Alimentos
CREATE OR REPLACE PACKAGE zoo_food AS
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


-- Implementación del paquete para Operaciones con Alimentos (BODY)
CREATE OR REPLACE PACKAGE BODY zoo_food AS
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



---------------------------------
-- Paquete para Operaciones con Tours
CREATE OR REPLACE PACKAGE zoo_tours AS
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

-- BODY
CREATE OR REPLACE PACKAGE BODY zoo_tours AS
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

-- Ejemplo de llamada para agregar un tour
BEGIN
    zoo_tours.add_tour('T004', 'Tour Nocturno', 2.0, 'E007');
END;
/

-- Ejemplo de llamada para actualizar un tour existente
BEGIN
    zoo_tours.update_tour('T001', 'Tour de la Sabana Actualizado', 3.0, 'E004');
END;
/

-- Ejemplo de llamada para eliminar un tour
BEGIN
    zoo_tours.delete_tour('T003');
END;
/

-- Ejemplo de llamada para obtener información detallada de un tour
DECLARE
    tour_info VARCHAR2(4000);
BEGIN
    tour_info := zoo_tours.get_tour_info('T002');
    DBMS_OUTPUT.PUT_LINE('Información del Tour T002: ' || tour_info);
END;
/

