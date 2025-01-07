DECLARE
    -- Variable BIND
    v_periodo VARCHAR2(7) := '03/2024';

    -- Variables 
    v_id_cliente CLIENTE.ID_CLI%TYPE;
    v_rut_sdig CLIENTE.NUMRUN_CLI%TYPE;
    v_rut_dig CLIENTE.DVRUN_CLI%TYPE;
    v_nombre CLIENTE.PNOMBRE_CLI%TYPE;
    v_apellido CLIENTE.APPATERNO_CLI%TYPE;
    v_apellidoM CLIENTE.APMATERNO_CLI%TYPE;
    v_renta CLIENTE.RENTA%TYPE;
    v_comuna COMUNA.NOMBRE_COMUNA%TYPE;
    v_fecha_nacimiento CLIENTE.FECHA_NAC_CLI%TYPE;
    v_nombre_completo VARCHAR2(100);
    v_edad NUMBER;
    v_puntaje NUMBER := 0;
    v_correo VARCHAR2(100);
    v_rut VARCHAR2(20);
    v_tipo_cliente TIPO_CLIENTE.NOMBRE_TIPO_CLI%TYPE;

    -- Contadores
    v_total_client NUMBER := 0;
    v_procesados_client NUMBER := 0;
    
    
    CURSOR control_clientes IS
        SELECT 
            c.ID_CLI,
            c.NUMRUN_CLI,
            c.DVRUN_CLI,
            c.PNOMBRE_CLI,
            c.APPATERNO_CLI,
            c.APMATERNO_CLI,
            c.RENTA,
            c.FECHA_NAC_CLI,
            EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM c.FECHA_NAC_CLI) AS EDAD,
            co.NOMBRE_COMUNA,
            t.NOMBRE_TIPO_CLI
        FROM CLIENTE c
        INNER JOIN COMUNA co ON c.ID_COMUNA = co.ID_COMUNA
        INNER JOIN TIPO_CLIENTE t ON c.ID_TIPO_CLI = t.ID_TIPO_CLI;

BEGIN
    -- Truncar la tabla DETALLE_DE_CLIENTES
    EXECUTE IMMEDIATE 'TRUNCATE TABLE DETALLE_DE_CLIENTES';

    -- Contar el total de clientes para recorrer
    SELECT COUNT(*) INTO v_total_client FROM CLIENTE;

    -- Procesar clientes uno a uno
    FOR cliente IN control_clientes LOOP     
        v_id_cliente := cliente.ID_CLI;
        v_rut := cliente.NUMRUN_CLI;
        v_nombre_completo := cliente.APPATERNO_CLI || ' ' || cliente.APMATERNO_CLI || ' ' || cliente.PNOMBRE_CLI;
        v_renta := cliente.RENTA;
        v_comuna := cliente.NOMBRE_COMUNA;
        v_tipo_cliente := cliente.NOMBRE_TIPO_CLI;
        v_fecha_nacimiento := cliente.FECHA_NAC_CLI;
        v_edad := cliente.EDAD;

        --  Renta > 700k y no vive en comunas
        IF v_renta > 700000 AND v_comuna NOT IN ('La Reina', 'Las Condes', 'Vitacura') THEN
            v_puntaje := ROUND(v_renta * 0.03);

        --  Cliente Internacional o VIP, puntaje por edad
        ELSIF v_tipo_cliente IN ('Internacional', 'VIP') THEN
            v_puntaje := v_edad * 30;

        --  Aplicar porcentaje de TRAMO_EDAD si puntaje sigue siendo 0
        ELSE
            SELECT porcentaje INTO v_puntaje
            FROM (
                SELECT porcentaje
                FROM TRAMO_EDAD
                WHERE v_edad BETWEEN tramo_inf AND tramo_sup
                ORDER BY tramo_inf
            )
            WHERE ROWNUM = 1;
        END IF;
        
        -- CORREO
        v_correo := LOWER(cliente.APPATERNO_CLI) || v_edad || '*' || SUBSTR(UPPER(cliente.PNOMBRE_CLI), 1, 1) ||
                    TO_CHAR(v_fecha_nacimiento, 'DD') || SUBSTR(v_periodo, 1, 2) || '@LogiCarg.cl';

        -- Insertar los datos procesados en DETALLE_DE_CLIENTES
        INSERT INTO DETALLE_DE_CLIENTES (IDC, RUT, CLIENTE, EDAD, PUNTAJE, CORREO_CORP, PERIODO)
        VALUES (v_id_cliente, v_rut, v_nombre_completo, v_edad, v_puntaje, v_correo, v_periodo);

        -- Incrementar contador de clientes procesados
        v_procesados_client := v_procesados_client + 1;
    END LOOP;

    -- Confirmar transacciones si se procesaron todos los clientes
    IF v_procesados_client = v_total_client THEN
        DBMS_OUTPUT.PUT_LINE('Proceso completado exitosamente. Clientes procesados: ' || v_procesados_client);
        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error: No se procesaron todos los clientes. Rollback ejecutado.');
        ROLLBACK;
    END IF;
END;

SELECT * FROM DETALLE_DE_CLIENTES ORDER BY 1;