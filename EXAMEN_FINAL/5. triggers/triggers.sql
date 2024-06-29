-- 1. TRIGGER para verificar que la fecha del recorrido sea en el futuro
CREATE OR REPLACE TRIGGER check_fecha
    BEFORE INSERT OR UPDATE ON RECORRIDO
                                FOR EACH ROW
BEGIN
    IF :NEW.fecha < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20001, 'La fecha debe ser en el futuro');
END IF;
END;
/

-- PRUEBA: Este INSERT falla porque la fecha es anterior a la fecha actual
INSERT INTO RECORRIDO (ID_recorrido, fecha, hora, inciden, ID_tour)
VALUES ('R004', TO_DATE('2021-01-01', 'YYYY-MM-DD'), TO_TIMESTAMP('10:00:00', 'HH24:MI:SS'), 0, 'T001');


-- 2. Trigger para verificar que la fecha de nacimiento del empleado sea razonable
CREATE OR REPLACE TRIGGER check_fecha_nacimiento
    BEFORE INSERT OR UPDATE ON EMPLEADO
    FOR EACH ROW
BEGIN
    IF :NEW.fecha_nacimiento < ADD_MONTHS(SYSDATE, -1200) THEN
        RAISE_APPLICATION_ERROR(-20002, 'La fecha de nacimiento no puede ser mayor a 100 años atrás');
    END IF;
END;
/

-- 3. Trigger para asegurarse de que la fecha de contratación no sea en el futuro
CREATE OR REPLACE TRIGGER check_fecha_contratacion
    BEFORE INSERT OR UPDATE ON EMPLEADO
    FOR EACH ROW
BEGIN
    IF :NEW.fecha_contratacion > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20003, 'La fecha de contratación no puede ser en el futuro');
    END IF;
END;
/

-- 4. Trigger para actualizar automáticamente el stock del alimento cada vez que un animal lo consume
CREATE OR REPLACE TRIGGER update_stock_alimento
    AFTER INSERT OR UPDATE ON COME
    FOR EACH ROW
BEGIN
    UPDATE ALIMENTO
    SET stock = stock - :NEW.cantidad
    WHERE ID_alimento = :NEW.ID_alimento;

    IF (SELECT stock FROM ALIMENTO WHERE ID_alimento = :NEW.ID_alimento) < 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Stock no puede ser negativo');
    END IF;
END;
/

-- 5. Trigger para asegurar que un empleado asignado como cuidador esté en la tabla de cuidadores
CREATE OR REPLACE TRIGGER check_empleado_cuidador
    BEFORE INSERT OR UPDATE ON ANIMAL
    FOR EACH ROW
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

-- 6. Trigger para asegurar que un empleado asignado como guía esté en la tabla de guías
CREATE OR REPLACE TRIGGER check_empleado_guia
    BEFORE INSERT OR UPDATE ON TOUR
    FOR EACH ROW
BEGIN
    IF :NEW.ID_empleado IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM GUIA WHERE ID_empleado = :NEW.ID_empleado) THEN
            RAISE_APPLICATION_ERROR(-20006, 'El empleado asignado no es un guía válido');
        END IF;
    END IF;
END;
/

-- 7.  Trigger para asegurar que un empleado asignado como cuidador no esté en otra tabla de tipo de empleado
CREATE OR REPLACE TRIGGER check_tipo_empleado_cuidador
    BEFORE INSERT OR UPDATE ON CUIDADOR
    FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM GUIA WHERE ID_empleado = :NEW.ID_empleado) THEN
        RAISE_APPLICATION_ERROR(-20007, 'El empleado no puede ser guía y cuidador al mismo tiempo');
    END IF;
END;
/

-- PRUEBA: Este INSERT fallas porque 'E004' ya está en la tabla GUIA
INSERT INTO CUIDADOR (ID_empleado, habilidad, experiencia) VALUES ('E004', 'Cuidado de reptiles', 5);


-- 8. Trigger para asegurar que un empleado asignado como guía no esté en otra tabla de tipo de empleado
CREATE OR REPLACE TRIGGER check_tipo_empleado_guia
    BEFORE INSERT OR UPDATE ON GUIA
    FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM CUIDADOR WHERE ID_empleado = :NEW.ID_empleado) THEN
        RAISE_APPLICATION_ERROR(-20008, 'El empleado no puede ser cuidador y guía al mismo tiempo');
    END IF;
END;
/

-- PRUEBA: Este INSERT falla porque 'E001' ya está en la tabla CUIDADOR
INSERT INTO GUIA (ID_empleado, nacion, idiomas) VALUES ('E001', 'Argentina', 'Español, Portugués');


-- 9. Trigger para verificar que la capacidad del recinto no se exceda cuando se agregan animales
CREATE OR REPLACE TRIGGER check_capacidad_recinto
    BEFORE INSERT OR UPDATE ON ANIMAL
    FOR EACH ROW
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

-- PRUEBA: Aumentamos la capacidad del recinto 'R001' para la demostración
UPDATE RECINTO SET capacidad = 1 WHERE ID_recinto = 'R001';

-- Este INSERT debería fallar porque el recinto 'R001' ya tiene su capacidad máxima de 1 animal
INSERT INTO ANIMAL (ID_animal, nombre, ID_especie, ID_empleado, ID_recinto) VALUES ('A004', 'Tiger', 'E001', 'E001', 'R001');

select * from EMPLEADO;


-- 10. Trigger para asegurar que los tours no se superpongan en tiempo para un mismo guía
CREATE OR REPLACE TRIGGER check_tour_time_overlap
    BEFORE INSERT OR UPDATE ON RECORRIDO
    FOR EACH ROW
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

-- Este INSERT debería fallar porque el guía 'E004' ya tiene un recorrido en la misma fecha y hora
INSERT INTO RECORRIDO (ID_recorrido, fecha, hora, inciden, ID_tour)
VALUES ('R005', TO_DATE('2022-01-01', 'YYYY-MM-DD'), TO_TIMESTAMP('10:00:00', 'HH24:MI:SS'), 0, 'T001');


-- 11. Trigger para actualizar la fecha y hora de los tours si la guía se actualiza
CREATE OR REPLACE TRIGGER update_tour_recorrido
    AFTER UPDATE ON TOUR
    FOR EACH ROW
BEGIN
    UPDATE RECORRIDO
    SET fecha = :NEW.fecha, hora = :NEW.hora
    WHERE ID_tour = :OLD.ID_tour;
END;
/

SELECT TRIGGER_NAME, TABLE_NAME, TRIGGER_TYPE, TRIGGERING_EVENT, STATUS
FROM USER_TRIGGERS;

