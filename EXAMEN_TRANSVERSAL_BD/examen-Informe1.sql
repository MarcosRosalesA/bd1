--Creacion de vista para el informe 1
CREATE VIEW RESUMEN_CLIENTES_REGION AS
SELECT 
    region.nombre_region AS REGION,  -- Nombre de la región
    COUNT(CASE 
            WHEN SYSDATE - cliente.fecha_inscripcion >= (20 * 365) THEN 1 
         END) AS CLIENTES_20_ANIOS,  -- Clientes con más de 20 años inscritos
    COUNT(*) AS TOTAL_CLIENTES  -- Total general de clientes
FROM 
    CLIENTE cliente
INNER JOIN 
    REGION region ON cliente.COD_REGION = region.COD_REGION
GROUP BY 
    region.nombre_region
ORDER BY 
    CLIENTES_20_ANIOS ASC;  -- Orden por clientes con más de 20 años de inscripción;

SELECT * FROM RESUMEN_CLIENTES_REGION;

CREATE INDEX IDX_REGION ON CLIENTE (COD_REGION);
CREATE INDEX IDX_CLI_REGION ON CLIENTE (COD_REGION, fecha_inscripcion);
