SELECT 
    e.nombre AS ESPECIALIDAD_MEDICA,
    COUNT(b.id_bono) AS CANTIDAD_BONOS,
    SUM(b.costo) AS MONTO_PERDIDA, --esto hace la suma de bonos no pagados por especialidad
    MIN(b.fecha_bono) AS FECHA_BONO, -- toma la fecha mas antigua
    CASE 
    -- Con esta sentencia se filta para saber si el bono es cobrable o no, seghun el año actual o anterior
        WHEN EXTRACT(YEAR FROM b.fecha_bono) >= EXTRACT(YEAR FROM SYSDATE) - 1 THEN 'COBRABLE'
        ELSE 'INCOBRABLE'
    END AS ESTADO_DE_COBRO
FROM 
    BONO_CONSULTA b
JOIN 
    ESPECIALIDAD_MEDICA e ON b.esp_id = e.esp_id
WHERE 
    b.id_bono NOT IN (
        SELECT p.id_bono
        FROM PAGOS p
    )
GROUP BY 
    e.nombre,
  CASE 
    --Mismo caso con la sentencia anterior de filtro de cobrable o no. pero es para agruparlo 
      WHEN EXTRACT(YEAR FROM b.fecha_bono) >= EXTRACT(YEAR FROM SYSDATE) - 1 THEN 'COBRABLE'
        ELSE 'INCOBRABLE'
    END
ORDER BY 
--con esto ordena ascendentemente la cantidad de bonos y luego el monto de perdida.
    CANTIDAD_BONOS DESC,
    MONTO_PERDIDA DESC;