-- Declarar variables de enlace
VARIABLE v_fecha_proceso VARCHAR2(20);
EXECUTE :v_fecha_proceso := '01/06/2021';
VARIABLE v_limite_asign  NUMBER;
EXECUTE :v_limite_asign  := 250000;

DECLARE
   -- Definición de tipos y variables
   TYPE t_movilizacion_extra IS VARRAY(5) OF NUMBER;
   v_movilizacion t_movilizacion_extra := t_movilizacion_extra(0.02, 0.04, 0.05, 0.07, 0.09);
   v_anio NUMBER := TO_NUMBER(TO_CHAR(TO_DATE(:v_fecha_proceso, 'DD/MM/YYYY'), 'YYYY'));
   v_mes  NUMBER := TO_NUMBER(TO_CHAR(TO_DATE(:v_fecha_proceso, 'DD/MM/YYYY'), 'MM'));

   -- Cursor para obtener información de profesionales
   CURSOR c_profesionales IS
       SELECT p.numrun_prof, p.nombre, p.appaterno, p.apmaterno, p.cod_profesion, p.cod_comuna, p.cod_tpcontrato
         FROM profesional p
         ORDER BY (SELECT nombre_profesion FROM profesion WHERE cod_profesion = p.cod_profesion), p.appaterno, p.nombre;

   -- Variables para procesar
   r_profesional c_profesionales%ROWTYPE;
   v_cnt_asesorias NUMBER := 0;
   v_sum_honorarios NUMBER := 0;
   v_valor_movilizacion NUMBER := 0;
   v_valor_asignacion_contrato NUMBER := 0;
   v_valor_asignacion_profesion NUMBER := 0;
   v_total_asignaciones NUMBER := 0;
   v_nombre_comuna VARCHAR2(50);

BEGIN
   -- Limpiar tablas antes de iniciar el nuevo proceso
   EXECUTE IMMEDIATE 'TRUNCATE TABLE DETALLE_ASIGNACION_MES';
   EXECUTE IMMEDIATE 'TRUNCATE TABLE RESUMEN_MES_PROFESION';
   EXECUTE IMMEDIATE 'TRUNCATE TABLE ERRORES_PROCESO';

   -- Procesar registros a través del cursor
   OPEN c_profesionales;
   LOOP
      FETCH c_profesionales INTO r_profesional;
      EXIT WHEN c_profesionales%NOTFOUND;

      -- Obtener asesorías y honorarios 
      SELECT NVL(COUNT(*), 0), NVL(SUM(a.honorario), 0)
        INTO v_cnt_asesorias, v_sum_honorarios
        FROM asesoria a
       WHERE a.numrun_prof = r_profesional.numrun_prof
         AND EXTRACT(YEAR FROM a.inicio_asesoria) = v_anio
         AND EXTRACT(MONTH FROM a.inicio_asesoria) = v_mes;

      -- Si no hay asesorías omite el registro
      IF v_cnt_asesorias = 0 THEN
         CONTINUE;
      END IF;

      -- CASE para calcular la movilización según comuna y regla del enunciado
      BEGIN
         SELECT c.nom_comuna INTO v_nombre_comuna FROM comuna c WHERE c.cod_comuna = r_profesional.cod_comuna;
         CASE
            WHEN v_nombre_comuna = 'Santiago' AND v_sum_honorarios < 350000 THEN
               v_valor_movilizacion := ROUND(v_sum_honorarios * v_movilizacion(1));
            WHEN v_nombre_comuna = 'Ñuñoa' THEN
               v_valor_movilizacion := ROUND(v_sum_honorarios * v_movilizacion(2));
            WHEN v_nombre_comuna = 'La Reina' AND v_sum_honorarios < 400000 THEN
               v_valor_movilizacion := ROUND(v_sum_honorarios * v_movilizacion(3));
            WHEN v_nombre_comuna = 'La Florida' AND v_sum_honorarios < 800000 THEN
               v_valor_movilizacion := ROUND(v_sum_honorarios * v_movilizacion(4));
            WHEN v_nombre_comuna = 'Macul' AND v_sum_honorarios < 680000 THEN
               v_valor_movilizacion := ROUND(v_sum_honorarios * v_movilizacion(5));
            ELSE
               v_valor_movilizacion := 0;
         END CASE;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_valor_movilizacion := 0;
      END;

      -- Calcular asignación por tipo de contrato
      BEGIN
         SELECT incentivo INTO v_valor_asignacion_contrato FROM tipo_contrato WHERE cod_tpcontrato = r_profesional.cod_tpcontrato;
         v_valor_asignacion_contrato := ROUND(v_sum_honorarios * (v_valor_asignacion_contrato / 100));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_valor_asignacion_contrato := 0;
      END;

      -- Calcular asignación por profesión
      BEGIN
         SELECT asignacion INTO v_valor_asignacion_profesion FROM porcentaje_profesion WHERE cod_profesion = r_profesional.cod_profesion;
         v_valor_asignacion_profesion := ROUND(v_sum_honorarios * (v_valor_asignacion_profesion / 100));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_valor_asignacion_profesion := 0;
            INSERT INTO errores_proceso (error_id, mensaje_error_oracle, mensaje_error_usr)
                 VALUES (SQ_ERROR.NEXTVAL, 'ORA-01403: No se ha encontrado ningun dato existente', 'Error al obtener porcentaje de asignación RUN: ' || r_profesional.numrun_prof);
      END;

      -- Sumar asignaciones y validar límite
      v_total_asignaciones := v_valor_movilizacion + v_valor_asignacion_contrato + v_valor_asignacion_profesion;

      IF v_total_asignaciones > :v_limite_asign THEN
         INSERT INTO errores_proceso (error_id, mensaje_error_oracle, mensaje_error_usr)
              VALUES (SQ_ERROR.NEXTVAL, 'Error: Límite superado de asignación ' || r_profesional.numrun_prof, 'Asignaciones ajustadas al máximo permitido, antes ('|| v_total_asignaciones ||') ahora (' || :v_limite_asign || ') ' );
         v_total_asignaciones := :v_limite_asign;
      END IF;

      -- Insertar registro detallado en DETALLE_ASIGNACION_MES
      INSERT INTO DETALLE_ASIGNACION_MES (
         mes_proceso, anno_proceso, run_profesional, nombre_profesional, profesion, nro_asesorias, monto_honorarios, monto_movil_extra, monto_asig_tipocont, monto_asig_profesion, monto_total_asignaciones
      ) VALUES (
         v_mes, v_anio, r_profesional.numrun_prof, r_profesional.nombre || ' ' || r_profesional.appaterno,
         (SELECT nombre_profesion FROM profesion WHERE cod_profesion = r_profesional.cod_profesion),
         v_cnt_asesorias, v_sum_honorarios, v_valor_movilizacion, v_valor_asignacion_contrato, v_valor_asignacion_profesion, v_total_asignaciones
      );

   END LOOP;
   CLOSE c_profesionales;

   -- Insertar resumen por profesión
   INSERT INTO RESUMEN_MES_PROFESION (
       anno_mes_proceso, profesion, total_asesorias, monto_total_honorarios, monto_total_movil_extra, monto_total_asig_tipocont, monto_total_asig_prof, monto_total_asignaciones
   ) SELECT TO_CHAR(v_anio) || LPAD(v_mes, 2, '0') AS anno_mes_proceso, p.nombre_profesion,
            NVL(SUM(dam.nro_asesorias), 0), NVL(SUM(dam.monto_honorarios), 0), NVL(SUM(dam.monto_movil_extra), 0),
            NVL(SUM(dam.monto_asig_tipocont), 0), NVL(SUM(dam.monto_asig_profesion), 0), NVL(SUM(dam.monto_total_asignaciones), 0)
     FROM profesion p
     LEFT JOIN DETALLE_ASIGNACION_MES dam ON dam.profesion = p.nombre_profesion AND dam.anno_proceso = v_anio AND dam.mes_proceso = v_mes
   GROUP BY p.nombre_profesion
   ORDER BY p.nombre_profesion;

   -- Confirmar los cambios
   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('Ocurrió un error general: ' || SQLERRM);
END;
/

--Comprobaciones
SELECT * FROM DETALLE_ASIGNACION_MES;
SELECT * FROM RESUMEN_MES_PROFESION;
SELECT * FROM ERRORES_PROCESO;