INSERT INTO Deportes (ID_Deporte, Nombre_Deporte) VALUES (28, 'Fútbol');
INSERT INTO Deportes (ID_Deporte, Nombre_Deporte) VALUES (29, 'Baloncesto');
INSERT INTO Deportes (ID_Deporte, Nombre_Deporte) VALUES (30, 'Voleibol');

INSERT INTO Encargado (ID_Encargado, Nombre, Apellido, Telefono, Email) 
VALUES (1, 'Juan', 'Pérez', '123456789', 'juan.perez@email.com');
INSERT INTO Encargado (ID_Encargado, Nombre, Apellido, Telefono, Email) 
VALUES (2, 'María', 'Rodríguez', '987654321', 'maria.rodriguez@email.com');
INSERT INTO Encargado (ID_Encargado, Nombre, Apellido, Telefono, Email) 
VALUES (3, 'Luis', 'Martínez', '456789123', 'luis.martinez@email.com');

INSERT INTO Escuelas_Deportivas (ID_Escuela, Nombre_Escuela, ID_Deporte, ID_Encargado, Ubicacion) 
VALUES (1, 'Escuela Deportiva A', 28, 16, 'Calle 123, Ciudad X');
INSERT INTO Escuelas_Deportivas (ID_Escuela, Nombre_Escuela, ID_Deporte, ID_Encargado, Ubicacion) 
VALUES (2, 'Escuela Deportiva B', 29, 17, 'Avenida 456, Ciudad Y');
INSERT INTO Escuelas_Deportivas (ID_Escuela, Nombre_Escuela, ID_Deporte, ID_Encargado, Ubicacion) 
VALUES (3, 'Escuela Deportiva C', 30, 18 , 'Boulevard 789, Ciudad Z');


INSERT INTO Costos (ID_Costo, ID_Escuela, Tipo_Costo, Monto, Fecha) 
VALUES (1, 21, 'Pago Entrenadores', 5000.00, TO_DATE('2023-09-15', 'YYYY-MM-DD'));
INSERT INTO Costos (ID_Costo, ID_Escuela, Tipo_Costo, Monto, Fecha) 
VALUES (2, 22, 'Compra de Equipos', 3000.00, TO_DATE('2023-09-20', 'YYYY-MM-DD'));
INSERT INTO Costos (ID_Costo, ID_Escuela, Tipo_Costo, Monto, Fecha) 
VALUES (3, 23, 'Pago Insumos', 2000.00, TO_DATE('2023-09-25', 'YYYY-MM-DD'));

INSERT INTO Insumos (ID_Insumo, ID_Costo, Descripcion, Cantidad, Costo_Unitario) 
VALUES (1, 12, 'Balones de fútbol', 10, 50.00);
INSERT INTO Insumos (ID_Insumo, ID_Costo, Descripcion, Cantidad, Costo_Unitario) 
VALUES (2, 13, 'Redes de baloncesto', 5, 100.00);
INSERT INTO Insumos (ID_Insumo, ID_Costo, Descripcion, Cantidad, Costo_Unitario) 
VALUES (3, 14, 'Conos de entrenamiento', 20, 10.00);

INSERT INTO Equipos (ID_Equipo, ID_Costo, Descripcion, Cantidad, Costo_Unitario) 
VALUES (1, 12, 'Uniformes', 20, 25.00);
INSERT INTO Equipos (ID_Equipo, ID_Costo, Descripcion, Cantidad, Costo_Unitario) 
VALUES (2, 13, 'Cestas de baloncesto', 2, 500.00);
INSERT INTO Equipos (ID_Equipo, ID_Costo, Descripcion, Cantidad, Costo_Unitario) 
VALUES (3, 14, 'Pelotas de voleibol', 15, 15.00);

INSERT INTO Personal (ID_Personal, Nombre, Apellido, Profesion, Nacionalidad, ID_Escuela) 
VALUES (1, 'Carlos', 'García', 'Entrenador', 'Chileno', 21);
INSERT INTO Personal (ID_Personal, Nombre, Apellido, Profesion, Nacionalidad, ID_Escuela) 
VALUES (2, 'Lucía', 'Martínez', 'Administrador', 'Argentina', 22);
INSERT INTO Personal (ID_Personal, Nombre, Apellido, Profesion, Nacionalidad, ID_Escuela) 
VALUES (3, 'Diego', 'López', 'Preparador Físico', 'Colombiano', 23);

