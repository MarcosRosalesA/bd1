-- Creación de sinonimos para el CASO 3
CREATE PUBLIC SYNONYM MEDICO FOR ADMIN.MEDICO;
CREATE PUBLIC SYNONYM CARGO FOR ADMIN.CARGO;

--Creacion de vista VISTA_AUM_MEDICO_X_CARGO con PRY2205_USER1
SELECT * FROM CARGO;
SELECT * FROM MEDICO WHERE car_id = 400
  AND sueldo_base < 1500000;

--Creación de vista caso 3 - 1
CREATE VIEW VISTA_AUM_MEDICO_X_CARGO AS
SELECT 
    TO_CHAR(med.rut_med, '999G999G999') || '-' || med.dv_run AS RUT_MEDICO,                                   -- RUT del médico
    carg.nombre AS CARGO,                      -- Descripción del cargo
    med.sueldo_base AS SUELDO_ACTUAL,                              -- Salario actual del médico
   TO_CHAR( CASE
        WHEN med.sueldo_base BETWEEN 1000000 AND 3000000 THEN med.sueldo_base * 1.15 -- Incremento del 15%
        WHEN med.sueldo_base > 3000000 THEN med.sueldo_base * 1.10                    -- Incremento del 10%
        ELSE med.sueldo_base                                                      -- Sin incremento
    END,
    '$999G999G999') AS SUELDO_AUMENTADO                                  -- Salario incrementado
FROM 
    MEDICO med
INNER JOIN 
    CARGO carg ON med.car_id = carg.car_id
WHERE
    UPPER(carg.nombre) LIKE '%ATEN%'
ORDER BY SUELDO_AUMENTADO ASC;

-- Revisar la vista caso 3 - 1
SELECT * FROM VISTA_AUM_MEDICO_X_CARGO;

-- Plan de ejecución para la vista creada
EXPLAIN PLAN FOR
SELECT * FROM VISTA_AUM_MEDICO_X_CARGO;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Se crea index con el usuario admin para el caso 3 -1
-- CREATE INDEX idx_med_car_id ON MEDICO (car_id);
-- DROP INDEX idx_med_car_id; --En caso de eliminar para poder ver y comparar

--Creacion de Vista de caso 3 -2
CREATE VIEW VISTA_AUM_MEDICO_X_CARGO_2 AS
SELECT 
    TO_CHAR(med.rut_med, '999G999G999') || '-' || med.dv_run AS RUT_MEDICO,   -- RUT del médico
    carg.nombre AS CARGO,                      -- Descripción del cargo
    med.sueldo_base AS SUELDO_ACTUAL,                              -- Salario actual del médico
   TO_CHAR( CASE
        WHEN med.sueldo_base < 1500000 THEN med.sueldo_base * 1.15                    
        ELSE med.sueldo_base                                                      
    END,
    '$999G999G999') AS SUELDO_AUMENTADO                                  -- Salario incrementado
FROM 
    MEDICO med
INNER JOIN 
    CARGO carg ON med.car_id = carg.car_id
WHERE
   med.car_id = 400 AND med.sueldo_base < 1500000
ORDER BY SUELDO_AUMENTADO ASC;

-- Revision de vista
SELECT * FROM VISTA_AUM_MEDICO_X_CARGO_2;

-- Creacion de indice para el caso 3-2
-- CREATE INDEX idx_med_sueldo_base ON MEDICO(sueldo_base);
-- DROP INDEX idx_med_sueldo_base;

