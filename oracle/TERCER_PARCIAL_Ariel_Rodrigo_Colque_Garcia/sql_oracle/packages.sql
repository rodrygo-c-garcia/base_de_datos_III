-- PAQUETE PARA GESTONAR LA RELACION ENTRE LIBROS Y AUTORES
-- definicion del paquete
CREATE OR REPLACE PACKAGE pkg_libro_autor IS
    PROCEDURE almacenar_libro_autor (p_isbn IN CHAR, p_id_autor IN CHAR, p_rol_autor IN VARCHAR2);
    PROCEDURE ver_autores_libro (p_isbn IN CHAR);
    FUNCTION contar_autores_libro (p_isbn IN CHAR) RETURN NUMBER;
END pkg_libro_autor;

-- cuerpo
CREATE OR REPLACE PACKAGE BODY pkg_libro_autor AS
    -- procedimiento que almacena los autores y sus libros correspondientes
    PROCEDURE almacenar_libro_autor (p_isbn IN CHAR, p_id_autor IN CHAR, p_rol_autor IN VARCHAR2) IS
    BEGIN
        INSERT INTO LIBRO_AUTOR (ISBN, ID_AUTOR, ROL_AUTOR)
        VALUES (p_isbn, p_id_autor, p_rol_autor);
    END almacenar_libro_autor;

    -- procedimiento que muestra los autores de un libro
    PROCEDURE ver_autores_libro (p_isbn IN CHAR) IS
    BEGIN
        FOR c IN (SELECT A.ID_AUTOR, A.NOMBRES, LA.ROL_AUTOR, L.TITULO
                  FROM AUTOR A
                        JOIN LIBRO_AUTOR LA ON A.ID_AUTOR = LA.ID_AUTOR
                        JOIN LIBRO L ON LA.ISBN = L.ISBN
                  WHERE LA.ISBN = p_isbn)
            LOOP
                DBMS_OUTPUT.PUT_LINE(' ');
                DBMS_OUTPUT.PUT_LINE('TITULO LIBRO: ' || c.TITULO);
                DBMS_OUTPUT.PUT_LINE('ID AUTOR: ' || c.ID_AUTOR);
                DBMS_OUTPUT.PUT_LINE('NOMBRES: ' || c.NOMBRES);
                DBMS_OUTPUT.PUT_LINE('ROL: ' || c.ROL_AUTOR);
            END LOOP;
    END ver_autores_libro;

    -- funcion que cuenta los autores de un libro
    FUNCTION contar_autores_libro (p_isbn IN CHAR) RETURN NUMBER IS
        v_contador NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_contador
        FROM LIBRO_AUTOR
        WHERE ISBN = p_isbn;

        RETURN v_contador;
    END contar_autores_libro;
END pkg_libro_autor;

-- verficamos si hay error en el paquete creado
SELECT * FROM USER_ERRORS WHERE NAME = 'PKG_LIBRO_AUTOR';

BEGIN
    pkg_libro_autor.almacenar_libro_autor('9781234567890', 'A001', 'Autor Principal');
    pkg_libro_autor.almacenar_libro_autor('9781234567891', 'A002', 'Co-Autor');
    pkg_libro_autor.almacenar_libro_autor('9781234567892', 'A003', 'Editor');
    pkg_libro_autor.almacenar_libro_autor('9781234567893', 'A004', 'Autor Principal');
    pkg_libro_autor.almacenar_libro_autor('9781234567894', 'A005', 'Co-Autor');
    pkg_libro_autor.almacenar_libro_autor('9781234567895', 'A006', 'Co-Autor');
END;
/

-- registrar autore y su libro correspondiente
BEGIN
    pkg_libro_autor.almacenar_libro_autor('9781234567895', 'A002', 'Autor Principal');
END;

-- ver autores de un libro
BEGIN
    pkg_libro_autor.ver_autores_libro('9781234567895');
END;

-- consultar cuantos autores tiene un libro
BEGIN
    DBMS_OUTPUT.PUT_LINE('Autores del Libro: ' || pkg_libro_autor.contar_autores_libro('9781234567892'));
END;

SELECT * FROM LIBRO;
SELECT * FROM AUTOR;
SELECT * FROM LIBRO_AUTOR;


-- PAQUETE PARA LA GESTION DE PRESTAMOS

CREATE OR REPLACE PACKAGE pkg_gestion_prestamo AS
    -- Función que devuelve la cantidad de ejemplares disponibles de un libro en particular.
    FUNCTION ejemplares_disponibles (p_isbn IN CHAR) RETURN NUMBER;

    -- Función que verifica si un usuario tiene un préstamo activo para un libro en particular.
    FUNCTION tiene_prestamo_activo (p_id_usuario IN CHAR, p_isbn IN CHAR) RETURN BOOLEAN;

    -- Procedimiento que realiza un préstamo de un libro a un usuario.
    -- Verifica si hay ejemplares disponibles y si el usuario no tiene un préstamo activo para el mismo libro.
    PROCEDURE realizar_prestamo (p_id_usuario IN CHAR, p_isbn IN CHAR, p_id_empleado IN CHAR);

    -- Procedimiento que realiza la devolución de un libro por parte de un usuario.
    -- Actualiza la fecha de devolución y aumenta la cantidad de ejemplares disponibles del libro.
    PROCEDURE realizar_devolucion (p_id_usuario IN CHAR, p_isbn IN CHAR);

    -- Procedimiento que calcula e inserta una multa para un usuario que ha devuelto un libro con retraso.
    PROCEDURE calcular_e_insertar_multa (p_id_usuario IN CHAR, p_isbn IN CHAR);
END;
/

CREATE OR REPLACE PACKAGE BODY pkg_gestion_prestamo AS
    -- función para consultar la disponibilidad de un libro
    FUNCTION ejemplares_disponibles (p_isbn IN CHAR) RETURN NUMBER IS
        v_ejemplares NUMBER;
    BEGIN
        SELECT EJEMPLARES_DISPONIBLES
        INTO v_ejemplares
        FROM LIBRO
        WHERE ISBN = p_isbn;

        RETURN v_ejemplares;
    END ejemplares_disponibles;

    -- función para verificar si un usuario tiene un préstamo activo para un libro
    FUNCTION tiene_prestamo_activo (p_id_usuario IN CHAR, p_isbn IN CHAR) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM PRESTAMO
        WHERE ID_USUARIO = p_id_usuario AND ISBN = p_isbn AND FECHA_DEVOLUCION IS NULL;

        RETURN v_count > 0;
    END tiene_prestamo_activo;

    -- procedimiento para realizar un préstamo
    PROCEDURE realizar_prestamo (p_id_usuario IN CHAR, p_isbn IN CHAR, p_id_empleado IN CHAR) IS
        v_ejemplares NUMBER;
    BEGIN
        v_ejemplares := ejemplares_disponibles(p_isbn);

        IF v_ejemplares > 0 THEN
            INSERT INTO PRESTAMO (ID_USUARIO, ISBN, ID_EMPLEADO, FECHA_PRESTAMO)
            VALUES (p_id_usuario, p_isbn, p_id_empleado, SYSDATE);

            UPDATE LIBRO
            SET EJEMPLARES_DISPONIBLES = EJEMPLARES_DISPONIBLES - 1
            WHERE ISBN = p_isbn;
        ELSE
            DBMS_OUTPUT.PUT_LINE('No hay ejemplares disponibles para el libro con ISBN: ' || p_isbn);
        END IF;
    END realizar_prestamo;

    -- procedimiento para realizar una devolución
    PROCEDURE realizar_devolucion (p_id_usuario IN CHAR, p_isbn IN CHAR) IS
    BEGIN
        IF (tiene_prestamo_activo(p_id_usuario, p_isbn)) THEN

            UPDATE PRESTAMO
            SET FECHA_DEVOLUCION = TO_DATE('2024-06-29', 'YYYY-MM-DD')
            WHERE ID_USUARIO = p_id_usuario AND ISBN = p_isbn AND FECHA_DEVOLUCION IS NULL;

            UPDATE LIBRO
            SET EJEMPLARES_DISPONIBLES = EJEMPLARES_DISPONIBLES + 1
            WHERE ISBN = p_isbn;
        ELSE
            DBMS_OUTPUT.PUT_LINE('El usuario con el ID: ' || p_id_usuario || ' no tiene prestamos activos con el libro ' || p_isbn);
        END IF;
    END realizar_devolucion;


    -- procedimiento para calcular e insertar una multa
    PROCEDURE calcular_e_insertar_multa (p_id_usuario IN CHAR, p_isbn IN CHAR) IS
        v_fecha_prestamo DATE;
        v_fecha_devolucion DATE;
        v_dias_retraso NUMBER;
        v_multa NUMBER;
        v_count_estudiante NUMBER;
        v_count_profesor NUMBER;
    BEGIN
        IF tiene_prestamo_activo(p_id_usuario, p_isbn) THEN
            DBMS_OUTPUT.PUT_LINE('El usuario aun tiene un préstamo activo para el libro con ISBN: ' || p_isbn);
        ELSE
            SELECT FECHA_PRESTAMO, FECHA_DEVOLUCION
            INTO v_fecha_prestamo, v_fecha_devolucion
            FROM PRESTAMO
            WHERE ID_USUARIO = p_id_usuario AND ISBN = p_isbn AND FECHA_DEVOLUCION IS NOT NULL;

            v_dias_retraso := TRUNC(v_fecha_devolucion - v_fecha_prestamo) - 5;

            IF v_dias_retraso > 0 THEN
                -- Verificar si el usuario es un estudiante
                SELECT COUNT(*)
                INTO v_count_estudiante
                FROM ESTUDIANTE
                WHERE ID_ESTUDIANTE = p_id_usuario;

                -- Verificar si el usuario es un profesor
                SELECT COUNT(*)
                INTO v_count_profesor
                FROM PROFESOR
                WHERE ID_PROFESOR = p_id_usuario;

                -- Establecer el valor de la multa en función del tipo de usuario
                IF v_count_estudiante > 0 THEN
                    v_multa := v_dias_retraso * 2.5;
                ELSIF v_count_profesor > 0 THEN
                    v_multa := v_dias_retraso * 10;
                END IF;

                INSERT INTO MULTA (ID_USUARIO, ISBN, FECHA_MULTA, MONTO, TIPO_USUARIO, DIAS_RETRASO, MULTA_DIA)
                VALUES (p_id_usuario, p_isbn, SYSDATE, v_multa, CASE
                    WHEN v_count_estudiante > 0 THEN 'Estudiante'
                    WHEN v_count_profesor > 0 THEN 'Profesor'
                    ELSE 'Otro'
                    END, v_dias_retraso, CASE
                    WHEN v_count_estudiante > 0 THEN 2.5
                    WHEN v_count_profesor > 0 THEN 10
                    ELSE 0
                    END);
            END IF;
        END IF;
    END calcular_e_insertar_multa;
END pkg_gestion_prestamo;
/

-- verificar errores del package
SELECT * FROM USER_ERRORS WHERE NAME = 'pkg_gestion_prestamo';

-- consultamos si un libro tiene ejemplares disponibles
SELECT pkg_gestion_prestamo.EJEMPLARES_DISPONIBLES ('9781234567892') AS Ejemplares FROM dual;

-- prestamo de un libro
SELECT * FROM USUARIO;
SELECT * FROM LIBRO;
SELECT * FROM EMPLEADO;

BEGIN
    pkg_gestion_prestamo.realizar_prestamo('U123456789', '9781234567893', 'E123456789');
END;

BEGIN
    pkg_gestion_prestamo.realizar_prestamo('U123456789', '9781234567890', 'E123456789'); -- devuelto TO_DATE('2024-07-29', 'YYYY-MM-DD')
    pkg_gestion_prestamo.realizar_prestamo('U777888999', '9781234567894', 'E987654321'); -- devuelto TO_DATE('2024-06-24', 'YYYY-MM-DD')
    pkg_gestion_prestamo.realizar_prestamo('U777888999', '9781234567892', 'E123456789');
    pkg_gestion_prestamo.realizar_prestamo('U888999000', '9781234567892', 'E987654321'); -- devuelto
    pkg_gestion_prestamo.realizar_prestamo('U666777888', '9781234567892', 'E123456789');
END;

BEGIN
    pkg_gestion_prestamo.realizar_prestamo('U123456789', '9781234567892', 'E123456789');
END;

SELECT * FROM PRESTAMO;
SELECT * FROM HISTORIAL_TRANSACCION;

-- si un usario tiene o no un prestamo activo
DECLARE
    v_prestamo_activo BOOLEAN;
BEGIN
    v_prestamo_activo := pkg_gestion_prestamo.tiene_prestamo_activo('U666777888', '9781234567892');

    IF v_prestamo_activo THEN
        DBMS_OUTPUT.PUT_LINE('El usuario tiene un préstamo activo para el libro especificado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('El usuario NO tiene un préstamo activo para el libro especificado.');
    END IF;
END;
/

-- devolucion de un libro
BEGIN
    pkg_gestion_prestamo.realizar_devolucion('U888999000', '9781234567892');
END;

BEGIN
    pkg_gestion_prestamo.realizar_devolucion('U777888999', '9781234567894');
END;

SELECT * FROM PRESTAMO;
SELECT * FROM HISTORIAL_TRANSACCION;

-- calcular e insertar multa
BEGIN
    pkg_gestion_prestamo.calcular_e_insertar_multa('U888999000', '9781234567892');
END;

SELECT * FROM MULTA;