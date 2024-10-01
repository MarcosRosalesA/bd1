-- Crear secuencia para la tabla Deportes
CREATE SEQUENCE Seq_Deportes START WITH 1 INCREMENT BY 1;

-- Crear tabla Deportes
CREATE TABLE Deportes (
    ID_Deporte NUMBER PRIMARY KEY,
    Nombre_Deporte VARCHAR2(50) NOT NULL
);

-- Crear trigger para insertar valores automáticos en la tabla Deportes
CREATE OR REPLACE TRIGGER Trigger_Deportes_BI
BEFORE INSERT ON Deportes
FOR EACH ROW
BEGIN
  :NEW.ID_Deporte := Seq_Deportes.NEXTVAL;
END;
/

-- Crear secuencia para la tabla Encargado
CREATE SEQUENCE Seq_Encargado START WITH 1 INCREMENT BY 1;

-- Crear tabla Encargado
CREATE TABLE Encargado (
    ID_Encargado NUMBER PRIMARY KEY,
    Nombre VARCHAR2(50) NOT NULL,
    Apellido VARCHAR2(50) NOT NULL,
    Telefono VARCHAR2(15),
    Email VARCHAR2(100)
);

-- Crear trigger para insertar valores automáticos en la tabla Encargado
CREATE OR REPLACE TRIGGER Trigger_Encargado_BI
BEFORE INSERT ON Encargado
FOR EACH ROW
BEGIN
  :NEW.ID_Encargado := Seq_Encargado.NEXTVAL;
END;
/

-- Crear secuencia para la tabla Escuelas_Deportivas
CREATE SEQUENCE Seq_Escuelas_Deportivas START WITH 1 INCREMENT BY 1;

-- Crear tabla Escuelas Deportivas
CREATE TABLE Escuelas_Deportivas (
    ID_Escuela NUMBER PRIMARY KEY,
    Nombre_Escuela VARCHAR2(100) NOT NULL,
    ID_Deporte NUMBER,
    ID_Encargado NUMBER,
    Ubicacion VARCHAR2(150),
    CONSTRAINT FK_Deporte FOREIGN KEY (ID_Deporte) REFERENCES Deportes(ID_Deporte),
    CONSTRAINT FK_Encargado FOREIGN KEY (ID_Encargado) REFERENCES Encargado(ID_Encargado)
);

-- Crear trigger para insertar valores automáticos en la tabla Escuelas Deportivas
CREATE OR REPLACE TRIGGER Trigger_Escuelas_Deportivas_BI
BEFORE INSERT ON Escuelas_Deportivas
FOR EACH ROW
BEGIN
  :NEW.ID_Escuela := Seq_Escuelas_Deportivas.NEXTVAL;
END;
/

-- Crear secuencia para la tabla Personal
CREATE SEQUENCE Seq_Personal START WITH 1 INCREMENT BY 1;

-- Crear tabla Personal
CREATE TABLE Personal (
    ID_Personal NUMBER PRIMARY KEY,
    Nombre VARCHAR2(50) NOT NULL,
    Apellido VARCHAR2(50) NOT NULL,
    Profesion VARCHAR2(50),
    Nacionalidad VARCHAR2(50),
    ID_Escuela NUMBER,
    CONSTRAINT FK_Escuela_Personal FOREIGN KEY (ID_Escuela) REFERENCES Escuelas_Deportivas(ID_Escuela)
);

-- Crear trigger para insertar valores automáticos en la tabla Personal
CREATE OR REPLACE TRIGGER Trigger_Personal_BI
BEFORE INSERT ON Personal
FOR EACH ROW
BEGIN
  :NEW.ID_Personal := Seq_Personal.NEXTVAL;
END;
/

-- Crear secuencia para la tabla Costos
CREATE SEQUENCE Seq_Costos START WITH 1 INCREMENT BY 1;

-- Crear tabla Costos
CREATE TABLE Costos (
    ID_Costo NUMBER PRIMARY KEY,
    ID_Escuela NUMBER,
    Tipo_Costo VARCHAR2(50) NOT NULL,  -- Tipo de costo (pago entrenadores, insumos, equipos, etc.)
    Monto NUMBER(10, 2) NOT NULL,
    Fecha DATE NOT NULL,
    CONSTRAINT FK_Escuela_Costos FOREIGN KEY (ID_Escuela) REFERENCES Escuelas_Deportivas(ID_Escuela)
);

-- Crear trigger para insertar valores automáticos en la tabla Costos
CREATE OR REPLACE TRIGGER Trigger_Costos_BI
BEFORE INSERT ON Costos
FOR EACH ROW
BEGIN
  :NEW.ID_Costo := Seq_Costos.NEXTVAL;
END;
/

-- Crear secuencia para la tabla Insumos
CREATE SEQUENCE Seq_Insumos START WITH 1 INCREMENT BY 1;

-- Crear tabla Insumos
CREATE TABLE Insumos (
    ID_Insumo NUMBER PRIMARY KEY,
    ID_Costo NUMBER,
    Descripcion VARCHAR2(100),
    Cantidad NUMBER,
    Costo_Unitario NUMBER(10, 2),
    CONSTRAINT FK_Costo_Insumos FOREIGN KEY (ID_Costo) REFERENCES Costos(ID_Costo)
);

-- Crear trigger para insertar valores automáticos en la tabla Insumos
CREATE OR REPLACE TRIGGER Trigger_Insumos_BI
BEFORE INSERT ON Insumos
FOR EACH ROW
BEGIN
  :NEW.ID_Insumo := Seq_Insumos.NEXTVAL;
END;
/

-- Crear secuencia para la tabla Equipos
CREATE SEQUENCE Seq_Equipos START WITH 1 INCREMENT BY 1;

-- Crear tabla Equipos
CREATE TABLE Equipos (
    ID_Equipo NUMBER PRIMARY KEY,
    ID_Costo NUMBER,
    Descripcion VARCHAR2(100),
    Cantidad NUMBER,
    Costo_Unitario NUMBER(10, 2),
    CONSTRAINT FK_Costo_Equipos FOREIGN KEY (ID_Costo) REFERENCES Costos(ID_Costo)
);

-- Crear trigger para insertar valores automáticos en la tabla Equipos
CREATE OR REPLACE TRIGGER Trigger_Equipos_BI
BEFORE INSERT ON Equipos
FOR EACH ROW
BEGIN
  :NEW.ID_Equipo := Seq_Equipos.NEXTVAL;
END;
/
