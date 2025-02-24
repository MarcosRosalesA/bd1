-- PACKAGE para el puntaje extra
CREATE OR REPLACE PACKAGE BODY PKG_PUNTAJE_EXTRA AS
  FUNCTION fn_calcula_puntaje_extra(
    p_exper IN NUMBER,
    p_nacion IN NUMBER,
    p_porcent IN NUMBER,
    p_horas_tot IN NUMBER,
    p_estab_cont IN NUMBER
  ) RETURN NUMBER IS
    v_extra NUMBER;
  BEGIN
    -- Validar parámetros.
    IF p_porcent < 0 OR p_porcent > 100 THEN
      RAISE_APPLICATION_ERROR(-20001, 'El porcentaje debe estar entre 0 y 100.');
    END IF;

    -- Cálculo si más de un establecimiento y más de 30 horas.
    IF p_estab_cont > 1 AND p_horas_tot > 30 THEN
      v_extra := ROUND((p_porcent/100) * (p_exper + p_nacion));
    ELSE
      v_extra := 0;
    END IF;
    
    RETURN v_extra;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END fn_calcula_puntaje_extra;
END PKG_PUNTAJE_EXTRA;
/

-----------------------------------------------------------------------
-- 2. Función para calcular puntaje por experiencia
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_puntaje_experiencia(p_num IN NUMBER) RETURN NUMBER IS
  v_fecha_min DATE;
  v_anios     NUMBER;
  v_puntaje   NUMBER;
  v_err       VARCHAR2(250);
BEGIN
  -- Fecha de contrato más antigua.
  SELECT MIN(fecha_contrato)
    INTO v_fecha_min
  FROM ANTECEDENTES_LABORALES
  WHERE numrun = p_num;

  -- Años de experiencia.
  v_anios := FLOOR(MONTHS_BETWEEN(SYSDATE, v_fecha_min) / 12);

  -- Asigna puntaje según años.
  SELECT ptje_experiencia
    INTO v_puntaje
  FROM PTJE_ANNOS_EXPERIENCIA
  WHERE v_anios BETWEEN rango_annos_ini AND rango_annos_ter;

  RETURN v_puntaje;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_err := 'Postulante sin registros.';
    INSERT INTO ERROR_PROCESO(numrun, rutina_error, mensaje_error)
    VALUES (p_num, 'fn_puntaje_experiencia', v_err);
    COMMIT;
    RETURN 0;
  WHEN OTHERS THEN
    v_err := 'Error: ' || SQLERRM;
    INSERT INTO ERROR_PROCESO(numrun, rutina_error, mensaje_error)
    VALUES (p_num, 'fn_puntaje_experiencia', v_err);
    COMMIT;
    RETURN 0;
END fn_puntaje_experiencia;
/

-----------------------------------------------------------------------
-- 3. Función para puntaje asociado al país
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_puntaje_pais(p_num IN NUMBER) RETURN NUMBER IS
  v_codigo_pais NUMBER;
  v_puntaje     NUMBER;
  v_err         VARCHAR2(250);
BEGIN
  -- Código del país.
  SELECT i.cod_pais
    INTO v_codigo_pais
  FROM POSTULACION_PASANTIA_PERFEC pp
  JOIN PASANTIA_PERFECCIONAMIENTO p ON pp.cod_programa = p.cod_programa
  JOIN INSTITUCION i ON p.cod_inst = i.cod_inst
  WHERE pp.numrun = p_num;

  -- Puntaje del país.
  SELECT ptje_pais
    INTO v_puntaje
  FROM PTJE_PAIS_POSTULA
  WHERE cod_pais = v_codigo_pais;

  RETURN v_puntaje;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_err := 'País no encontrado.';
    INSERT INTO ERROR_PROCESO(numrun, rutina_error, mensaje_error)
    VALUES (p_num, 'fn_puntaje_pais', v_err);
    COMMIT;
    RETURN 0;
  WHEN OTHERS THEN
    v_err := 'Error: ' || SQLERRM;
    INSERT INTO ERROR_PROCESO(numrun, rutina_error, mensaje_error)
    VALUES (p_num, 'fn_puntaje_pais', v_err);
    COMMIT;
    RETURN 0;
END fn_puntaje_pais;
/

-----------------------------------------------------------------------
-- 4. Procedimiento principal para postulantes
-----------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE prc_procesa_postulantes(p_porcent_extra IN NUMBER) IS
  CURSOR c_postulantes IS
    SELECT numrun,
           pnombre || ' ' || NVL(snombre,'') || ' ' || apaterno || ' ' || amaterno AS nombre_completo
    FROM ANTECEDENTES_PERSONALES
    ORDER BY numrun;

  v_horas_tot   NUMBER;
  v_estab_count  NUMBER;
  v_puntaje_exp NUMBER;
  v_puntaje_pais NUMBER;
  v_puntaje_extra NUMBER;
  v_err         VARCHAR2(250);
BEGIN
  -- Truncar tablas de resultados.
  EXECUTE IMMEDIATE 'TRUNCATE TABLE DETALLE_PUNTAJE_POSTULACION';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ERROR_PROCESO';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE RESULTADO_POSTULACION';

  -- Procesar postulantes.
  FOR r_post IN c_postulantes LOOP
    BEGIN
      v_puntaje_exp := fn_puntaje_experiencia(r_post.numrun);
      v_puntaje_pais := fn_puntaje_pais(r_post.numrun);

      -- Obtener horas totales y establecimientos.
      SELECT NVL(SUM(horas_semanales), 0),
             NVL(COUNT(*), 0)
        INTO v_horas_tot, v_estab_count
      FROM ANTECEDENTES_LABORALES
      WHERE numrun = r_post.numrun;

      -- Calcular puntaje extra.
      v_puntaje_extra := PKG_PUNTAJE_EXTRA.fn_calcula_puntaje_extra(
                           v_puntaje_exp,
                           v_puntaje_pais,
                           p_porcent_extra,
                           v_horas_tot,
                           v_estab_count);

      -- Insertar en resultados.
      INSERT INTO DETALLE_PUNTAJE_POSTULACION (run_postulante, nombre_postulante, ptje_annos_exp, ptje_pais_postula, ptje_extra)
      VALUES (r_post.numrun, r_post.nombre_completo, v_puntaje_exp, v_puntaje_pais, v_puntaje_extra);
    EXCEPTION
      WHEN OTHERS THEN
        v_err := 'Error en postulante ' || r_post.numrun || ': ' || SQLERRM;
        INSERT INTO ERROR_PROCESO(numrun, rutina_error, mensaje_error)
        VALUES (r_post.numrun, 'prc_procesa_postulantes', v_err);
        COMMIT;
    END;
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END prc_procesa_postulantes;
/

-----------------------------------------------------------------------
-- 5. Trigger para el resultado de la postulación
-----------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_resultado_postulacion
AFTER INSERT ON DETALLE_PUNTAJE_POSTULACION
FOR EACH ROW
DECLARE
  v_puntaje_final NUMBER;
  v_resultado     VARCHAR2(20);
BEGIN
  -- Validar puntajes.
  IF :NEW.ptje_annos_exp IS NULL OR :NEW.ptje_pais_postula IS NULL OR :NEW.ptje_extra IS NULL THEN
    RAISE_APPLICATION_ERROR(-20002, 'Puntajes no pueden ser nulos.');
  END IF;

  -- Calcular puntaje final.
  v_puntaje_final := :NEW.ptje_annos_exp + :NEW.ptje_pais_postula + :NEW.ptje_extra;

  -- Asignar resultado según puntaje.
  IF v_puntaje_final >= 2500 THEN
    v_resultado := 'SELECCIONADO';
  ELSE
    v_resultado := 'NO SELECCIONADO';
  END IF;

  -- Actualizar o insertar en RESULTADO_POSTULACION.
  UPDATE RESULTADO_POSTULACION
    SET ptje_final_post = v_puntaje_final,
        resultado_post = v_resultado
  WHERE run_postulante = :NEW.run_postulante;

  IF SQL%ROWCOUNT = 0 THEN
    INSERT INTO RESULTADO_POSTULACION (run_postulante, ptje_final_post, resultado_post)
    VALUES (:NEW.run_postulante, v_puntaje_final, v_resultado);
  END IF;
END;
/ 

-----------------------------------------------------------------------
-- Ejecución y validación final
-----------------------------------------------------------------------
-- Ejemplo de ejecución:
BEGIN
  prc_procesa_postulantes(35); -- Parámetro válido.
END;
/ 


-- Consulta de resultados:
SELECT * FROM DETALLE_PUNTAJE_POSTULACION;
SELECT * FROM RESULTADO_POSTULACION;
SELECT * FROM ERROR_PROCESO;
