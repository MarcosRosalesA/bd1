--Todos estos comandos fueron hechos por el usuario ADMIN
-- Creación de usuario PRY2205_USER1
CREATE USER PRY2205_USER1 IDENTIFIED BY "Markos02.2905"
DEFAULT TABLESPACE DATA
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON DATA;

-- Creación de usaurio PRY2205_USER2
CREATE USER PRY2205_USER2 IDENTIFIED BY "Markos02.2905"
DEFAULT TABLESPACE DATA
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON DATA;

-- Permiso para el usuario PRY2205_USER1 
-- Con el permiso de creación de tabla podrá crear Indices ya que es Oracle Cloud
GRANT CREATE TABLE TO PRY2205_USER1;
GRANT CREATE VIEW TO PRY2205_USER1;
GRANT CREATE SYNONYM TO PRY2205_USER1;
GRANT CREATE SESSION TO PRY2205_USER1;

-- Permitir que cree sinónimos públicos
GRANT CREATE PUBLIC SYNONYM TO PRY2205_USER1;

--¨Permiso para el usuario PRY2205_USER2
GRANT CREATE VIEW TO PRY2205_USER2;
GRANT CREATE SESSION TO PRY2205_USER2;

-- Creación de rol PRY2205_ROL_D
CREATE ROLE PRY2205_ROL_D;

-- Creación de rol PRY2205_ROL_P
CREATE ROLE PRY2205_ROL_P;
-- Permisos para el Rol P El cual podrá hacer procedimientos y funciones
GRANT CREATE PROCEDURE TO PRY2205_ROL_P;


-- Dar permisos en las tablas al rol PRY2205_ROL_D que estará asociado al usuario PRY2205_USER2
-- Las tablas fueron creadas con el usuario admin antes de comenzar a desarrollar.
GRANT SELECT ON MEDICO TO PRY2205_ROL_D;
GRANT SELECT ON CARGO TO PRY2205_ROL_D;

-- Asignar el rol al usuario
GRANT PRY2205_ROL_D TO PRY2205_USER2;

-- ASignación de Permisos para el usuario PRY2205_USER2 para el caso 2;
-- Esto se debe ejecutar luego de crear los sinonimos
GRANT SELECT ON BONOS TO PRY2205_USER2;
GRANT SELECT ON PAG TO PRY2205_USER2;
GRANT SELECT ON PAC TO PRY2205_USER2;
GRANT SELECT ON SAL TO PRY2205_USER2;

-- Como la base de datos y sus tablas fue creado con el usuario ADMIN se dará permisos al usuario PRY2205_USER1
GRANT SELECT ON MEDICO TO PRY2205_USER1;
GRANT SELECT ON CARGO TO PRY2205_USER1;
