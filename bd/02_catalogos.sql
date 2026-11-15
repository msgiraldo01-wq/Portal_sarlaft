-- =====================================================================
-- PORTAL SARLAFT - 02_catalogos.sql
-- Datos de referencia y la primera version de los cuestionarios.
-- Ejecutar despues de 01_esquema.sql:
--   mysql -u root -p portal_sarlaft < bd/02_catalogos.sql
--
-- Lo que hay que COMPLETAR o VALIDAR antes de produccion:
--   - municipios: aqui van las capitales y todo Risaralda. Cargar el
--     archivo DIVIPOLA completo del DANE (unos 1.100 municipios).
--   - actividades_ciiu: aqui va una muestra. Cargar la tabla CIIU
--     Rev. 4 A.C. completa de la DIAN y calificar el riesgo de cada
--     actividad segun la matriz de riesgo de la entidad.
--   - paises.riesgo_gafi y la lista de paises de la pregunta de
--     operaciones internacionales: validar contra la ultima publicacion
--     del GAFI (cambia tres veces al ano).
--   - Los textos de las declaraciones: revisarlos con el oficial de
--     cumplimiento y el area juridica.
-- =====================================================================

USE portal_sarlaft;
SET NAMES utf8mb4;

-- Tipos de documento
INSERT INTO tipos_documento (codigo, nombre, tipo_persona) VALUES
  ('NIT', 'Número de identificación tributaria', 'juridica'),
  ('CC', 'Cédula de ciudadanía', 'natural'),
  ('CE', 'Cédula de extranjería', 'natural'),
  ('PPT', 'Permiso por protección temporal', 'natural'),
  ('PA', 'Pasaporte', 'natural'),
  ('TI', 'Tarjeta de identidad', 'natural');

-- Paises (seleccion; completar con ISO 3166-1 si se necesitan mas).
-- riesgo_gafi = 'accion': Corea del Norte, Iran y Myanmar llevan varios anos en el llamado a la
-- accion del GAFI. La lista de vigilancia ('vigilancia') cambia en cada plenaria: marcarla con
--   UPDATE paises SET riesgo_gafi = 'vigilancia' WHERE codigo IN (...);
INSERT INTO paises (codigo, nombre, riesgo_gafi) VALUES
  ('CO', 'Colombia', 'ninguno'),
  ('AR', 'Argentina', 'ninguno'),
  ('BO', 'Bolivia', 'ninguno'),
  ('BR', 'Brasil', 'ninguno'),
  ('CL', 'Chile', 'ninguno'),
  ('EC', 'Ecuador', 'ninguno'),
  ('PY', 'Paraguay', 'ninguno'),
  ('PE', 'Perú', 'ninguno'),
  ('UY', 'Uruguay', 'ninguno'),
  ('VE', 'Venezuela', 'ninguno'),
  ('GY', 'Guyana', 'ninguno'),
  ('SR', 'Surinam', 'ninguno'),
  ('MX', 'México', 'ninguno'),
  ('GT', 'Guatemala', 'ninguno'),
  ('HN', 'Honduras', 'ninguno'),
  ('SV', 'El Salvador', 'ninguno'),
  ('NI', 'Nicaragua', 'ninguno'),
  ('CR', 'Costa Rica', 'ninguno'),
  ('PA', 'Panamá', 'ninguno'),
  ('BZ', 'Belice', 'ninguno'),
  ('CU', 'Cuba', 'ninguno'),
  ('DO', 'República Dominicana', 'ninguno'),
  ('HT', 'Haití', 'ninguno'),
  ('JM', 'Jamaica', 'ninguno'),
  ('PR', 'Puerto Rico', 'ninguno'),
  ('TT', 'Trinidad y Tobago', 'ninguno'),
  ('BS', 'Bahamas', 'ninguno'),
  ('BB', 'Barbados', 'ninguno'),
  ('AW', 'Aruba', 'ninguno'),
  ('CW', 'Curazao', 'ninguno'),
  ('KY', 'Islas Caimán', 'ninguno'),
  ('VG', 'Islas Vírgenes Británicas', 'ninguno'),
  ('BM', 'Bermudas', 'ninguno'),
  ('US', 'Estados Unidos', 'ninguno'),
  ('CA', 'Canadá', 'ninguno'),
  ('ES', 'España', 'ninguno'),
  ('PT', 'Portugal', 'ninguno'),
  ('FR', 'Francia', 'ninguno'),
  ('DE', 'Alemania', 'ninguno'),
  ('IT', 'Italia', 'ninguno');
INSERT INTO paises (codigo, nombre, riesgo_gafi) VALUES
  ('GB', 'Reino Unido', 'ninguno'),
  ('IE', 'Irlanda', 'ninguno'),
  ('NL', 'Países Bajos', 'ninguno'),
  ('BE', 'Bélgica', 'ninguno'),
  ('LU', 'Luxemburgo', 'ninguno'),
  ('CH', 'Suiza', 'ninguno'),
  ('AT', 'Austria', 'ninguno'),
  ('SE', 'Suecia', 'ninguno'),
  ('NO', 'Noruega', 'ninguno'),
  ('DK', 'Dinamarca', 'ninguno'),
  ('FI', 'Finlandia', 'ninguno'),
  ('PL', 'Polonia', 'ninguno'),
  ('CZ', 'Chequia', 'ninguno'),
  ('GR', 'Grecia', 'ninguno'),
  ('RO', 'Rumania', 'ninguno'),
  ('BG', 'Bulgaria', 'ninguno'),
  ('HR', 'Croacia', 'ninguno'),
  ('RU', 'Rusia', 'ninguno'),
  ('UA', 'Ucrania', 'ninguno'),
  ('TR', 'Turquía', 'ninguno'),
  ('MC', 'Mónaco', 'ninguno'),
  ('AD', 'Andorra', 'ninguno'),
  ('LI', 'Liechtenstein', 'ninguno'),
  ('MT', 'Malta', 'ninguno'),
  ('CY', 'Chipre', 'ninguno'),
  ('CN', 'China', 'ninguno'),
  ('JP', 'Japón', 'ninguno'),
  ('KR', 'Corea del Sur', 'ninguno'),
  ('KP', 'Corea del Norte', 'accion'),
  ('IN', 'India', 'ninguno'),
  ('PK', 'Pakistán', 'ninguno'),
  ('ID', 'Indonesia', 'ninguno'),
  ('PH', 'Filipinas', 'ninguno'),
  ('VN', 'Vietnam', 'ninguno'),
  ('TH', 'Tailandia', 'ninguno'),
  ('MY', 'Malasia', 'ninguno'),
  ('SG', 'Singapur', 'ninguno'),
  ('HK', 'Hong Kong', 'ninguno'),
  ('TW', 'Taiwán', 'ninguno'),
  ('LA', 'Laos', 'ninguno');
INSERT INTO paises (codigo, nombre, riesgo_gafi) VALUES
  ('MM', 'Myanmar', 'accion'),
  ('NP', 'Nepal', 'ninguno'),
  ('AU', 'Australia', 'ninguno'),
  ('NZ', 'Nueva Zelanda', 'ninguno'),
  ('PG', 'Papúa Nueva Guinea', 'ninguno'),
  ('IL', 'Israel', 'ninguno'),
  ('LB', 'Líbano', 'ninguno'),
  ('SY', 'Siria', 'ninguno'),
  ('IR', 'Irán', 'accion'),
  ('IQ', 'Irak', 'ninguno'),
  ('AE', 'Emiratos Árabes Unidos', 'ninguno'),
  ('SA', 'Arabia Saudita', 'ninguno'),
  ('QA', 'Catar', 'ninguno'),
  ('YE', 'Yemen', 'ninguno'),
  ('KW', 'Kuwait', 'ninguno'),
  ('ZA', 'Sudáfrica', 'ninguno'),
  ('NG', 'Nigeria', 'ninguno'),
  ('KE', 'Kenia', 'ninguno'),
  ('EG', 'Egipto', 'ninguno'),
  ('MA', 'Marruecos', 'ninguno'),
  ('DZ', 'Argelia', 'ninguno'),
  ('AO', 'Angola', 'ninguno'),
  ('CM', 'Camerún', 'ninguno'),
  ('CI', 'Costa de Marfil', 'ninguno'),
  ('CD', 'República Democrática del Congo', 'ninguno'),
  ('NA', 'Namibia', 'ninguno'),
  ('SS', 'Sudán del Sur', 'ninguno'),
  ('MZ', 'Mozambique', 'ninguno'),
  ('ML', 'Malí', 'ninguno'),
  ('BF', 'Burkina Faso', 'ninguno');

-- Departamentos (DIVIPOLA, completo)
INSERT INTO departamentos (codigo, nombre) VALUES
  ('05', 'Antioquia'),
  ('08', 'Atlántico'),
  ('11', 'Bogotá, D.C.'),
  ('13', 'Bolívar'),
  ('15', 'Boyacá'),
  ('17', 'Caldas'),
  ('18', 'Caquetá'),
  ('19', 'Cauca'),
  ('20', 'Cesar'),
  ('23', 'Córdoba'),
  ('25', 'Cundinamarca'),
  ('27', 'Chocó'),
  ('41', 'Huila'),
  ('44', 'La Guajira'),
  ('47', 'Magdalena'),
  ('50', 'Meta'),
  ('52', 'Nariño'),
  ('54', 'Norte de Santander'),
  ('63', 'Quindío'),
  ('66', 'Risaralda'),
  ('68', 'Santander'),
  ('70', 'Sucre'),
  ('73', 'Tolima'),
  ('76', 'Valle del Cauca'),
  ('81', 'Arauca'),
  ('85', 'Casanare'),
  ('86', 'Putumayo'),
  ('88', 'Archipiélago de San Andrés, Providencia y Santa Catalina'),
  ('91', 'Amazonas'),
  ('94', 'Guainía'),
  ('95', 'Guaviare'),
  ('97', 'Vaupés'),
  ('99', 'Vichada');

-- Municipios: capitales, Soacha, Cartago y todo Risaralda. Completar con DIVIPOLA.
INSERT INTO municipios (codigo, departamento_codigo, nombre) VALUES
  ('05001', '05', 'Medellín'),
  ('08001', '08', 'Barranquilla'),
  ('11001', '11', 'Bogotá, D.C.'),
  ('13001', '13', 'Cartagena de Indias'),
  ('15001', '15', 'Tunja'),
  ('17001', '17', 'Manizales'),
  ('18001', '18', 'Florencia'),
  ('19001', '19', 'Popayán'),
  ('20001', '20', 'Valledupar'),
  ('23001', '23', 'Montería'),
  ('25754', '25', 'Soacha'),
  ('27001', '27', 'Quibdó'),
  ('41001', '41', 'Neiva'),
  ('44001', '44', 'Riohacha'),
  ('47001', '47', 'Santa Marta'),
  ('50001', '50', 'Villavicencio'),
  ('52001', '52', 'Pasto'),
  ('54001', '54', 'San José de Cúcuta'),
  ('63001', '63', 'Armenia'),
  ('68001', '68', 'Bucaramanga'),
  ('70001', '70', 'Sincelejo'),
  ('73001', '73', 'Ibagué'),
  ('76001', '76', 'Cali'),
  ('76147', '76', 'Cartago'),
  ('81001', '81', 'Arauca'),
  ('85001', '85', 'Yopal'),
  ('86001', '86', 'Mocoa'),
  ('88001', '88', 'San Andrés'),
  ('91001', '91', 'Leticia'),
  ('94001', '94', 'Inírida'),
  ('95001', '95', 'San José del Guaviare'),
  ('97001', '97', 'Mitú'),
  ('99001', '99', 'Puerto Carreño'),
  ('66001', '66', 'Pereira'),
  ('66045', '66', 'Apía'),
  ('66075', '66', 'Balboa'),
  ('66088', '66', 'Belén de Umbría'),
  ('66170', '66', 'Dosquebradas'),
  ('66318', '66', 'Guática'),
  ('66383', '66', 'La Celia');
INSERT INTO municipios (codigo, departamento_codigo, nombre) VALUES
  ('66400', '66', 'La Virginia'),
  ('66440', '66', 'Marsella'),
  ('66456', '66', 'Mistrató'),
  ('66572', '66', 'Pueblo Rico'),
  ('66594', '66', 'Quinchía'),
  ('66682', '66', 'Santa Rosa de Cabal'),
  ('66687', '66', 'Santuario');

-- Actividades CIIU (muestra). El riesgo es un EJEMPLO: lo define la matriz de riesgo de la entidad.
INSERT INTO actividades_ciiu (codigo, descripcion, riesgo) VALUES
  ('0010', 'Asalariados', 'bajo'),
  ('0081', 'Personas naturales sin actividad económica', 'bajo'),
  ('0082', 'Personas naturales subsidiadas por terceros', 'bajo'),
  ('0090', 'Rentistas de capital, solo para personas naturales', 'medio'),
  ('2100', 'Fabricación de productos farmacéuticos, sustancias químicas medicinales y productos botánicos de uso farmacéutico', 'bajo'),
  ('3250', 'Fabricación de instrumentos, aparatos y materiales médicos y odontológicos (incluido mobiliario)', 'bajo'),
  ('4111', 'Construcción de edificios residenciales', 'medio'),
  ('4645', 'Comercio al por mayor de productos farmacéuticos, medicinales, cosméticos y de tocador', 'bajo'),
  ('4659', 'Comercio al por mayor de otros tipos de maquinaria y equipo n.c.p.', 'bajo'),
  ('4773', 'Comercio al por menor de productos farmacéuticos y medicinales, cosméticos y artículos de tocador en establecimientos especializados', 'bajo'),
  ('4923', 'Transporte de carga por carretera', 'bajo'),
  ('5611', 'Expendio a la mesa de comidas preparadas', 'bajo'),
  ('6201', 'Actividades de desarrollo de sistemas informáticos (planificación, análisis, diseño, programación, pruebas)', 'bajo'),
  ('6202', 'Actividades de consultoría informática y actividades de administración de instalaciones informáticas', 'bajo'),
  ('6420', 'Actividades de sociedades de cartera', 'medio'),
  ('6499', 'Otras actividades de servicio financiero, excepto las de seguros y pensiones n.c.p.', 'alto'),
  ('6810', 'Actividades inmobiliarias realizadas con bienes propios o arrendados', 'medio'),
  ('6910', 'Actividades jurídicas', 'bajo'),
  ('6920', 'Actividades de contabilidad, teneduría de libros, auditoría financiera y asesoría tributaria', 'bajo'),
  ('7020', 'Actividades de consultoría de gestión', 'bajo'),
  ('8010', 'Actividades de seguridad privada', 'bajo'),
  ('8121', 'Limpieza general interior de edificios', 'bajo'),
  ('8610', 'Actividades de hospitales y clínicas, con internación', 'bajo'),
  ('8621', 'Actividades de la práctica médica, sin internación', 'bajo'),
  ('8622', 'Actividades de la práctica odontológica', 'bajo'),
  ('8691', 'Actividades de apoyo diagnóstico', 'bajo'),
  ('8692', 'Actividades de apoyo terapéutico', 'bajo'),
  ('8699', 'Otras actividades de atención de la salud humana', 'bajo');

-- Parentescos (familiares de PEP segun el Decreto 830 de 2021: conyuge o companero permanente,
-- hasta segundo grado de consanguinidad, segundo de afinidad y primero civil)
INSERT INTO parentescos (id, nombre, tipo, grado) VALUES
  (1, 'Cónyuge', 'pareja', NULL),
  (2, 'Compañero(a) permanente', 'pareja', NULL),
  (3, 'Padre o madre', 'consanguinidad', 1),
  (4, 'Hijo(a)', 'consanguinidad', 1),
  (5, 'Hermano(a)', 'consanguinidad', 2),
  (6, 'Abuelo(a)', 'consanguinidad', 2),
  (7, 'Nieto(a)', 'consanguinidad', 2),
  (8, 'Tío(a)', 'consanguinidad', 3),
  (9, 'Sobrino(a)', 'consanguinidad', 3),
  (10, 'Primo(a)', 'consanguinidad', 4),
  (11, 'Suegro(a)', 'afinidad', 1),
  (12, 'Hijastro(a)', 'afinidad', 1),
  (13, 'Yerno o nuera', 'afinidad', 1),
  (14, 'Cuñado(a)', 'afinidad', 2),
  (15, 'Padre o madre adoptante', 'civil', 1),
  (16, 'Hijo(a) adoptivo(a)', 'civil', 1);

-- Listas que se consultan
INSERT INTO listas_restrictivas (codigo, nombre, fuente, vinculante) VALUES
  ('ONU', 'Lista consolidada del Consejo de Seguridad', 'Organización de las Naciones Unidas', TRUE),
  ('OFAC', 'Lista SDN (Specially Designated Nationals)', 'Departamento del Tesoro de Estados Unidos', FALSE),
  ('UE', 'Lista consolidada de sanciones financieras', 'Unión Europea', FALSE),
  ('PROCURADURIA', 'Antecedentes disciplinarios', 'Procuraduría General de la Nación', FALSE),
  ('CONTRALORIA', 'Boletín de responsables fiscales', 'Contraloría General de la República', FALSE),
  ('POLICIA', 'Antecedentes judiciales', 'Policía Nacional de Colombia', FALSE);

-- Soportes. vigencia_dias = antiguedad maxima del documento. Ajustar con el oficial de cumplimiento.
INSERT INTO tipos_soporte (codigo, nombre, tipo_persona, relaciones, obligatorio, vigencia_dias) VALUES
  ('RUT', 'Registro Único Tributario (RUT)', 'ambas', NULL, TRUE, NULL),
  ('CAMARA_COMERCIO', 'Certificado de existencia y representación legal', 'juridica', NULL, TRUE, 30),
  ('CEDULA_REPRESENTANTE', 'Documento de identidad del representante legal', 'juridica', NULL, TRUE, NULL),
  ('ESTADOS_FINANCIEROS', 'Estados financieros del último cierre', 'juridica', 'proveedor,cliente,accionista', TRUE, NULL),
  ('CERTIFICACION_BANCARIA', 'Certificación bancaria', 'ambas', 'proveedor', TRUE, 30),
  ('DOCUMENTO_IDENTIDAD', 'Documento de identidad', 'natural', NULL, TRUE, NULL),
  ('DECLARACION_RENTA', 'Declaración de renta del último año', 'natural', 'proveedor,cliente,accionista', FALSE, NULL),
  ('COMPOSICION_ACCIONARIA', 'Composición accionaria certificada por revisor fiscal o contador', 'juridica', 'proveedor,cliente,accionista', FALSE, 90);

-- Parametros editables desde Ajustes
INSERT INTO parametros (clave, valor, tipo, descripcion) VALUES
  ('periodicidad_actualizacion_meses', '12', 'entero', 'Cada cuántos meses debe actualizar su información un tercero aprobado'),
  ('dias_aviso_vencimiento', '30', 'entero', 'Con cuántos días de anticipación se avisa que vence la actualización'),
  ('codigo_vigencia_minutos', '10', 'entero', 'Minutos que dura un código de verificación'),
  ('codigo_intentos_maximos', '5', 'entero', 'Intentos permitidos por código antes de invalidarlo'),
  ('codigo_reenvio_segundos', '60', 'entero', 'Segundos de espera antes de poder pedir otro código'),
  ('soporte_tamano_maximo_mb', '2', 'decimal', 'Tamaño máximo de cada documento soporte'),
  ('soporte_tipos_permitidos', 'application/pdf', 'texto', 'Tipos de archivo aceptados, separados por coma'),
  ('invitacion_vigencia_dias', '15', 'entero', 'Días que dura el enlace de una invitación'),
  ('sesion_inactividad_minutos', '30', 'entero', 'Minutos de inactividad antes de cerrar la sesión'),
  ('prefijo_radicado', 'SRL', 'texto', 'Prefijo del número de radicado');

-- =====================================================================
-- CUESTIONARIOS, VERSION 1
-- Ids fijos para que los datos de prueba y los reportes los encuentren:
--   cuestionario 1 = persona juridica (modulos 101-111, preguntas 1001+)
--   cuestionario 2 = persona natural  (modulos 201-208, preguntas 2001+)
-- Las versiones futuras se crean desde Ajustes, con ids automaticos.
-- =====================================================================

-- ---- Formulario de vinculación y actualización de persona jurídica
INSERT INTO cuestionarios (id, nombre, tipo_persona, version, estado, publicado_en, notas) VALUES
  (1, 'Formulario de vinculación y actualización de persona jurídica', 'juridica', 1, 'publicado', '2026-11-06 00:00:00', 'Versión inicial. Circular Externa 009 de 2016 de la Supersalud y sus modificaciones; Decreto 830 de 2021 (PEP); Resolución DIAN 164 de 2021 (beneficiario final).');
INSERT INTO modulos (id, cuestionario_id, orden, nombre, descripcion) VALUES
  (101, 1, 1, 'Identificación', 'Datos de quien firma el formulario en nombre de la empresa.'),
  (102, 1, 2, 'Información general', 'Ubicación y actividad económica de la empresa.'),
  (103, 1, 3, 'Representante legal', 'Datos del representante legal principal y de sus suplentes, como figuran en el certificado de existencia y representación legal.'),
  (104, 1, 4, 'Personas expuestas políticamente', 'Preguntas sobre el representante legal, los miembros de junta directiva, los accionistas y los beneficiarios finales.'),
  (105, 1, 5, 'Operaciones internacionales', NULL),
  (106, 1, 6, 'Activos virtuales', 'Los activos virtuales son representaciones digitales de valor que se pueden comercializar, transferir o usar como medio de pago o inversión, sin respaldo de una moneda de curso legal; por ejemplo, criptomonedas, tokens y monedas estables. Responda si realiza alguna de estas operaciones.'),
  (107, 1, 7, 'Información financiera', 'Cifras del último cierre contable, en pesos colombianos.'),
  (108, 1, 8, 'Origen de fondos', NULL),
  (109, 1, 9, 'Accionistas y beneficiarios', 'Composición de la empresa. Si la entidad es pública, deje vacías las secciones que no apliquen.'),
  (110, 1, 10, 'Declaraciones', NULL),
  (111, 1, 11, 'Soportes y firma', 'Cargue los documentos y firme con el código que le enviaremos.');
INSERT INTO preguntas (id, modulo_id, orden, codigo, enunciado, ayuda, tipo, obligatoria, relaciones, depende_de_pregunta_id, depende_de_valor, alerta_si_valor) VALUES
  (1001, 102, 10, 'productos_servicios', '¿Qué tipo de producto o servicio ofrece a la entidad?', NULL, 'multiple', TRUE, 'proveedor', NULL, NULL, NULL),
  (1002, 104, 10, 'pep_recursos_publicos', '¿Alguno de ellos maneja recursos públicos?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (1003, 104, 20, 'pep_reconocimiento', '¿Alguno de ellos goza de reconocimiento público?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (1004, 104, 30, 'pep_poder_publico', '¿Alguno de ellos ejerce algún grado de poder público?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (1005, 104, 40, 'pep_servidor_publico', '¿Alguno de ellos es servidor público?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (1006, 104, 50, 'pep_decreto_830', '¿Alguno de ellos está clasificado como Persona Expuesta Políticamente (PEP) según el Decreto 830 de 2021?', 'Son PEP, entre otros, los servidores públicos que ordenan gasto, contratan o dirigen proyectos de inversión; por ejemplo: presidente, ministros, congresistas, gobernadores, alcaldes, concejales y diputados.', 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (1007, 105, 10, 'opint_realiza', '¿La empresa realiza operaciones en moneda extranjera o con el exterior?', NULL, 'si_no', TRUE, NULL, NULL, NULL, NULL),
  (1008, 105, 20, 'opint_tipos', '¿Qué tipo de operaciones realiza?', NULL, 'multiple', TRUE, NULL, 1007, 'si', NULL),
  (1009, 105, 30, 'opint_paises', '¿Alguna de esas operaciones es con los siguientes países?', 'Jurisdicciones de mayor riesgo según el GAFI. La lista se actualiza después de cada plenaria del GAFI.', 'multiple', TRUE, NULL, 1007, 'si', NULL),
  (1010, 105, 40, 'opint_cuentas', '¿La empresa tiene cuentas o productos financieros en el exterior?', NULL, 'si_no', TRUE, NULL, NULL, NULL, NULL),
  (1011, 105, 50, 'opint_cuentas_detalle', 'Indique entidad, país y moneda de cada cuenta o producto', NULL, 'texto_largo', TRUE, NULL, 1010, 'si', NULL),
  (1012, 106, 10, 'av_fiat', '¿Intercambia activos virtuales por dinero de curso legal (pesos, dólares u otras monedas)?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (1013, 106, 20, 'av_entre', '¿Intercambia una forma de activo virtual por otra?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (1014, 106, 30, 'av_transferencias', '¿Hace transferencias de activos virtuales?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (1015, 106, 40, 'av_custodia', '¿Custodia o administra activos virtuales, o instrumentos que permitan controlarlos?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (1016, 106, 50, 'av_servicios_emisor', '¿Participa o presta servicios financieros relacionados con la oferta de un emisor o la venta de un activo virtual?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (1017, 106, 60, 'av_otro_servicio', '¿Ha prestado algún otro servicio relacionado con activos virtuales?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (1018, 108, 10, 'origen_fondos', 'Los bienes y recursos de la empresa provienen de:', NULL, 'multiple', TRUE, NULL, NULL, NULL, NULL),
  (1019, 108, 20, 'origen_licito', 'Declaro que los recursos de la empresa provienen de actividades lícitas y que no se destinarán a la financiación del terrorismo ni de la proliferación de armas de destrucción masiva.', NULL, 'aceptacion', TRUE, NULL, NULL, NULL, NULL),
  (1020, 109, 10, 'grupo_pertenece', '¿La empresa hace parte de un grupo empresarial?', NULL, 'si_no', TRUE, NULL, NULL, NULL, NULL);
INSERT INTO preguntas (id, modulo_id, orden, codigo, enunciado, ayuda, tipo, obligatoria, relaciones, depende_de_pregunta_id, depende_de_valor, alerta_si_valor) VALUES
  (1021, 110, 10, 'decl_parentesco_directivos', '¿Algún empleado de la empresa tiene parentesco con directivos o colaboradores de la entidad que puedan influir en la contratación?', 'Incluya parentesco hasta cuarto grado de consanguinidad, segundo de afinidad y primero civil.', 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (1022, 110, 20, 'decl_obligado_regulacion', '¿La empresa está obligada a cumplir alguna regulación de prevención del lavado de activos, la financiación del terrorismo o el soborno?', NULL, 'si_no', TRUE, NULL, NULL, NULL, NULL),
  (1023, 110, 30, 'decl_tiene_sistema', '¿La empresa tiene implementado un sistema o medidas para prevenir el lavado de activos, la financiación del terrorismo y el soborno?', NULL, 'si_no', TRUE, NULL, NULL, NULL, NULL),
  (1024, 110, 40, 'decl_veracidad', 'Declaro que la información de este formulario es veraz, completa y verificable, y me comprometo a actualizarla cuando cambie o al menos una vez al año.', NULL, 'aceptacion', TRUE, NULL, NULL, NULL, NULL),
  (1025, 110, 50, 'decl_tratamiento_datos', 'Autorizo el tratamiento de los datos personales de este formulario para el conocimiento de terceros y la prevención del lavado de activos, la financiación del terrorismo y la proliferación de armas de destrucción masiva, conforme a la Ley 1581 de 2012 y la política de tratamiento de datos de la entidad.', NULL, 'aceptacion', TRUE, NULL, NULL, NULL, NULL),
  (1026, 110, 60, 'decl_anticorrupcion', 'Declaro que no he ofrecido ni ofreceré pagos, dádivas o beneficios indebidos a trabajadores de la entidad, que no me encuentro en causales de inhabilidad o incompatibilidad para contratar con ella y que acataré sus políticas de prevención del soborno y la corrupción.', NULL, 'aceptacion', TRUE, NULL, NULL, NULL, NULL);
INSERT INTO pregunta_opciones (pregunta_id, orden, valor, etiqueta, pide_detalle, excluyente, genera_alerta) VALUES
  (1001, 10, 'suministros_medicos', 'Suministros médicos o farmacéuticos', FALSE, FALSE, FALSE),
  (1001, 20, 'servicios_salud', 'Servicios de salud', FALSE, FALSE, FALSE),
  (1001, 30, 'tecnologia', 'Tecnología y sistemas de información', FALSE, FALSE, FALSE),
  (1001, 40, 'administrativos', 'Servicios administrativos o de gestión', FALSE, FALSE, FALSE),
  (1001, 50, 'consultoria', 'Consultoría o asesoría especializada', FALSE, FALSE, FALSE),
  (1001, 60, 'otro', 'Otro', TRUE, FALSE, FALSE),
  (1008, 10, 'importaciones', 'Importaciones', FALSE, FALSE, FALSE),
  (1008, 20, 'exportaciones', 'Exportaciones', FALSE, FALSE, FALSE),
  (1008, 30, 'inversiones', 'Inversiones', FALSE, FALSE, FALSE),
  (1008, 40, 'prestamos', 'Préstamos', FALSE, FALSE, FALSE),
  (1008, 50, 'giros', 'Giros', FALSE, FALSE, FALSE),
  (1008, 60, 'transferencias', 'Transferencias', FALSE, FALSE, FALSE),
  (1008, 70, 'pago_servicios', 'Pago de servicios', FALSE, FALSE, FALSE),
  (1008, 80, 'otro', 'Otro', TRUE, FALSE, FALSE),
  (1009, 10, 'ninguno', 'Ninguno', FALSE, TRUE, FALSE),
  (1009, 20, 'DZ', 'Argelia', FALSE, FALSE, TRUE),
  (1009, 30, 'AO', 'Angola', FALSE, FALSE, TRUE),
  (1009, 40, 'BO', 'Bolivia', FALSE, FALSE, TRUE),
  (1009, 50, 'BG', 'Bulgaria', FALSE, FALSE, TRUE),
  (1009, 60, 'CM', 'Camerún', FALSE, FALSE, TRUE),
  (1009, 70, 'CI', 'Costa de Marfil', FALSE, FALSE, TRUE),
  (1009, 80, 'KP', 'Corea del Norte', FALSE, FALSE, TRUE),
  (1009, 90, 'HT', 'Haití', FALSE, FALSE, TRUE),
  (1009, 100, 'IR', 'Irán', FALSE, FALSE, TRUE),
  (1009, 110, 'VG', 'Islas Vírgenes Británicas', FALSE, FALSE, TRUE),
  (1009, 120, 'KE', 'Kenia', FALSE, FALSE, TRUE),
  (1009, 130, 'LA', 'Laos', FALSE, FALSE, TRUE),
  (1009, 140, 'LB', 'Líbano', FALSE, FALSE, TRUE),
  (1009, 150, 'MC', 'Mónaco', FALSE, FALSE, TRUE),
  (1009, 160, 'MM', 'Myanmar', FALSE, FALSE, TRUE),
  (1009, 170, 'NA', 'Namibia', FALSE, FALSE, TRUE),
  (1009, 180, 'NP', 'Nepal', FALSE, FALSE, TRUE),
  (1009, 190, 'PG', 'Papúa Nueva Guinea', FALSE, FALSE, TRUE),
  (1009, 200, 'CD', 'República Democrática del Congo', FALSE, FALSE, TRUE),
  (1009, 210, 'SY', 'Siria', FALSE, FALSE, TRUE),
  (1009, 220, 'SS', 'Sudán del Sur', FALSE, FALSE, TRUE),
  (1009, 230, 'VE', 'Venezuela', FALSE, FALSE, TRUE),
  (1009, 240, 'VN', 'Vietnam', FALSE, FALSE, TRUE),
  (1009, 250, 'YE', 'Yemen', FALSE, FALSE, TRUE),
  (1018, 10, 'objeto_social', 'Desarrollo del objeto social', FALSE, FALSE, FALSE);
INSERT INTO pregunta_opciones (pregunta_id, orden, valor, etiqueta, pide_detalle, excluyente, genera_alerta) VALUES
  (1018, 20, 'inversiones', 'Inversiones', FALSE, FALSE, FALSE),
  (1018, 30, 'rentas', 'Rentas o arrendamientos', FALSE, FALSE, FALSE),
  (1018, 40, 'prestamos', 'Préstamos o financiación', FALSE, FALSE, FALSE),
  (1018, 50, 'aportes_socios', 'Aportes de socios', FALSE, FALSE, FALSE),
  (1018, 60, 'otro', 'Otro', TRUE, FALSE, FALSE);
INSERT INTO modulo_secciones (modulo_id, orden, componente, titulo, instrucciones, obligatoria, minimo_filas, depende_de_pregunta_id, depende_de_valor) VALUES
  (101, 1, 'firmante', 'Representante legal o apoderado que firmará', 'Recibirá en su celular y su correo el código para firmar.', TRUE, 1, NULL, NULL),
  (102, 1, 'datos_generales', 'Datos generales de la empresa', NULL, TRUE, 0, NULL, NULL),
  (103, 1, 'representante_principal', 'Representante legal principal', NULL, TRUE, 1, NULL, NULL),
  (103, 2, 'representantes_suplentes', 'Representantes legales suplentes', 'Opcional. Agregue a cada suplente que figure en el certificado.', FALSE, 0, NULL, NULL),
  (104, 1, 'familiares_pep', 'Familiares y asociados de la persona PEP', 'Relacione al cónyuge o compañero permanente y a los familiares hasta segundo grado de consanguinidad, segundo de afinidad y primero civil.', TRUE, 1, 1006, 'si'),
  (107, 1, 'financiero', 'Información financiera', NULL, TRUE, 0, NULL, NULL),
  (109, 1, 'accionistas', 'Accionistas o asociados', 'Si son muchos, relacione los de mayor participación y adjunte la composición accionaria.', TRUE, 1, NULL, NULL),
  (109, 2, 'junta_directiva', 'Miembros de la junta directiva', NULL, FALSE, 0, NULL, NULL),
  (109, 3, 'beneficiarios_finales', 'Beneficiarios finales', 'Personas naturales que, directa o indirectamente, son dueñas o controlan la empresa (Resolución DIAN 164 de 2021).', TRUE, 1, NULL, NULL),
  (109, 4, 'grupo_empresarial', 'Empresas del grupo empresarial', NULL, TRUE, 1, 1020, 'si'),
  (110, 1, 'parientes_directivos', 'Parientes en la entidad', NULL, TRUE, 1, 1021, 'si'),
  (111, 1, 'soportes', 'Documentos soporte', NULL, TRUE, 0, NULL, NULL),
  (111, 2, 'firma', 'Firma y envío', NULL, TRUE, 0, NULL, NULL);

-- ---- Formulario de vinculación y actualización de persona natural
INSERT INTO cuestionarios (id, nombre, tipo_persona, version, estado, publicado_en, notas) VALUES
  (2, 'Formulario de vinculación y actualización de persona natural', 'natural', 1, 'publicado', '2026-11-06 00:00:00', 'Versión inicial. Circular Externa 009 de 2016 de la Supersalud y sus modificaciones; Decreto 830 de 2021 (PEP); Resolución DIAN 164 de 2021 (beneficiario final).');
INSERT INTO modulos (id, cuestionario_id, orden, nombre, descripcion) VALUES
  (201, 2, 1, 'Datos personales', 'Sus datos personales, ubicación y actividad económica.'),
  (202, 2, 2, 'Personas expuestas políticamente', NULL),
  (203, 2, 3, 'Operaciones internacionales', NULL),
  (204, 2, 4, 'Activos virtuales', 'Los activos virtuales son representaciones digitales de valor que se pueden comercializar, transferir o usar como medio de pago o inversión, sin respaldo de una moneda de curso legal; por ejemplo, criptomonedas, tokens y monedas estables. Responda si realiza alguna de estas operaciones.'),
  (205, 2, 5, 'Información financiera', 'Cifras de su último año, en pesos colombianos.'),
  (206, 2, 6, 'Origen de fondos', NULL),
  (207, 2, 7, 'Declaraciones', NULL),
  (208, 2, 8, 'Soportes y firma', 'Cargue los documentos y firme con el código que le enviaremos.');
INSERT INTO preguntas (id, modulo_id, orden, codigo, enunciado, ayuda, tipo, obligatoria, relaciones, depende_de_pregunta_id, depende_de_valor, alerta_si_valor) VALUES
  (2001, 202, 10, 'pep_recursos_publicos', '¿Maneja recursos públicos?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (2002, 202, 20, 'pep_reconocimiento', '¿Goza de reconocimiento público?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (2003, 202, 30, 'pep_poder_publico', '¿Ejerce algún grado de poder público?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (2004, 202, 40, 'pep_servidor_publico', '¿Es servidor público?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (2005, 202, 50, 'pep_decreto_830', '¿Está clasificado como Persona Expuesta Políticamente (PEP) según el Decreto 830 de 2021?', 'Son PEP, entre otros, los servidores públicos que ordenan gasto, contratan o dirigen proyectos de inversión; por ejemplo: presidente, ministros, congresistas, gobernadores, alcaldes, concejales y diputados.', 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (2006, 202, 60, 'pep_familiar', '¿Es familiar o asociado cercano de una Persona Expuesta Políticamente?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (2007, 203, 10, 'opint_realiza', '¿Usted realiza operaciones en moneda extranjera o con el exterior?', NULL, 'si_no', TRUE, NULL, NULL, NULL, NULL),
  (2008, 203, 20, 'opint_tipos', '¿Qué tipo de operaciones realiza?', NULL, 'multiple', TRUE, NULL, 2007, 'si', NULL),
  (2009, 203, 30, 'opint_paises', '¿Alguna de esas operaciones es con los siguientes países?', 'Jurisdicciones de mayor riesgo según el GAFI. La lista se actualiza después de cada plenaria del GAFI.', 'multiple', TRUE, NULL, 2007, 'si', NULL),
  (2010, 203, 40, 'opint_cuentas', '¿Usted tiene cuentas o productos financieros en el exterior?', NULL, 'si_no', TRUE, NULL, NULL, NULL, NULL),
  (2011, 203, 50, 'opint_cuentas_detalle', 'Indique entidad, país y moneda de cada cuenta o producto', NULL, 'texto_largo', TRUE, NULL, 2010, 'si', NULL),
  (2012, 204, 10, 'av_fiat', '¿Intercambia activos virtuales por dinero de curso legal (pesos, dólares u otras monedas)?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (2013, 204, 20, 'av_entre', '¿Intercambia una forma de activo virtual por otra?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (2014, 204, 30, 'av_transferencias', '¿Hace transferencias de activos virtuales?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (2015, 204, 40, 'av_custodia', '¿Custodia o administra activos virtuales, o instrumentos que permitan controlarlos?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (2016, 204, 50, 'av_servicios_emisor', '¿Participa o presta servicios financieros relacionados con la oferta de un emisor o la venta de un activo virtual?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (2017, 204, 60, 'av_otro_servicio', '¿Ha prestado algún otro servicio relacionado con activos virtuales?', NULL, 'si_no', TRUE, NULL, NULL, NULL, 'si'),
  (2018, 206, 10, 'origen_fondos', 'Sus bienes y recursos provienen de:', NULL, 'multiple', TRUE, NULL, NULL, NULL, NULL),
  (2019, 206, 20, 'origen_licito', 'Declaro que mis recursos provienen de actividades lícitas y que no se destinarán a la financiación del terrorismo ni de la proliferación de armas de destrucción masiva.', NULL, 'aceptacion', TRUE, NULL, NULL, NULL, NULL),
  (2020, 207, 10, 'decl_parentesco_directivos', '¿Tiene parentesco con directivos o colaboradores de la entidad que puedan influir en su vinculación o contratación?', 'Incluya parentesco hasta cuarto grado de consanguinidad, segundo de afinidad y primero civil.', 'si_no', TRUE, NULL, NULL, NULL, 'si');
INSERT INTO preguntas (id, modulo_id, orden, codigo, enunciado, ayuda, tipo, obligatoria, relaciones, depende_de_pregunta_id, depende_de_valor, alerta_si_valor) VALUES
  (2021, 207, 20, 'decl_veracidad', 'Declaro que la información de este formulario es veraz, completa y verificable, y me comprometo a actualizarla cuando cambie o al menos una vez al año.', NULL, 'aceptacion', TRUE, NULL, NULL, NULL, NULL),
  (2022, 207, 30, 'decl_tratamiento_datos', 'Autorizo el tratamiento de los datos personales de este formulario para el conocimiento de terceros y la prevención del lavado de activos, la financiación del terrorismo y la proliferación de armas de destrucción masiva, conforme a la Ley 1581 de 2012 y la política de tratamiento de datos de la entidad.', NULL, 'aceptacion', TRUE, NULL, NULL, NULL, NULL),
  (2023, 207, 40, 'decl_anticorrupcion', 'Declaro que no he ofrecido ni ofreceré pagos, dádivas o beneficios indebidos a trabajadores de la entidad, que no me encuentro en causales de inhabilidad o incompatibilidad para contratar con ella y que acataré sus políticas de prevención del soborno y la corrupción.', NULL, 'aceptacion', TRUE, NULL, NULL, NULL, NULL);
INSERT INTO pregunta_opciones (pregunta_id, orden, valor, etiqueta, pide_detalle, excluyente, genera_alerta) VALUES
  (2008, 10, 'importaciones', 'Importaciones', FALSE, FALSE, FALSE),
  (2008, 20, 'exportaciones', 'Exportaciones', FALSE, FALSE, FALSE),
  (2008, 30, 'inversiones', 'Inversiones', FALSE, FALSE, FALSE),
  (2008, 40, 'prestamos', 'Préstamos', FALSE, FALSE, FALSE),
  (2008, 50, 'giros', 'Giros', FALSE, FALSE, FALSE),
  (2008, 60, 'transferencias', 'Transferencias', FALSE, FALSE, FALSE),
  (2008, 70, 'pago_servicios', 'Pago de servicios', FALSE, FALSE, FALSE),
  (2008, 80, 'otro', 'Otro', TRUE, FALSE, FALSE),
  (2009, 10, 'ninguno', 'Ninguno', FALSE, TRUE, FALSE),
  (2009, 20, 'DZ', 'Argelia', FALSE, FALSE, TRUE),
  (2009, 30, 'AO', 'Angola', FALSE, FALSE, TRUE),
  (2009, 40, 'BO', 'Bolivia', FALSE, FALSE, TRUE),
  (2009, 50, 'BG', 'Bulgaria', FALSE, FALSE, TRUE),
  (2009, 60, 'CM', 'Camerún', FALSE, FALSE, TRUE),
  (2009, 70, 'CI', 'Costa de Marfil', FALSE, FALSE, TRUE),
  (2009, 80, 'KP', 'Corea del Norte', FALSE, FALSE, TRUE),
  (2009, 90, 'HT', 'Haití', FALSE, FALSE, TRUE),
  (2009, 100, 'IR', 'Irán', FALSE, FALSE, TRUE),
  (2009, 110, 'VG', 'Islas Vírgenes Británicas', FALSE, FALSE, TRUE),
  (2009, 120, 'KE', 'Kenia', FALSE, FALSE, TRUE),
  (2009, 130, 'LA', 'Laos', FALSE, FALSE, TRUE),
  (2009, 140, 'LB', 'Líbano', FALSE, FALSE, TRUE),
  (2009, 150, 'MC', 'Mónaco', FALSE, FALSE, TRUE),
  (2009, 160, 'MM', 'Myanmar', FALSE, FALSE, TRUE),
  (2009, 170, 'NA', 'Namibia', FALSE, FALSE, TRUE),
  (2009, 180, 'NP', 'Nepal', FALSE, FALSE, TRUE),
  (2009, 190, 'PG', 'Papúa Nueva Guinea', FALSE, FALSE, TRUE),
  (2009, 200, 'CD', 'República Democrática del Congo', FALSE, FALSE, TRUE),
  (2009, 210, 'SY', 'Siria', FALSE, FALSE, TRUE),
  (2009, 220, 'SS', 'Sudán del Sur', FALSE, FALSE, TRUE),
  (2009, 230, 'VE', 'Venezuela', FALSE, FALSE, TRUE),
  (2009, 240, 'VN', 'Vietnam', FALSE, FALSE, TRUE),
  (2009, 250, 'YE', 'Yemen', FALSE, FALSE, TRUE),
  (2018, 10, 'salario', 'Salario', FALSE, FALSE, FALSE),
  (2018, 20, 'honorarios', 'Honorarios o actividades independientes', FALSE, FALSE, FALSE),
  (2018, 30, 'pension', 'Pensión', FALSE, FALSE, FALSE),
  (2018, 40, 'inversiones', 'Inversiones', FALSE, FALSE, FALSE),
  (2018, 50, 'rentas', 'Rentas o arrendamientos', FALSE, FALSE, FALSE),
  (2018, 60, 'herencia', 'Herencia o donación', FALSE, FALSE, FALSE),
  (2018, 70, 'otro', 'Otro', TRUE, FALSE, FALSE);
INSERT INTO modulo_secciones (modulo_id, orden, componente, titulo, instrucciones, obligatoria, minimo_filas, depende_de_pregunta_id, depende_de_valor) VALUES
  (201, 1, 'datos_generales', 'Datos personales', NULL, TRUE, 0, NULL, NULL),
  (202, 1, 'familiares_pep', 'Sus familiares', 'Relacione a su cónyuge o compañero permanente y a sus familiares hasta segundo grado de consanguinidad, segundo de afinidad y primero civil.', TRUE, 1, 2005, 'si'),
  (205, 1, 'financiero', 'Información financiera', NULL, TRUE, 0, NULL, NULL),
  (207, 1, 'parientes_directivos', 'Parientes en la entidad', NULL, TRUE, 1, 2020, 'si'),
  (208, 1, 'soportes', 'Documentos soporte', NULL, TRUE, 0, NULL, NULL),
  (208, 2, 'firma', 'Firma y envío', NULL, TRUE, 0, NULL, NULL);

-- Las preguntas de la version 1 tienen ids fijos; los siguientes empiezan despues de ellos.
ALTER TABLE preguntas AUTO_INCREMENT = 10001;
ALTER TABLE modulos AUTO_INCREMENT = 1001;
ALTER TABLE cuestionarios AUTO_INCREMENT = 101;
