--Creacion de tabla para guardar los datos del caso 1
CREATE TABLE RECAUDACION_BONOS_MEDICOS (
    RUT_MEDICO NUMBER(10),
    NOMBRE_MEDICO VARCHAR2(100),
    TOTAL_RECAUDADO NUMBER(10,2),
    UNIDAD_MEDICA VARCHAR2(100)
    );

INSERT INTO RECAUDACION_BONOS_MEDICOS (RUT_MEDICO, NOMBRE_MEDICO, TOTAL_RECAUDADO, UNIDAD_MEDICA)
SELECT 
    m.rut_med AS RUT_MEDICO,
    CONCAT(CONCAT(m.pnombre, ' ' || m.apaterno), ' ' || m.amaterno) AS NOMBRE_MEDICO,
    SUM(b.costo) AS TOTAL_RECAUDADO,
    u.nombre AS UNIDAD_MEDICA
FROM 
    BONO_CONSULTA b
JOIN 
    MEDICO m ON b.rut_med = m.rut_med --Asociacion de bono y medicos
JOIN 
    UNIDAD_CONSULTA u ON m.uni_id = u.uni_id --Asociacion de medico y consultas
WHERE 
    m.car_id NOT IN (
        SELECT car_id 
        FROM CARGO 
       WHERE car_id IN ('100', '500', '600') -- Cargos excluidos
    )
GROUP BY 
    m.rut_med, 
    CONCAT(CONCAT(m.pnombre, ' ' || m.apaterno), ' ' || m.amaterno),
    u.nombre
ORDER BY 
    TOTAL_RECAUDADO;
    
    --Commit para confirmar los datos y me deje consultarlos
 COMMIT;
    -- consulta de data
SELECT * 
FROM RECAUDACION_BONOS_MEDICOS;
