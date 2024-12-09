--Creación de Indice para el CASO 3 - 1
CREATE INDEX idx_med_car_id ON MEDICO (car_id);
DROP INDEX idx_med_car_id;

--Creación de indice para el CASO 3 - 2
CREATE INDEX idx_med_sueldo_base ON MEDICO(sueldo_base);
DROP INDEX idx_med_sueldo_base;
