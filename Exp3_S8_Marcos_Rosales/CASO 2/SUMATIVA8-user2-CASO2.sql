CREATE VIEW V_RECALCULO_PAGOS AS   
SELECT 
    pac.pac_run    AS rut,                                  -- RUT DEL PACIENTE
    pac.dv_run     AS digito,                                  -- DIGITO DE RUT
    sal.descripcion AS sist_salud,                     -- Sistema de Salud del Paciente
    INITCAP(pac.apaterno) || ' ' || INITCAP(pac.pnombre) AS NOMBRE_PACIENTE, -- Nombre del paciente con las iniciales en Mayusculas
    pagos.monto_a_cancelar AS costo,        -- Monto a cancelar de la tabla PAGOS
        CASE -- filtra y calcula cada uno de los casos y aumentar el monto a cancelar
            WHEN pagos.monto_a_cancelar BETWEEN 15000 AND 25000 
                THEN ROUND(pagos.monto_a_cancelar * 1.15)
            WHEN pagos.monto_a_cancelar > 25000 
                THEN ROUND(pagos.monto_a_cancelar * 1.20)
            ELSE pagos.monto_a_cancelar
        END AS Monto_a_cancelar,
    (EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM pac.fecha_nacimiento)) AS edad  -- Calculo de edad
FROM 
    PAG pagos
INNER JOIN 
    PAC pac ON pac.pac_run = (SELECT bono.pac_run FROM BONOS bono WHERE bono.id_bono = pagos.id_bono
    AND TO_TIMESTAMP(bono.hr_consulta, 'HH24:MI')>= TO_TIMESTAMP('17:15', 'HH24:MI')) --Sub consulta para poder filtrar por horario
INNER JOIN 
    SAL sal ON pac.sal_id = sal.sal_id                       
ORDER BY
    pac.pac_run,
    Monto_a_cancelar;

-- Comprobación de que la vista esté creada con la informacion
SELECT * FROM V_RECALCULO_PAGOS;