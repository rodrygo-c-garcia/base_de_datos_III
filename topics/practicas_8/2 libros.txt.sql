-- EJEMPLO SENCILLO DE PROCEDIMIENTO ALMACENADO

set serveroutput on;
CREATE OR REPLACE PROCEDURE saludo 
AS 
BEGIN 
   dbms_output.put_line('Hola a todos'); 
END saludo; 

-- PARA EJECUTAR INVOCAR O EJECUTAR EL PA)
BEGIN
SALUDO;
END;

-- OTRA FORMA PARA EJECUTAR INVOCAR O EJECUTAR EL PA)

execute saludo;



create table Libros(
idlibro int not null,
titulo varchar2(30) not null,
autor varchar2(60) not null,
precio number(5,2)
);

--VALORES
insert into libros values(1,'El quijote','Miguel de Cervantes',454.5);
insert into libros values(2,'Cien años de soledad','Gabriel G. Marquez',545.4);
insert into libros values(3,'El alquimista','Paulo Coehlo',636.3);

-- procedimiento almacenado que incrementa el 1% al precio del libro

set serveroutput on;

create or replace procedure precio_libros
  as
  begin
   update libros set precio=precio+(precio*0.1);
  end precio_libros;

select * from liibros;

execute precio_libros;

select * from liibros;
  ------------------------------------------------------------
me permite ver todos los procedimientos creados

select *from user_objects where object_type='PROCEDURE';
--------------------------------------------------------------
me permite ver el procedimiento saludo

select * from user_procedures where object_name like '%saludo%';
--------------------------------------------------------------
borrar un procedimiento

drop procedure saludo;
---------------------------------------------------------------------