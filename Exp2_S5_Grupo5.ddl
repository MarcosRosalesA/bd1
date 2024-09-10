-- Generado por Oracle SQL Developer Data Modeler 23.1.0.087.0806
--   en:        2024-09-09 21:34:52 CLST
--   sitio:      Oracle Database 11g
--   tipo:      Oracle Database 11g



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE cliente (
    id_cliente   NUMBER(10, 10) NOT NULL,
    rut          NUMBER(10, 10) NOT NULL,
    nombres      CHAR(50 CHAR) NOT NULL,
    domicilio    CHAR(40) NOT NULL,
    num_contacto NUMBER(20, 20) NOT NULL,
    email        CHAR(40)
);

ALTER TABLE cliente ADD CONSTRAINT cliente_pk PRIMARY KEY ( id_cliente );

CREATE TABLE marca_model (
    id_marca  NUMBER(10, 10) NOT NULL,
    nom_marca CHAR(20) NOT NULL,
    nom_model CHAR(20) NOT NULL,
    anio      NUMBER(10, 10) NOT NULL,
    color     CHAR(10) NOT NULL
);

ALTER TABLE marca_model ADD CONSTRAINT marca_model_pk PRIMARY KEY ( id_marca );

CREATE TABLE repuestos (
    id_respuesto         NUMBER(10, 10) NOT NULL,
    nom_repuesto         CHAR(20) NOT NULL,
    cantidad_rep         NUMBER(10, 10) NOT NULL,
    servicio_id_servicio NUMBER(10, 10)
);

ALTER TABLE repuestos ADD CONSTRAINT repuestos_pk PRIMARY KEY ( id_respuesto );

CREATE TABLE servicio (
    id_servicio NUMBER(10, 10) NOT NULL,
    nom_serv    CHAR(20 CHAR) NOT NULL
);

ALTER TABLE servicio ADD CONSTRAINT servicio_pk PRIMARY KEY ( id_servicio );

CREATE TABLE status (
    id_estado  NUMBER(10, 10) NOT NULL,
    nom_estado CHAR(10) NOT NULL
);

ALTER TABLE status ADD CONSTRAINT status_pk PRIMARY KEY ( id_estado );

CREATE TABLE trabajo (
    id_trabajo           NUMBER(10, 10) NOT NULL,
    fecha_entrega        DATE NOT NULL,
    fecha_ingreso        DATE NOT NULL,
    cliente_id_cliente   NUMBER(10, 10) NOT NULL,
    servicio_id_servicio NUMBER(10, 10) NOT NULL,
    status_id_estado     NUMBER(10, 10) NOT NULL
);

ALTER TABLE trabajo ADD CONSTRAINT trabajo_pk PRIMARY KEY ( id_trabajo );

CREATE TABLE vehiculo (
    id_veh               NUMBER(10, 10) NOT NULL,
    patente              NUMBER(10, 10) NOT NULL,
    cliente_id_cliente   NUMBER(10, 10) NOT NULL,
    marca_model_id_marca NUMBER(10, 10) NOT NULL
);

ALTER TABLE vehiculo ADD CONSTRAINT vehiculo_pk PRIMARY KEY ( id_veh,
                                                              cliente_id_cliente );

ALTER TABLE repuestos
    ADD CONSTRAINT repuestos_servicio_fk FOREIGN KEY ( servicio_id_servicio )
        REFERENCES servicio ( id_servicio );

ALTER TABLE trabajo
    ADD CONSTRAINT trabajo_cliente_fk FOREIGN KEY ( cliente_id_cliente )
        REFERENCES cliente ( id_cliente );

ALTER TABLE trabajo
    ADD CONSTRAINT trabajo_servicio_fk FOREIGN KEY ( servicio_id_servicio )
        REFERENCES servicio ( id_servicio );

ALTER TABLE trabajo
    ADD CONSTRAINT trabajo_status_fk FOREIGN KEY ( status_id_estado )
        REFERENCES status ( id_estado );

ALTER TABLE vehiculo
    ADD CONSTRAINT vehiculo_cliente_fk FOREIGN KEY ( cliente_id_cliente )
        REFERENCES cliente ( id_cliente );

ALTER TABLE vehiculo
    ADD CONSTRAINT vehiculo_marca_model_fk FOREIGN KEY ( marca_model_id_marca )
        REFERENCES marca_model ( id_marca );



-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                             7
-- CREATE INDEX                             0
-- ALTER TABLE                             13
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
