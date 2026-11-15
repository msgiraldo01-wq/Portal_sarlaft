-- =====================================================================
-- PORTAL SARLAFT - 01_esquema.sql
-- Base de datos del sistema de conocimiento de terceros
-- (Circular Externa 009 de 2016 de la Supersalud y sus modificaciones).
--
-- Motor:     MySQL 8.0 o superior (InnoDB, utf8mb4).
-- Ejecutar:  mysql -u root -p < bd/01_esquema.sql
--            (o abrirlo en MySQL Workbench y ejecutarlo completo).
--            Usa DELIMITER para los disparadores: debe correrse con el
--            cliente mysql o Workbench, no desde la aplicacion Node.
--
-- Este script NO borra nada: si la base ya existe, falla al crear la
-- primera tabla repetida. Para empezar de cero en desarrollo use
-- 00_reiniciar_desarrollo.sql.
--
-- ORGANIZACION (ver MER.md)
--   A. Catalogos            datos de referencia que casi no cambian
--   B. Personas y acceso    usuarios internos, terceros, codigos
--   C. Cuestionario         preguntas parametrizables y versionadas
--   D. Formulario           lo que diligencia cada tercero cada periodo
--   E. Control              listas restrictivas, alertas, auditoria
--   F. Vistas               consultas listas para las pantallas
--
-- CONVENCIONES
--   - Tablas en plural, columnas en singular, en espanol y sin tildes.
--   - Llave primaria "id" salvo en catalogos con codigo oficial
--     (DANE, ISO, CIIU), donde el codigo es la llave.
--   - Llaves foraneas: <tabla en singular>_id o <tabla>_codigo.
--   - Fechas de sistema terminan en "_en" (creado_en, enviado_en).
--   - Los archivos (soportes) NO se guardan en la base: se guarda la
--     ruta, el tamano y la huella SHA-256.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS portal_sarlaft
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_es_0900_ai_ci;  -- espanol: sin distinguir tildes, pero n y ñ distintas

USE portal_sarlaft;


-- =====================================================================
-- A. CATALOGOS
-- =====================================================================

CREATE TABLE tipos_documento (
  codigo        VARCHAR(5)   NOT NULL COMMENT 'NIT, CC, CE, PPT, PA',
  nombre        VARCHAR(60)  NOT NULL,
  tipo_persona  ENUM('juridica','natural','ambas') NOT NULL,
  activo        BOOLEAN      NOT NULL DEFAULT TRUE,
  PRIMARY KEY (codigo)
) ENGINE=InnoDB COMMENT='Tipos de documento de identidad aceptados';

CREATE TABLE paises (
  codigo        CHAR(2)      NOT NULL COMMENT 'ISO 3166-1 alfa-2',
  nombre        VARCHAR(80)  NOT NULL,
  riesgo_gafi   ENUM('ninguno','vigilancia','accion') NOT NULL DEFAULT 'ninguno'
                COMMENT 'Listas del GAFI: vigilancia reforzada (gris) o llamado a la accion (negra). Actualizar tras cada plenaria.',
  PRIMARY KEY (codigo),
  UNIQUE KEY uq_paises_nombre (nombre)
) ENGINE=InnoDB COMMENT='Paises';

CREATE TABLE departamentos (
  codigo        CHAR(2)      NOT NULL COMMENT 'Codigo DANE (DIVIPOLA)',
  nombre        VARCHAR(80)  NOT NULL,
  PRIMARY KEY (codigo)
) ENGINE=InnoDB COMMENT='Departamentos de Colombia';

CREATE TABLE municipios (
  codigo              CHAR(5)     NOT NULL COMMENT 'Codigo DANE (DIVIPOLA)',
  departamento_codigo CHAR(2)     NOT NULL,
  nombre              VARCHAR(80) NOT NULL,
  PRIMARY KEY (codigo),
  KEY ix_municipios_nombre (nombre),
  CONSTRAINT fk_municipios_departamento FOREIGN KEY (departamento_codigo) REFERENCES departamentos (codigo)
) ENGINE=InnoDB COMMENT='Municipios de Colombia';

CREATE TABLE actividades_ciiu (
  codigo        CHAR(4)      NOT NULL COMMENT 'CIIU Rev. 4 A.C. (DIAN)',
  descripcion   VARCHAR(300) NOT NULL,
  riesgo        ENUM('bajo','medio','alto') NOT NULL DEFAULT 'bajo'
                COMMENT 'Riesgo LA/FT de la actividad segun la matriz de la entidad',
  PRIMARY KEY (codigo)
) ENGINE=InnoDB COMMENT='Actividades economicas CIIU';

CREATE TABLE parentescos (
  id            TINYINT UNSIGNED NOT NULL,
  nombre        VARCHAR(60)  NOT NULL,
  tipo          ENUM('consanguinidad','afinidad','civil','pareja') NOT NULL,
  grado         TINYINT UNSIGNED NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_parentescos_nombre (nombre)
) ENGINE=InnoDB COMMENT='Parentescos para familiares de PEP y de directivos';

CREATE TABLE listas_restrictivas (
  id            SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo        VARCHAR(20)  NOT NULL,
  nombre        VARCHAR(150) NOT NULL,
  fuente        VARCHAR(150) NOT NULL COMMENT 'Entidad que publica la lista',
  vinculante    BOOLEAN      NOT NULL COMMENT 'TRUE = lista vinculante para Colombia (ONU)',
  activa        BOOLEAN      NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id),
  UNIQUE KEY uq_listas_codigo (codigo)
) ENGINE=InnoDB COMMENT='Listas restrictivas y de control que se consultan';

CREATE TABLE tipos_soporte (
  id            SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo        VARCHAR(30)  NOT NULL,
  nombre        VARCHAR(150) NOT NULL,
  tipo_persona  ENUM('juridica','natural','ambas') NOT NULL,
  relaciones    SET('proveedor','cliente','empleado','accionista','otro') NULL
                COMMENT 'A que relaciones se exige. NULL = a todas',
  obligatorio   BOOLEAN      NOT NULL DEFAULT TRUE,
  vigencia_dias SMALLINT UNSIGNED NULL COMMENT 'Antiguedad maxima de expedicion. NULL = sin limite',
  activo        BOOLEAN      NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id),
  UNIQUE KEY uq_tipos_soporte_codigo (codigo)
) ENGINE=InnoDB COMMENT='Documentos soporte que se piden con el formulario';


-- =====================================================================
-- B. PERSONAS Y ACCESO
-- =====================================================================

CREATE TABLE usuarios (
  id                 INT UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario            VARCHAR(60)  NOT NULL,
  nombre             VARCHAR(150) NOT NULL,
  correo             VARCHAR(150) NOT NULL,
  clave_hash         VARCHAR(255) NOT NULL COMMENT 'bcrypt. Nunca la contrasena en claro',
  rol                ENUM('administrador','oficial_cumplimiento','analista','auditor') NOT NULL,
  activo             BOOLEAN      NOT NULL DEFAULT TRUE COMMENT 'Los usuarios se desactivan, no se borran',
  intentos_fallidos  TINYINT UNSIGNED NOT NULL DEFAULT 0,
  bloqueado_hasta    DATETIME     NULL,
  ultimo_ingreso_en  DATETIME     NULL,
  creado_en          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_usuarios_usuario (usuario),
  UNIQUE KEY uq_usuarios_correo (correo)
) ENGINE=InnoDB COMMENT='Equipo interno: oficial de cumplimiento, analistas, auditores';

CREATE TABLE parametros (
  clave           VARCHAR(60)  NOT NULL,
  valor           VARCHAR(255) NOT NULL,
  tipo            ENUM('entero','decimal','texto','booleano') NOT NULL,
  descripcion     VARCHAR(300) NOT NULL,
  actualizado_por INT UNSIGNED NULL,
  actualizado_en  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (clave),
  CONSTRAINT fk_parametros_usuario FOREIGN KEY (actualizado_por) REFERENCES usuarios (id)
) ENGINE=InnoDB COMMENT='Parametros editables desde Ajustes (periodicidad, tamanos, tiempos)';

CREATE TABLE terceros (
  id                     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tipo_persona           ENUM('juridica','natural') NOT NULL,
  tipo_documento         VARCHAR(5)   NOT NULL,
  numero_documento       VARCHAR(20)  NOT NULL COMMENT 'Solo digitos (o alfanumerico en pasaporte), sin DV',
  digito_verificacion    TINYINT UNSIGNED NULL COMMENT 'Solo NIT, calculado con el algoritmo DIAN',
  razon_social           VARCHAR(200) NULL COMMENT 'Persona juridica',
  nombres                VARCHAR(100) NULL COMMENT 'Persona natural',
  apellidos              VARCHAR(100) NULL COMMENT 'Persona natural',
  nombre                 VARCHAR(201) AS (COALESCE(razon_social, CONCAT(nombres, ' ', apellidos))) STORED
                         COMMENT 'Calculado: razon social o nombres + apellidos. Para buscar y listar',
  contacto_nombre        VARCHAR(150) NULL COMMENT 'Quien diligencia en nombre de la persona juridica',
  correo                 VARCHAR(150) NOT NULL,
  celular                VARCHAR(15)  NOT NULL,
  autorizacion_datos_en  DATETIME     NOT NULL COMMENT 'Cuando acepto el tratamiento de datos (Ley 1581)',
  autorizacion_datos_ip  VARCHAR(45)  NULL,
  estado                 ENUM('activo','inactivo','bloqueado') NOT NULL DEFAULT 'activo',
  nivel_riesgo           ENUM('sin_calificar','bajo','medio','alto') NOT NULL DEFAULT 'sin_calificar',
  creado_en              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_terceros_documento (tipo_documento, numero_documento),
  KEY ix_terceros_nombre (nombre),
  KEY ix_terceros_numero (numero_documento),
  CONSTRAINT fk_terceros_tipo_documento FOREIGN KEY (tipo_documento) REFERENCES tipos_documento (codigo),
  CONSTRAINT ck_terceros_juridica CHECK (tipo_persona <> 'juridica' OR (razon_social IS NOT NULL AND tipo_documento = 'NIT')),
  CONSTRAINT ck_terceros_natural  CHECK (tipo_persona <> 'natural'  OR (nombres IS NOT NULL AND apellidos IS NOT NULL)),
  CONSTRAINT ck_terceros_dv       CHECK ((tipo_documento = 'NIT') = (digito_verificacion IS NOT NULL)),
  CONSTRAINT ck_terceros_dv_rango CHECK (digito_verificacion IS NULL OR digito_verificacion <= 9)
) ENGINE=InnoDB COMMENT='Proveedores, clientes, empleados, accionistas: quien diligencia el formulario';

CREATE TABLE tercero_relaciones (
  tercero_id     INT UNSIGNED NOT NULL,
  relacion       ENUM('proveedor','cliente','empleado','accionista','otro') NOT NULL,
  desde          DATE         NOT NULL,
  activa         BOOLEAN      NOT NULL DEFAULT TRUE,
  PRIMARY KEY (tercero_id, relacion),
  CONSTRAINT fk_relaciones_tercero FOREIGN KEY (tercero_id) REFERENCES terceros (id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Un tercero puede ser a la vez proveedor y cliente, etc.';

CREATE TABLE codigos_verificacion (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tercero_id    INT UNSIGNED NOT NULL,
  proposito     ENUM('acceso','firma') NOT NULL,
  codigo_hash   CHAR(64)     NOT NULL COMMENT 'SHA-256 del codigo con sal. El codigo nunca se guarda en claro',
  canales       SET('correo','sms') NOT NULL,
  creado_en     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vence_en      DATETIME     NOT NULL,
  intentos      TINYINT UNSIGNED NOT NULL DEFAULT 0,
  usado_en      DATETIME     NULL,
  ip            VARCHAR(45)  NULL,
  PRIMARY KEY (id),
  KEY ix_codigos_tercero (tercero_id, proposito, creado_en),
  CONSTRAINT fk_codigos_tercero FOREIGN KEY (tercero_id) REFERENCES terceros (id) ON DELETE CASCADE,
  CONSTRAINT ck_codigos_vence CHECK (vence_en > creado_en)
) ENGINE=InnoDB COMMENT='Codigos de un solo uso para entrar y para firmar';

CREATE TABLE invitaciones (
  id                INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tipo_documento    VARCHAR(5)   NOT NULL,
  numero_documento  VARCHAR(20)  NOT NULL,
  correo            VARCHAR(150) NOT NULL,
  relacion          ENUM('proveedor','cliente','empleado','accionista','otro') NOT NULL,
  token_hash        CHAR(64)     NOT NULL COMMENT 'SHA-256 del token del enlace',
  enviada_por       INT UNSIGNED NOT NULL,
  enviada_en        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vence_en          DATETIME     NOT NULL,
  usada_en          DATETIME     NULL,
  tercero_id        INT UNSIGNED NULL COMMENT 'Se llena cuando el invitado se registra',
  PRIMARY KEY (id),
  UNIQUE KEY uq_invitaciones_token (token_hash),
  KEY ix_invitaciones_documento (tipo_documento, numero_documento),
  CONSTRAINT fk_invitaciones_tipo_doc FOREIGN KEY (tipo_documento) REFERENCES tipos_documento (codigo),
  CONSTRAINT fk_invitaciones_usuario  FOREIGN KEY (enviada_por) REFERENCES usuarios (id),
  CONSTRAINT fk_invitaciones_tercero  FOREIGN KEY (tercero_id) REFERENCES terceros (id) ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='Enlaces que el equipo envia para que un tercero diligencie';


-- =====================================================================
-- C. CUESTIONARIO PARAMETRIZABLE
-- Las preguntas no estan fijas en el codigo: viven aqui, versionadas.
-- Cuando la norma cambia se crea una version nueva del cuestionario;
-- los formularios ya diligenciados conservan la version que usaron.
-- =====================================================================

CREATE TABLE cuestionarios (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(150) NOT NULL,
  tipo_persona   ENUM('juridica','natural') NOT NULL,
  version        SMALLINT UNSIGNED NOT NULL,
  estado         ENUM('borrador','publicado','retirado') NOT NULL DEFAULT 'borrador',
  publicado_en   DATETIME     NULL,
  notas          TEXT         NULL COMMENT 'Que cambio y por que norma',
  creado_por     INT UNSIGNED NULL,
  creado_en      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  -- Solo puede haber UN cuestionario publicado por tipo de persona:
  publicado_tipo ENUM('juridica','natural') AS (IF(estado = 'publicado', tipo_persona, NULL)) STORED,
  PRIMARY KEY (id),
  UNIQUE KEY uq_cuestionarios_version (tipo_persona, version),
  UNIQUE KEY uq_cuestionarios_publicado (publicado_tipo),
  CONSTRAINT fk_cuestionarios_usuario FOREIGN KEY (creado_por) REFERENCES usuarios (id)
) ENGINE=InnoDB COMMENT='Versiones del formulario SARLAFT, una por tipo de persona';

CREATE TABLE modulos (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cuestionario_id INT UNSIGNED NOT NULL,
  orden           TINYINT UNSIGNED NOT NULL,
  nombre          VARCHAR(100) NOT NULL,
  descripcion     TEXT         NULL COMMENT 'Texto de ayuda que encabeza el paso',
  PRIMARY KEY (id),
  UNIQUE KEY uq_modulos_orden (cuestionario_id, orden),
  CONSTRAINT fk_modulos_cuestionario FOREIGN KEY (cuestionario_id) REFERENCES cuestionarios (id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Pasos del formulario (Identificacion, PEP, Informacion financiera...)';

CREATE TABLE preguntas (
  id                      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  modulo_id               INT UNSIGNED NOT NULL,
  orden                   SMALLINT UNSIGNED NOT NULL,
  codigo                  VARCHAR(60)  NOT NULL COMMENT 'Clave estable para el codigo y los reportes',
  enunciado               TEXT         NOT NULL,
  ayuda                   TEXT         NULL,
  tipo                    ENUM('texto','texto_largo','numero','moneda','fecha','si_no','seleccion','multiple','aceptacion') NOT NULL,
  obligatoria             BOOLEAN      NOT NULL DEFAULT TRUE,
  relaciones              SET('proveedor','cliente','empleado','accionista','otro') NULL
                          COMMENT 'A que relaciones se hace la pregunta. NULL = a todas',
  depende_de_pregunta_id  INT UNSIGNED NULL COMMENT 'Solo se muestra si esta otra pregunta...',
  depende_de_valor        VARCHAR(60)  NULL COMMENT '...tiene este valor (si, no o el valor de una opcion)',
  alerta_si_valor         VARCHAR(60)  NULL COMMENT 'Si la respuesta es este valor se crea una alerta automatica',
  activa                  BOOLEAN      NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id),
  UNIQUE KEY uq_preguntas_codigo (modulo_id, codigo),
  KEY ix_preguntas_orden (modulo_id, orden),
  CONSTRAINT fk_preguntas_modulo FOREIGN KEY (modulo_id) REFERENCES modulos (id) ON DELETE CASCADE,
  CONSTRAINT fk_preguntas_depende FOREIGN KEY (depende_de_pregunta_id) REFERENCES preguntas (id),
  CONSTRAINT ck_preguntas_depende CHECK ((depende_de_pregunta_id IS NULL) = (depende_de_valor IS NULL))
) ENGINE=InnoDB COMMENT='Preguntas de cada modulo';

CREATE TABLE pregunta_opciones (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pregunta_id   INT UNSIGNED NOT NULL,
  orden         SMALLINT UNSIGNED NOT NULL,
  valor         VARCHAR(60)  NOT NULL COMMENT 'Clave que se guarda (ej. codigo ISO del pais)',
  etiqueta      VARCHAR(200) NOT NULL COMMENT 'Texto que ve el tercero',
  pide_detalle  BOOLEAN      NOT NULL DEFAULT FALSE COMMENT 'Opcion "Otro": pide escribir cual',
  excluyente    BOOLEAN      NOT NULL DEFAULT FALSE COMMENT '"Ninguno": no se combina con otras',
  genera_alerta BOOLEAN      NOT NULL DEFAULT FALSE,
  activa        BOOLEAN      NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id),
  UNIQUE KEY uq_opciones_valor (pregunta_id, valor),
  CONSTRAINT fk_opciones_pregunta FOREIGN KEY (pregunta_id) REFERENCES preguntas (id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Opciones de las preguntas de seleccion y multiples';

CREATE TABLE modulo_secciones (
  id                      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  modulo_id               INT UNSIGNED NOT NULL,
  orden                   TINYINT UNSIGNED NOT NULL,
  componente              ENUM('firmante','datos_generales','representante_principal','representantes_suplentes',
                               'familiares_pep','financiero','accionistas','junta_directiva','beneficiarios_finales',
                               'grupo_empresarial','parientes_directivos','soportes','firma') NOT NULL
                          COMMENT 'Bloque de datos estructurados que muestra el paso',
  titulo                  VARCHAR(150) NOT NULL,
  instrucciones           TEXT         NULL,
  obligatoria             BOOLEAN      NOT NULL DEFAULT TRUE,
  minimo_filas            TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Para listas de personas',
  depende_de_pregunta_id  INT UNSIGNED NULL,
  depende_de_valor        VARCHAR(60)  NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_secciones_componente (modulo_id, componente),
  CONSTRAINT fk_secciones_modulo   FOREIGN KEY (modulo_id) REFERENCES modulos (id) ON DELETE CASCADE,
  CONSTRAINT fk_secciones_depende  FOREIGN KEY (depende_de_pregunta_id) REFERENCES preguntas (id),
  CONSTRAINT ck_secciones_depende  CHECK ((depende_de_pregunta_id IS NULL) = (depende_de_valor IS NULL))
) ENGINE=InnoDB COMMENT='Bloques fijos (datos generales, financiero, listas de personas) dentro de un modulo';


-- =====================================================================
-- D. FORMULARIO
-- Un formulario = un tercero + un periodo + una version del cuestionario.
-- Los datos que se cruzan o se calculan (ubicacion, cifras, personas)
-- van en tablas con columnas propias; las preguntas parametrizables van
-- en respuestas.
-- =====================================================================

CREATE TABLE formularios (
  id                    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tercero_id            INT UNSIGNED NOT NULL,
  cuestionario_id       INT UNSIGNED NOT NULL,
  tipo                  ENUM('vinculacion','actualizacion') NOT NULL,
  periodo               YEAR         NOT NULL,
  estado                ENUM('borrador','en_revision','devuelto','aprobado','rechazado') NOT NULL DEFAULT 'borrador',
  radicado              VARCHAR(20)  NULL COMMENT 'Se asigna al enviar: SRL-AAAA-NNNNN',
  creado_en             DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  enviado_en            DATETIME     NULL COMMENT 'Firma y envio con codigo de un solo uso',
  firma_codigo_id       INT UNSIGNED NULL,
  firma_ip              VARCHAR(45)  NULL,
  revisado_por          INT UNSIGNED NULL,
  revisado_en           DATETIME     NULL,
  observacion_revision  TEXT         NULL COMMENT 'Lo que se le pide corregir o por que se rechaza',
  vence_en              DATE         NULL COMMENT 'Cuando debe actualizarse (al aprobar: hoy + periodicidad)',
  nivel_riesgo          ENUM('sin_calificar','bajo','medio','alto') NOT NULL DEFAULT 'sin_calificar',
  PRIMARY KEY (id),
  UNIQUE KEY uq_formularios_periodo (tercero_id, periodo),
  UNIQUE KEY uq_formularios_radicado (radicado),
  KEY ix_formularios_estado (estado, actualizado_en),
  KEY ix_formularios_vence (vence_en),
  CONSTRAINT fk_formularios_tercero      FOREIGN KEY (tercero_id) REFERENCES terceros (id),
  CONSTRAINT fk_formularios_cuestionario FOREIGN KEY (cuestionario_id) REFERENCES cuestionarios (id),
  CONSTRAINT fk_formularios_codigo       FOREIGN KEY (firma_codigo_id) REFERENCES codigos_verificacion (id),
  CONSTRAINT fk_formularios_revisor      FOREIGN KEY (revisado_por) REFERENCES usuarios (id),
  CONSTRAINT ck_formularios_enviado CHECK (estado = 'borrador' OR (radicado IS NOT NULL AND enviado_en IS NOT NULL)),
  CONSTRAINT ck_formularios_decidido CHECK (estado NOT IN ('aprobado','rechazado') OR (revisado_por IS NOT NULL AND revisado_en IS NOT NULL))
) ENGINE=InnoDB COMMENT='Formulario SARLAFT de un tercero en un periodo';

CREATE TABLE formulario_estados (
  id               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  formulario_id    INT UNSIGNED NOT NULL,
  estado_anterior  ENUM('borrador','en_revision','devuelto','aprobado','rechazado') NULL,
  estado_nuevo     ENUM('borrador','en_revision','devuelto','aprobado','rechazado') NOT NULL,
  usuario_id       INT UNSIGNED NULL COMMENT 'NULL = el propio tercero o el sistema',
  observacion      TEXT         NULL,
  ocurrido_en      DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY ix_estados_formulario (formulario_id, ocurrido_en),
  CONSTRAINT fk_estados_formulario FOREIGN KEY (formulario_id) REFERENCES formularios (id) ON DELETE CASCADE,
  CONSTRAINT fk_estados_usuario    FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
) ENGINE=InnoDB COMMENT='Historial de cambios de estado (lo llena un disparador)';

CREATE TABLE formulario_modulos (
  formulario_id   INT UNSIGNED NOT NULL,
  modulo_id       INT UNSIGNED NOT NULL,
  estado          ENUM('pendiente','completo','con_error') NOT NULL DEFAULT 'pendiente',
  actualizado_en  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (formulario_id, modulo_id),
  CONSTRAINT fk_fmodulos_formulario FOREIGN KEY (formulario_id) REFERENCES formularios (id) ON DELETE CASCADE,
  CONSTRAINT fk_fmodulos_modulo     FOREIGN KEY (modulo_id) REFERENCES modulos (id)
) ENGINE=InnoDB COMMENT='Avance por paso: lo que pinta la barra de pasos';

CREATE TABLE formulario_datos_generales (
  formulario_id          INT UNSIGNED NOT NULL,
  -- Persona juridica
  forma_juridica         ENUM('sa','sas','ltda','scs','sca','empresa_unipersonal','esal','cooperativa',
                              'entidad_publica','sucursal_extranjera','otra') NULL,
  naturaleza             ENUM('privada','publica','mixta') NULL,
  -- Persona natural
  fecha_nacimiento       DATE         NULL,
  municipio_nacimiento   CHAR(5)      NULL,
  pais_nacimiento        CHAR(2)      NULL,
  nacionalidad           CHAR(2)      NULL,
  ocupacion              VARCHAR(100) NULL,
  empresa_donde_trabaja  VARCHAR(150) NULL,
  cargo                  VARCHAR(100) NULL,
  -- Comunes
  actividad_ciiu         CHAR(4)      NOT NULL,
  pais                   CHAR(2)      NOT NULL DEFAULT 'CO',
  municipio              CHAR(5)      NULL COMMENT 'Obligatorio si el pais es Colombia',
  ciudad_exterior        VARCHAR(100) NULL COMMENT 'Si el pais no es Colombia',
  direccion              VARCHAR(200) NOT NULL,
  telefono               VARCHAR(40)  NOT NULL,
  sitio_web              VARCHAR(150) NULL,
  actualizado_en         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (formulario_id),
  CONSTRAINT fk_dgenerales_formulario   FOREIGN KEY (formulario_id) REFERENCES formularios (id) ON DELETE CASCADE,
  CONSTRAINT fk_dgenerales_ciiu         FOREIGN KEY (actividad_ciiu) REFERENCES actividades_ciiu (codigo),
  CONSTRAINT fk_dgenerales_pais         FOREIGN KEY (pais) REFERENCES paises (codigo),
  CONSTRAINT fk_dgenerales_municipio    FOREIGN KEY (municipio) REFERENCES municipios (codigo),
  CONSTRAINT fk_dgenerales_mun_nac      FOREIGN KEY (municipio_nacimiento) REFERENCES municipios (codigo),
  CONSTRAINT fk_dgenerales_pais_nac     FOREIGN KEY (pais_nacimiento) REFERENCES paises (codigo),
  CONSTRAINT fk_dgenerales_nacionalidad FOREIGN KEY (nacionalidad) REFERENCES paises (codigo),
  CONSTRAINT ck_dgenerales_ubicacion CHECK (
    (pais = 'CO' AND municipio IS NOT NULL) OR (pais <> 'CO' AND ciudad_exterior IS NOT NULL))
) ENGINE=InnoDB COMMENT='Ubicacion, actividad economica y datos basicos declarados (1 a 1 con formulario)';

CREATE TABLE formulario_financiero (
  formulario_id            INT UNSIGNED NOT NULL,
  fecha_corte              DATE          NOT NULL,
  moneda                   CHAR(3)       NOT NULL DEFAULT 'COP',
  activos                  DECIMAL(18,2) NOT NULL,
  pasivos                  DECIMAL(18,2) NOT NULL,
  patrimonio               DECIMAL(18,2) NOT NULL COMMENT 'Puede ser negativo',
  ingresos_anuales         DECIMAL(18,2) NOT NULL,
  otros_ingresos           DECIMAL(18,2) NOT NULL DEFAULT 0,
  concepto_otros_ingresos  VARCHAR(200)  NULL,
  egresos_anuales          DECIMAL(18,2) NOT NULL,
  actualizado_en           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (formulario_id),
  CONSTRAINT fk_financiero_formulario FOREIGN KEY (formulario_id) REFERENCES formularios (id) ON DELETE CASCADE,
  CONSTRAINT ck_financiero_positivos CHECK (activos >= 0 AND pasivos >= 0 AND ingresos_anuales >= 0
                                            AND otros_ingresos >= 0 AND egresos_anuales >= 0),
  CONSTRAINT ck_financiero_concepto  CHECK (otros_ingresos = 0 OR concepto_otros_ingresos IS NOT NULL)
) ENGINE=InnoDB COMMENT='Informacion financiera declarada (1 a 1 con formulario)';

CREATE TABLE personas_vinculadas (
  id                    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  formulario_id         INT UNSIGNED NOT NULL,
  rol                   ENUM('firmante','representante_principal','representante_suplente','accionista',
                             'junta_directiva','beneficiario_final','familiar_pep','pariente_directivo',
                             'grupo_empresarial') NOT NULL,
  orden                 SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  tipo_persona          ENUM('juridica','natural') NOT NULL DEFAULT 'natural',
  nombre_completo       VARCHAR(200) NOT NULL,
  tipo_documento        VARCHAR(5)   NULL,
  numero_documento      VARCHAR(20)  NULL,
  pais_documento        CHAR(2)      NULL COMMENT 'Para documentos extranjeros',
  correo                VARCHAR(150) NULL COMMENT 'firmante',
  celular               VARCHAR(15)  NULL COMMENT 'firmante',
  cargo                 VARCHAR(100) NULL COMMENT 'junta_directiva, pariente_directivo (cargo del directivo)',
  participacion         DECIMAL(5,2) NULL COMMENT 'accionista, beneficiario_final: % de participacion',
  es_pep                BOOLEAN      NULL COMMENT 'accionista, junta_directiva, beneficiario_final',
  parentesco_id         TINYINT UNSIGNED NULL COMMENT 'familiar_pep, pariente_directivo',
  fecha_nacimiento      DATE         NULL COMMENT 'representantes',
  municipio_nacimiento  CHAR(5)      NULL COMMENT 'representantes',
  municipio_residencia  CHAR(5)      NULL COMMENT 'representantes',
  direccion             VARCHAR(200) NULL COMMENT 'representantes',
  telefono              VARCHAR(40)  NULL COMMENT 'representantes',
  ocupacion             VARCHAR(100) NULL COMMENT 'representantes',
  creado_en             DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY ix_vinculadas_formulario (formulario_id, rol, orden),
  KEY ix_vinculadas_documento (numero_documento),
  KEY ix_vinculadas_nombre (nombre_completo),
  CONSTRAINT fk_vinculadas_formulario  FOREIGN KEY (formulario_id) REFERENCES formularios (id) ON DELETE CASCADE,
  CONSTRAINT fk_vinculadas_tipo_doc    FOREIGN KEY (tipo_documento) REFERENCES tipos_documento (codigo),
  CONSTRAINT fk_vinculadas_pais_doc    FOREIGN KEY (pais_documento) REFERENCES paises (codigo),
  CONSTRAINT fk_vinculadas_parentesco  FOREIGN KEY (parentesco_id) REFERENCES parentescos (id),
  CONSTRAINT fk_vinculadas_mun_nac     FOREIGN KEY (municipio_nacimiento) REFERENCES municipios (codigo),
  CONSTRAINT fk_vinculadas_mun_res     FOREIGN KEY (municipio_residencia) REFERENCES municipios (codigo),
  CONSTRAINT ck_vinculadas_participacion CHECK (participacion IS NULL OR (participacion > 0 AND participacion <= 100)),
  CONSTRAINT ck_vinculadas_parentesco    CHECK (rol NOT IN ('familiar_pep','pariente_directivo') OR parentesco_id IS NOT NULL),
  CONSTRAINT ck_vinculadas_firmante      CHECK (rol <> 'firmante' OR (correo IS NOT NULL AND numero_documento IS NOT NULL))
) ENGINE=InnoDB COMMENT='Todas las personas que aparecen en el formulario: representantes, socios, junta, beneficiarios, familiares';

CREATE TABLE respuestas (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  formulario_id   INT UNSIGNED NOT NULL,
  pregunta_id     INT UNSIGNED NOT NULL,
  valor_texto     TEXT          NULL COMMENT 'texto, texto_largo',
  valor_numero    DECIMAL(18,2) NULL COMMENT 'numero, moneda',
  valor_fecha     DATE          NULL COMMENT 'fecha',
  valor_booleano  BOOLEAN       NULL COMMENT 'si_no, aceptacion',
  actualizado_en  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_respuestas (formulario_id, pregunta_id),
  KEY ix_respuestas_pregunta (pregunta_id),
  CONSTRAINT fk_respuestas_formulario FOREIGN KEY (formulario_id) REFERENCES formularios (id) ON DELETE CASCADE,
  CONSTRAINT fk_respuestas_pregunta   FOREIGN KEY (pregunta_id) REFERENCES preguntas (id)
) ENGINE=InnoDB COMMENT='Respuesta a cada pregunta parametrizable. Las de seleccion guardan sus opciones en respuesta_opciones';

CREATE TABLE respuesta_opciones (
  respuesta_id  INT UNSIGNED NOT NULL,
  opcion_id     INT UNSIGNED NOT NULL,
  detalle       VARCHAR(300) NULL COMMENT 'Texto de "Otro, cual"',
  PRIMARY KEY (respuesta_id, opcion_id),
  CONSTRAINT fk_ropciones_respuesta FOREIGN KEY (respuesta_id) REFERENCES respuestas (id) ON DELETE CASCADE,
  CONSTRAINT fk_ropciones_opcion    FOREIGN KEY (opcion_id) REFERENCES pregunta_opciones (id)
) ENGINE=InnoDB COMMENT='Opciones marcadas en preguntas de seleccion y multiples';

CREATE TABLE soportes (
  id               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  formulario_id    INT UNSIGNED NOT NULL,
  tipo_soporte_id  SMALLINT UNSIGNED NOT NULL,
  nombre_original  VARCHAR(255) NOT NULL,
  ruta_archivo     VARCHAR(300) NOT NULL COMMENT 'Ruta relativa en el almacenamiento de archivos, fuera de publico/',
  tipo_mime        VARCHAR(100) NOT NULL,
  tamano_bytes     INT UNSIGNED NOT NULL,
  sha256           CHAR(64)     NOT NULL COMMENT 'Huella para probar que el archivo no cambio',
  fecha_expedicion DATE         NULL,
  estado           ENUM('cargado','aceptado','rechazado') NOT NULL DEFAULT 'cargado',
  observacion      VARCHAR(300) NULL,
  cargado_en       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  revisado_por     INT UNSIGNED NULL,
  revisado_en      DATETIME     NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_soportes_ruta (ruta_archivo),
  KEY ix_soportes_formulario (formulario_id, tipo_soporte_id),
  CONSTRAINT fk_soportes_formulario FOREIGN KEY (formulario_id) REFERENCES formularios (id) ON DELETE CASCADE,
  CONSTRAINT fk_soportes_tipo       FOREIGN KEY (tipo_soporte_id) REFERENCES tipos_soporte (id),
  CONSTRAINT fk_soportes_revisor    FOREIGN KEY (revisado_por) REFERENCES usuarios (id),
  CONSTRAINT ck_soportes_tamano     CHECK (tamano_bytes > 0)
) ENGINE=InnoDB COMMENT='Documentos adjuntos (RUT, camara de comercio, cedulas, estados financieros)';


-- =====================================================================
-- E. CONTROL: LISTAS, ALERTAS Y AUDITORIA
-- =====================================================================

CREATE TABLE consultas_listas (
  id                    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tercero_id            INT UNSIGNED NULL,
  formulario_id         INT UNSIGNED NULL,
  persona_vinculada_id  INT UNSIGNED NULL,
  lista_id              SMALLINT UNSIGNED NOT NULL,
  nombre_consultado     VARCHAR(200) NOT NULL COMMENT 'Se copia: la consulta es evidencia aunque la persona cambie',
  documento_consultado  VARCHAR(20)  NULL,
  resultado             ENUM('sin_coincidencia','coincidencia_parcial','coincidencia_exacta','error') NOT NULL,
  detalle               TEXT         NULL,
  origen                ENUM('automatica','manual') NOT NULL,
  consultado_por        INT UNSIGNED NULL COMMENT 'NULL si fue automatica',
  consultado_en         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  evidencia_ruta        VARCHAR(300) NULL COMMENT 'Certificado o captura de la consulta',
  PRIMARY KEY (id),
  KEY ix_consultas_tercero (tercero_id, consultado_en),
  KEY ix_consultas_formulario (formulario_id),
  KEY ix_consultas_resultado (resultado),
  CONSTRAINT fk_consultas_tercero    FOREIGN KEY (tercero_id) REFERENCES terceros (id) ON DELETE SET NULL,
  CONSTRAINT fk_consultas_formulario FOREIGN KEY (formulario_id) REFERENCES formularios (id) ON DELETE SET NULL,
  CONSTRAINT fk_consultas_persona    FOREIGN KEY (persona_vinculada_id) REFERENCES personas_vinculadas (id) ON DELETE SET NULL,
  CONSTRAINT fk_consultas_lista      FOREIGN KEY (lista_id) REFERENCES listas_restrictivas (id),
  CONSTRAINT fk_consultas_usuario    FOREIGN KEY (consultado_por) REFERENCES usuarios (id)
) ENGINE=InnoDB COMMENT='Cada consulta en listas restrictivas, del tercero o de sus personas vinculadas';

CREATE TABLE alertas (
  id                 INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tercero_id         INT UNSIGNED NOT NULL,
  formulario_id      INT UNSIGNED NULL,
  consulta_lista_id  INT UNSIGNED NULL,
  origen             ENUM('lista_restrictiva','pep','pais_riesgo','actividad_riesgo','activos_virtuales',
                          'inconsistencia','manual') NOT NULL,
  severidad          ENUM('baja','media','alta') NOT NULL,
  descripcion        TEXT         NOT NULL,
  estado             ENUM('abierta','en_analisis','descartada','reportada_uiaf') NOT NULL DEFAULT 'abierta',
  asignada_a         INT UNSIGNED NULL,
  decision           TEXT         NULL COMMENT 'Analisis y justificacion del cierre',
  numero_ros         VARCHAR(40)  NULL COMMENT 'Radicado del ROS ante la UIAF. Informacion reservada',
  creada_en          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  cerrada_por        INT UNSIGNED NULL,
  cerrada_en         DATETIME     NULL,
  PRIMARY KEY (id),
  KEY ix_alertas_estado (estado, severidad, creada_en),
  KEY ix_alertas_tercero (tercero_id),
  CONSTRAINT fk_alertas_tercero    FOREIGN KEY (tercero_id) REFERENCES terceros (id),
  CONSTRAINT fk_alertas_formulario FOREIGN KEY (formulario_id) REFERENCES formularios (id) ON DELETE SET NULL,
  CONSTRAINT fk_alertas_consulta   FOREIGN KEY (consulta_lista_id) REFERENCES consultas_listas (id) ON DELETE SET NULL,
  CONSTRAINT fk_alertas_asignada   FOREIGN KEY (asignada_a) REFERENCES usuarios (id),
  CONSTRAINT fk_alertas_cerrada    FOREIGN KEY (cerrada_por) REFERENCES usuarios (id),
  CONSTRAINT ck_alertas_cierre CHECK (estado NOT IN ('descartada','reportada_uiaf')
                                      OR (decision IS NOT NULL AND cerrada_por IS NOT NULL AND cerrada_en IS NOT NULL)),
  CONSTRAINT ck_alertas_ros    CHECK (estado <> 'reportada_uiaf' OR numero_ros IS NOT NULL)
) ENGINE=InnoDB COMMENT='Senales de alerta y su analisis. NUNCA visibles para el tercero (reserva del ROS)';

CREATE TABLE auditoria (
  id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  ocurrido_en  DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  actor        ENUM('usuario','tercero','sistema') NOT NULL,
  usuario_id   INT UNSIGNED NULL COMMENT 'Sin llave foranea a proposito: la bitacora no depende de otras tablas',
  tercero_id   INT UNSIGNED NULL,
  accion       VARCHAR(60)  NOT NULL COMMENT 'ingreso, registro, guardar_borrador, enviar, aprobar, consultar_lista...',
  entidad      VARCHAR(60)  NULL COMMENT 'Tabla afectada',
  entidad_id   VARCHAR(40)  NULL,
  detalle      JSON         NULL,
  ip           VARCHAR(45)  NULL,
  agente       VARCHAR(255) NULL COMMENT 'Navegador (User-Agent)',
  PRIMARY KEY (id),
  KEY ix_auditoria_fecha (ocurrido_en),
  KEY ix_auditoria_entidad (entidad, entidad_id),
  KEY ix_auditoria_usuario (usuario_id, ocurrido_en),
  KEY ix_auditoria_tercero (tercero_id, ocurrido_en)
) ENGINE=InnoDB COMMENT='Bitacora de solo escritura: no admite UPDATE ni DELETE';


-- =====================================================================
-- DISPARADORES
-- =====================================================================
DELIMITER $$

-- La auditoria no se modifica ni se borra.
CREATE TRIGGER tr_auditoria_sin_cambios BEFORE UPDATE ON auditoria
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La auditoria no se puede modificar.';
END$$

CREATE TRIGGER tr_auditoria_sin_borrado BEFORE DELETE ON auditoria
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La auditoria no se puede borrar.';
END$$

-- Cada cambio de estado del formulario queda en el historial.
-- La aplicacion indica quien lo hizo con:  SET @usuario_id = 7;
-- (si no lo indica, queda NULL = el propio tercero o el sistema).
CREATE TRIGGER tr_formularios_historial_alta AFTER INSERT ON formularios
FOR EACH ROW
BEGIN
  INSERT INTO formulario_estados (formulario_id, estado_anterior, estado_nuevo, usuario_id)
  VALUES (NEW.id, NULL, NEW.estado, @usuario_id);
END$$

CREATE TRIGGER tr_formularios_historial_cambio AFTER UPDATE ON formularios
FOR EACH ROW
BEGIN
  IF NOT (NEW.estado <=> OLD.estado) THEN
    INSERT INTO formulario_estados (formulario_id, estado_anterior, estado_nuevo, usuario_id, observacion)
    VALUES (NEW.id, OLD.estado, NEW.estado, @usuario_id,
            IF(NEW.estado IN ('devuelto','rechazado','aprobado'), NEW.observacion_revision, NULL));
  END IF;
END$$

-- Un formulario aprobado o rechazado ya no se edita: el tercero debe
-- diligenciar uno nuevo en el siguiente periodo.
CREATE TRIGGER tr_formularios_cerrado BEFORE UPDATE ON formularios
FOR EACH ROW
BEGIN
  IF OLD.estado IN ('aprobado','rechazado') AND NOT (NEW.estado <=> OLD.estado) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un formulario aprobado o rechazado no cambia de estado.';
  END IF;
END$$

DELIMITER ;


-- =====================================================================
-- F. VISTAS
-- =====================================================================

-- Bandeja del equipo: una fila por formulario, con el peor resultado de
-- sus consultas en listas. Es la tabla "Formularios recientes" de inicio.
CREATE OR REPLACE VIEW v_bandeja_formularios AS
SELECT
  f.id                AS formulario_id,
  f.radicado,
  f.periodo,
  f.tipo,
  f.estado,
  f.nivel_riesgo,
  f.actualizado_en,
  f.vence_en,
  t.id                AS tercero_id,
  t.nombre            AS tercero,
  t.tipo_persona,
  CONCAT(t.tipo_documento, ' ', t.numero_documento,
         IF(t.digito_verificacion IS NULL, '', CONCAT('-', t.digito_verificacion))) AS documento,
  (SELECT GROUP_CONCAT(r.relacion ORDER BY r.relacion SEPARATOR ', ')
     FROM tercero_relaciones r
    WHERE r.tercero_id = t.id AND r.activa) AS relaciones,
  COALESCE(
    (SELECT ELT(MAX(FIELD(c.resultado, 'sin_coincidencia','error','coincidencia_parcial','coincidencia_exacta')),
                'sin_coincidencia','error','coincidencia_parcial','coincidencia_exacta')
       FROM consultas_listas c
      WHERE c.formulario_id = f.id),
    'por_consultar')  AS listas,
  (SELECT COUNT(*) FROM alertas a
    WHERE a.formulario_id = f.id AND a.estado IN ('abierta','en_analisis')) AS alertas_abiertas
FROM formularios f
JOIN terceros t ON t.id = f.tercero_id;

-- Vencimientos: ultimo formulario aprobado de cada tercero y cuantos
-- dias le quedan. "por_vencer" segun el parametro dias_aviso_vencimiento.
CREATE OR REPLACE VIEW v_vencimientos AS
SELECT
  t.id      AS tercero_id,
  t.nombre  AS tercero,
  t.correo,
  f.id      AS formulario_id,
  f.radicado,
  f.vence_en,
  DATEDIFF(f.vence_en, CURDATE()) AS dias_restantes,
  CASE
    WHEN f.vence_en < CURDATE() THEN 'vencido'
    WHEN DATEDIFF(f.vence_en, CURDATE()) <=
         COALESCE((SELECT CAST(p.valor AS UNSIGNED) FROM parametros p WHERE p.clave = 'dias_aviso_vencimiento'), 30)
      THEN 'por_vencer'
    ELSE 'vigente'
  END AS situacion
FROM terceros t
JOIN formularios f
  ON f.id = (SELECT f2.id FROM formularios f2
              WHERE f2.tercero_id = t.id AND f2.estado = 'aprobado'
              ORDER BY f2.periodo DESC LIMIT 1)
WHERE t.estado = 'activo';

-- Avance de cada formulario: cuantos pasos completos de cuantos.
CREATE OR REPLACE VIEW v_avance_formularios AS
SELECT
  f.id AS formulario_id,
  COUNT(m.id) AS modulos_total,
  SUM(fm.estado = 'completo')  AS modulos_completos,
  SUM(fm.estado = 'con_error') AS modulos_con_error,
  ROUND(100 * SUM(fm.estado = 'completo') / COUNT(m.id)) AS porcentaje
FROM formularios f
JOIN modulos m ON m.cuestionario_id = f.cuestionario_id
LEFT JOIN formulario_modulos fm ON fm.formulario_id = f.id AND fm.modulo_id = m.id
GROUP BY f.id;
