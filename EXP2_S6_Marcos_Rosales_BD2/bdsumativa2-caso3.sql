INSERT INTO CANT_BONOS_PACIENTES_ANNIO (ANNIO_CALCULO, PAC_RUN, DV_RUN, EDAD, CANTIDAD_BONOS, MONTO_TOTAL_BONOS, SISTEMA_SALUD)
SELECT 
    EXTRACT(YEAR FROM SYSDATE) AS ANNIO_CALCULO,
    p.pac_run,
    p.dv_run,
    (EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM p.fecha_nacimiento)) AS edad,
    COUNT(b.id_bono) AS cantidad_bonos,
    SUM(b.costo) AS monto_total_bonos,
    s.descripcion AS sistema_salud
FROM 
    PACIENTE p
JOIN 
    BONO_CONSULTA b ON p.pac_run = b.pac_run
JOIN 
    SALUD s ON p.sal_id = s.sal_id
WHERE 
    EXTRACT(YEAR FROM b.fecha_bono) = EXTRACT(YEAR FROM SYSDATE)  -- Año actual
GROUP BY 
    p.pac_run, p.dv_run, p.fecha_nacimiento, s.descripcion
HAVING 
    SUM(b.costo) <= (
        SELECT ROUND(AVG(monto_total_paciente), 2) -- Promedio de montos totales por paciente en el año anterior
        FROM (
            SELECT 
                b.pac_run,
                SUM(b.costo) AS monto_total_paciente
            FROM 
                BONO_CONSULTA b
            WHERE 
                EXTRACT(YEAR FROM b.fecha_bono) = EXTRACT(YEAR FROM SYSDATE) - 1  -- Año anterior
            GROUP BY 
                b.pac_run
        )
    )
ORDER BY 
    monto_total_bonos DESC,
    edad DESC;
COMMIT;
SELECT * FROM CANT_BONOS_PACIENTES_ANNIO;