DELETE FROM Insumos;
DELETE FROM Equipos;
DELETE FROM Costos;
DELETE FROM Personal;
DELETE FROM Escuelas_Deportivas;
DELETE FROM Encargado;
DELETE FROM Deportes;

SELECT * FROM DEPORTES;
SELECT * FROM ENCARGADO;
SELECT * FROM ESCUELAS_DEPORTIVAS;
SELECT * FROM Costos;

SELECT * FROM Deportes WHERE Nombre_Deporte = 'Fútbol';
SELECT * FROM Escuelas_Deportivas WHERE Ubicacion LIKE '%Ciudad X%';
SELECT * FROM Equipos WHERE Costo_Unitario < 30;
SELECT * FROM Personal WHERE Profesion = 'Entrenador';


