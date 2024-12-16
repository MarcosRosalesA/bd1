-- Select para conocer mejor las tablas
SELECT * FROM TIPO_TRANSACCION_TARJETA;
SELECT * FROM TRANSACCION_TARJETA_CLIENTE;
SELECT * FROM SELECCION_TIPO_TRANSACCION;

--Alternativa Nro 1 para el informe 2 
SELECT
    TO_CHAR(SYSDATE, 'DD-MM-YYYY') AS FECHA,
    UPPER(tipo.cod_tptran_tarjeta) AS CODIGO,
    tipo.nombre_tptran_tarjeta AS DESCRIPCION,
    TRUNC(AVG (ctt.valor_cuota)) AS MONTO_PROMEDIO_TRANSACCION
FROM
    transaccion_tarjeta_cliente ttc
    -- Uso de inner joins para la conexion entre tablas
INNER JOIN
    cuota_transac_tarjeta_cliente ctt ON ttc.nro_tarjeta = ctt.nro_tarjeta AND ttc.nro_transaccion = ctt.nro_transaccion
INNER JOIN
    tipo_transaccion_tarjeta tipo ON ttc.cod_tptran_tarjeta = tipo.cod_tptran_tarjeta}
    -- Filtro para poder revisar solamente lo que es vencimiento de cuota entre junio y diciembre
WHERE
    EXTRACT(MONTH FROM ctt.fecha_venc_cuota) BETWEEN 6 AND 12
GROUP BY
    tipo.cod_tptran_tarjeta, tipo.nombre_tptran_tarjeta
    -- Orden ascendente de lo que son el promedio del valor de la cuota
ORDER BY
    AVG(ctt.valor_cuota) ASC;
    
    
-- ALTERNATIVA 2 - SUBCONSULTA --
-- Se inserta informacion en la tabla, basado en su esquema.
INSERT INTO SELECCION_TIPO_TRANSACCION (FECHA, COD_TIPO_TRANSAC, NOMBRE_TIPO_TRANSAC, MONTO_PROMEDIO)
SELECT
    TO_CHAR(SYSDATE, 'DD-MM-YYYY') AS FECHA,
    t.cod_tptran_tarjeta AS CODIGO,
    UPPER(t.nombre_tptran_tarjeta) AS DESCRIPCION,
    TRUNC(AVG(t.valor_cuota)) AS MONTO_PROMEDIO_TRANSACCION
FROM (
    -- Subconsulta: Selecciona las transacciones vencidas entre junio y diciembre
    SELECT
        ttc.cod_tptran_tarjeta,
        ttc.nro_tarjeta,
        ttc.nro_transaccion,
        ctt.valor_cuota,
        ctt.fecha_venc_cuota,
        tipo.nombre_tptran_tarjeta
    FROM
        transaccion_tarjeta_cliente ttc
        -- Joins que unen 3 tablas
    INNER JOIN
        cuota_transac_tarjeta_cliente ctt ON ttc.nro_tarjeta = ctt.nro_tarjeta
        AND ttc.nro_transaccion = ctt.nro_transaccion
    INNER JOIN
        tipo_transaccion_tarjeta tipo ON ttc.cod_tptran_tarjeta = tipo.cod_tptran_tarjeta
    WHERE
        EXTRACT(MONTH FROM ctt.fecha_venc_cuota) BETWEEN 6 AND 12
    ) t
GROUP BY
    t.cod_tptran_tarjeta, t.nombre_tptran_tarjeta
ORDER BY
    MONTO_PROMEDIO_TRANSACCION ASC;

-- Se hace commit para confirmar
COMMIT;

-- Se hace revisión de tabla
SELECT * FROM SELECCION_TIPO_TRANSACCION
ORDER BY MONTO_PROMEDIO ASC;


-- Actualización tasa de interes basada en SELECCIÓN_TIPO_TRANSACCIÓN --
-- Reduccion del 1% de la tasa de interes basada en la seleccion anterior
UPDATE tipo_transaccion_tarjeta tipo
SET tipo.tasaint_tptran_tarjeta = (tipo.tasaint_tptran_tarjeta - 0.01)
-- Filtro para que tome solo lo que son los codigos de la tabla seleccion tipo transaccion
--creada con la subconsulta
WHERE tipo.COD_TPTRAN_TARJETA IN (
    SELECT selec.COD_TIPO_TRANSAC 
    FROM SELECCION_TIPO_TRANSACCION selec
);
-- Para que tome los cambios
COMMIT;

