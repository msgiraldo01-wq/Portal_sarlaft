-- =====================================================================
-- PORTAL SARLAFT - 03_datos_prueba.sql
-- DATOS FICTICIOS para desarrollo y pruebas. NO cargar en produccion.
-- Ejecutar despues de 02_catalogos.sql:
--   mysql -u root -p portal_sarlaft < bd/03_datos_prueba.sql
--
-- Son los mismos terceros que muestra la pantalla de inicio de la demo.
-- Los nombres, documentos y cifras son inventados; cualquier parecido
-- con una empresa o persona real es coincidencia.
--
-- Todos los usuarios internos tienen la contrasena  Demo2026*
-- =====================================================================

USE portal_sarlaft;
SET NAMES utf8mb4;
SET @usuario_id = NULL;

-- MySQL Workbench trae activo el "modo de actualizacion segura", que bloquea
-- los UPDATE y DELETE masivos de este script (Error Code: 1175). Se apaga
-- solo mientras corre el script y al final se deja como estaba.
SET @modo_seguro_anterior = @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;

-- Equipo interno
INSERT INTO usuarios (id, usuario, nombre, correo, clave_hash, rol, ultimo_ingreso_en) VALUES
  (1, 'admin.sistemas', 'Administrador del sistema', 'sistemas@entidad.test', '$2b$12$gPK3QOh5G7YnFRZJunSRKuZXtB//RKuOePWUz0loiWwHUOgtBMIHO', 'administrador', '2026-11-05 08:02:00'),
  (2, 'laura.restrepo', 'Laura Restrepo', 'laura.restrepo@entidad.test', '$2b$12$gPK3QOh5G7YnFRZJunSRKuZXtB//RKuOePWUz0loiWwHUOgtBMIHO', 'oficial_cumplimiento', '2026-11-06 07:30:00'),
  (3, 'carlos.mejia', 'Carlos Mejía', 'carlos.mejia@entidad.test', '$2b$12$gPK3QOh5G7YnFRZJunSRKuZXtB//RKuOePWUz0loiWwHUOgtBMIHO', 'analista', '2026-11-06 07:45:00'),
  (4, 'auditoria.interna', 'Auditoría interna', 'auditoria@entidad.test', '$2b$12$gPK3QOh5G7YnFRZJunSRKuZXtB//RKuOePWUz0loiWwHUOgtBMIHO', 'auditor', NULL);
UPDATE parametros SET actualizado_por = 2 WHERE clave = 'periodicidad_actualizacion_meses';
UPDATE cuestionarios SET creado_por = 2;

-- Terceros (ficticios)
INSERT INTO terceros (id, tipo_persona, tipo_documento, numero_documento, digito_verificacion, razon_social, nombres, apellidos, contacto_nombre, correo, celular, autorizacion_datos_en, autorizacion_datos_ip, estado, creado_en) VALUES
  (1, 'juridica', 'NIT', '901482337', 2, 'Distribuciones Andinas del Café S.A.S.', NULL, NULL, 'Paula Andrea Gómez', 'compras@distribucionesandinas.test', '3104567321', '2024-03-11 09:20:00', '181.49.120.11', 'activo', '2024-03-11 09:20:00'),
  (2, 'juridica', 'NIT', '900771204', 8, 'Clínica Odontológica Los Alpes S.A.S.', NULL, NULL, 'Ricardo Londoño', 'administracion@losalpes.test', '3117780045', '2026-10-25 17:55:00', '181.49.120.12', 'activo', '2026-10-25 17:55:00'),
  (3, 'natural', 'CC', '1088254961', NULL, NULL, 'María Fernanda', 'Ospina Gil', NULL, 'mafe.ospina@correo.test', '3159876543', '2025-02-03 08:10:00', '181.49.120.13', 'activo', '2025-02-03 08:10:00'),
  (4, 'juridica', 'NIT', '816004512', 8, 'Transportes del Otún S.A.S.', NULL, NULL, 'Gustavo Arango', 'gerencia@transotun.test', '3006541122', '2025-06-17 10:00:00', '181.49.120.14', 'activo', '2025-06-17 10:00:00'),
  (5, 'juridica', 'NIT', '900318840', 1, 'Comercializadora Quimbaya Ltda.', NULL, NULL, 'Diana Marcela Ríos', 'contabilidad@quimbaya.test', '3128890011', '2023-08-29 14:12:00', '181.49.120.15', 'activo', '2023-08-29 14:12:00'),
  (6, 'natural', 'CC', '10245873', NULL, NULL, 'Jorge Iván', 'Salazar Henao', NULL, 'jorgeivan.salazar@correo.test', '3145551234', '2022-04-01 11:00:00', '181.49.120.16', 'activo', '2022-04-01 11:00:00'),
  (7, 'juridica', 'NIT', '901655012', 8, 'Laboratorio Bioanálisis del Eje S.A.S.', NULL, NULL, 'Natalia Quintero', 'calidad@bioanalisiseje.test', '3208874411', '2024-09-12 16:30:00', '181.49.120.17', 'activo', '2024-09-12 16:30:00'),
  (8, 'juridica', 'NIT', '800936271', 9, 'Inversiones La Badea S.A.', NULL, NULL, 'Felipe Arias', 'tesoreria@labadea.test', '3016667788', '2026-10-23 10:05:00', '181.49.120.18', 'activo', '2026-10-23 10:05:00'),
  (9, 'natural', 'CC', '1087998112', NULL, NULL, 'Andrés Felipe', 'Cardona Ríos', NULL, 'andres.cardona@correo.test', '3162223344', '2026-09-01 08:00:00', '181.49.120.19', 'activo', '2026-09-01 08:00:00'),
  (10, 'juridica', 'NIT', '901220478', 9, 'Suministros Hospitalarios Consota S.A.S.', NULL, NULL, 'Luisa Fernanda Tabares', 'ventas@consota.test', '3174448899', '2025-01-20 09:45:00', '181.49.120.20', 'activo', '2025-01-20 09:45:00'),
  (11, 'juridica', 'NIT', '901733905', 4, 'Servicios Médicos Integrales del Risaralda S.A.S.', NULL, NULL, 'Óscar Valencia', 'juridica@smir.test', '3189990022', '2026-10-02 15:40:00', '181.49.120.21', 'activo', '2026-10-02 15:40:00');
INSERT INTO tercero_relaciones (tercero_id, relacion, desde) VALUES
  (1, 'proveedor', '2024-03-11'),
  (2, 'proveedor', '2026-10-25'),
  (3, 'empleado', '2025-02-03'),
  (4, 'proveedor', '2025-06-17'),
  (5, 'cliente', '2023-08-29'),
  (6, 'accionista', '2022-04-01'),
  (7, 'proveedor', '2024-09-12'),
  (8, 'cliente', '2026-10-23'),
  (9, 'empleado', '2026-09-01'),
  (10, 'proveedor', '2025-01-20'),
  (10, 'cliente', '2025-01-20'),
  (11, 'proveedor', '2026-10-02');

-- Codigos de firma usados (el codigo real nunca se guarda; aqui son huellas de ejemplo)
INSERT INTO codigos_verificacion (id, tercero_id, proposito, codigo_hash, canales, creado_en, vence_en, intentos, usado_en, ip) VALUES
  (1, 1, 'firma', '6b01c344dbe5827bec3e711f9debb1e0cf4bf98478461b140c813fb873f88591', 'correo,sms', '2026-10-26 07:10:00', '2026-10-26 07:20:00', 0, '2026-10-26 07:12:00', '181.49.120.11'),
  (3, 3, 'firma', '85961c6be2cfc730781518508f58b9cdcf0d9e177de0fb2910a31c3c73e4d0ef', 'correo,sms', '2026-10-25 09:08:00', '2026-10-25 09:18:00', 0, '2026-10-25 09:10:00', '181.49.120.13'),
  (4, 4, 'firma', '9c10e84ca14bf15c2d6765040f20719d1615aa685557e63dea4b766825ecd0ef', 'correo,sms', '2026-10-14 15:18:00', '2026-10-14 15:28:00', 0, '2026-10-14 15:20:00', '181.49.120.14'),
  (5, 5, 'firma', '0a5d8bcc49c89b9d638b3dd0e026fdafefa07cab7605a0d9ed366912c816bfa4', 'correo,sms', '2026-10-21 11:38:00', '2026-10-21 11:48:00', 0, '2026-10-21 11:40:00', '181.49.120.15'),
  (6, 6, 'firma', 'a386c9fec40607079cf40c0275b2672133df71a4ff6a5bf0da0862b0fa883ef2', 'correo,sms', '2026-10-24 09:29:00', '2026-10-24 09:39:00', 0, '2026-10-24 09:31:00', '181.49.120.16'),
  (7, 7, 'firma', 'bc560a5eacc6a061a51a2d00a6b55dd0afbad4f6cb222e2af69608a0067b7c6c', 'correo,sms', '2025-10-08 10:10:00', '2025-10-08 10:20:00', 0, '2025-10-08 10:12:00', '181.49.120.17'),
  (9, 9, 'firma', '6ded1a3096bf8995fa62a140b63b2c7a2c5b5c6ac762398a49c29fc8c08c4fc7', 'correo,sms', '2026-09-03 11:58:00', '2026-09-03 12:08:00', 0, '2026-09-03 12:00:00', '181.49.120.19'),
  (10, 10, 'firma', '91f25fe8324d47c944e4d0e4489d5526acd9cb79801af7352af62f8e26236bb9', 'correo,sms', '2026-10-22 08:18:00', '2026-10-22 08:28:00', 0, '2026-10-22 08:20:00', '181.49.120.20'),
  (11, 11, 'firma', 'ac224ec4661cb46d675d51acbaca7dc79dc6ac1cbcfac10ffb75b3711d236516', 'correo,sms', '2026-10-28 10:28:00', '2026-10-28 10:38:00', 0, '2026-10-28 10:30:00', '181.49.120.21');

-- Formularios. El disparador registra el historial; abajo se reemplaza por uno con fechas reales.
INSERT INTO formularios (id, tercero_id, cuestionario_id, tipo, periodo, estado, radicado, creado_en, enviado_en, firma_codigo_id, firma_ip, revisado_por, revisado_en, observacion_revision, vence_en, nivel_riesgo) VALUES
  (1, 1, 1, 'actualizacion', 2026, 'en_revision', 'SRL-2026-01482', '2026-10-20 08:00:00', '2026-10-26 07:12:00', 1, '181.49.120.11', NULL, NULL, NULL, NULL, 'bajo'),
  (2, 2, 1, 'vinculacion', 2026, 'borrador', NULL, '2026-10-25 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'sin_calificar'),
  (3, 3, 2, 'actualizacion', 2026, 'aprobado', 'SRL-2026-01479', '2026-10-24 19:30:00', '2026-10-25 09:10:00', 3, '181.49.120.13', 2, '2026-10-25 16:05:00', 'Información completa y soportes vigentes.', '2027-10-25', 'bajo'),
  (4, 4, 1, 'actualizacion', 2026, 'rechazado', 'SRL-2026-01477', '2026-10-10 10:00:00', '2026-10-14 15:20:00', 4, '181.49.120.14', 2, '2026-10-25 11:27:00', 'El certificado de existencia y representación legal tiene más de 30 días y los estados financieros no están firmados por el contador. Se pidió corregir el 17/10/2026 y no se recibió respuesta.', NULL, 'medio'),
  (5, 5, 1, 'actualizacion', 2026, 'aprobado', 'SRL-2026-01474', '2026-10-18 09:00:00', '2026-10-21 11:40:00', 5, '181.49.120.15', 3, '2026-10-24 15:58:00', 'Aprobado. Sin señales de alerta.', '2027-10-24', 'bajo'),
  (6, 6, 2, 'actualizacion', 2026, 'en_revision', 'SRL-2026-01471', '2026-10-22 20:10:00', '2026-10-24 09:31:00', 6, '181.49.120.16', NULL, NULL, NULL, NULL, 'medio'),
  (7, 7, 1, 'actualizacion', 2025, 'aprobado', 'SRL-2025-00873', '2025-10-01 08:30:00', '2025-10-08 10:12:00', 7, '181.49.120.17', 2, '2025-10-15 17:02:00', 'Aprobado.', '2026-10-15', 'bajo'),
  (8, 8, 1, 'vinculacion', 2026, 'borrador', NULL, '2026-10-23 10:14:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'sin_calificar'),
  (9, 9, 2, 'vinculacion', 2026, 'aprobado', 'SRL-2026-01459', '2026-09-01 08:30:00', '2026-09-03 12:00:00', 9, '181.49.120.19', 3, '2026-10-22 14:47:00', 'Aprobado.', '2027-10-22', 'bajo'),
  (10, 10, 1, 'actualizacion', 2026, 'en_revision', 'SRL-2026-01455', '2026-10-15 07:50:00', '2026-10-22 08:20:00', 10, '181.49.120.20', NULL, NULL, NULL, NULL, 'medio'),
  (11, 11, 1, 'vinculacion', 2026, 'devuelto', 'SRL-2026-01490', '2026-10-02 16:00:00', '2026-10-28 10:30:00', 11, '181.49.120.21', 3, '2026-10-30 09:15:00', 'Falta la certificación bancaria y el porcentaje de participación del beneficiario final.', NULL, 'sin_calificar');
UPDATE formularios SET actualizado_en = '2026-10-26 07:12:00' WHERE id = 1;
UPDATE formularios SET actualizado_en = '2026-10-25 18:40:00' WHERE id = 2;
UPDATE formularios SET actualizado_en = '2026-10-25 16:05:00' WHERE id = 3;
UPDATE formularios SET actualizado_en = '2026-10-25 11:27:00' WHERE id = 4;
UPDATE formularios SET actualizado_en = '2026-10-24 15:58:00' WHERE id = 5;
UPDATE formularios SET actualizado_en = '2026-10-24 09:31:00' WHERE id = 6;
UPDATE formularios SET actualizado_en = '2025-10-15 17:02:00' WHERE id = 7;
UPDATE formularios SET actualizado_en = '2026-10-23 10:14:00' WHERE id = 8;
UPDATE formularios SET actualizado_en = '2026-10-22 14:47:00' WHERE id = 9;
UPDATE formularios SET actualizado_en = '2026-10-22 08:20:00' WHERE id = 10;
UPDATE formularios SET actualizado_en = '2026-10-30 09:15:00' WHERE id = 11;
DELETE FROM formulario_estados;
INSERT INTO formulario_estados (formulario_id, estado_anterior, estado_nuevo, usuario_id, observacion, ocurrido_en) VALUES
  (1, NULL, 'borrador', NULL, NULL, '2026-10-20 08:00:00'),
  (1, 'borrador', 'en_revision', NULL, NULL, '2026-10-26 07:12:00'),
  (2, NULL, 'borrador', NULL, NULL, '2026-10-25 18:00:00'),
  (3, NULL, 'borrador', NULL, NULL, '2026-10-24 19:30:00'),
  (3, 'borrador', 'en_revision', NULL, NULL, '2026-10-25 09:10:00'),
  (3, 'en_revision', 'aprobado', 2, 'Información completa y soportes vigentes.', '2026-10-25 16:05:00'),
  (4, NULL, 'borrador', NULL, NULL, '2026-10-10 10:00:00'),
  (4, 'borrador', 'en_revision', NULL, NULL, '2026-10-14 15:20:00'),
  (4, 'en_revision', 'devuelto', 2, 'Actualice el certificado de existencia y los estados financieros firmados.', '2026-10-17 10:00:00'),
  (4, 'devuelto', 'en_revision', NULL, NULL, '2026-10-20 08:15:00'),
  (4, 'en_revision', 'rechazado', 2, 'El certificado de existencia y representación legal tiene más de 30 días y los estados financieros no están firmados por el contador. Se pidió corregir el 17/10/2026 y no se recibió respuesta.', '2026-10-25 11:27:00'),
  (5, NULL, 'borrador', NULL, NULL, '2026-10-18 09:00:00'),
  (5, 'borrador', 'en_revision', NULL, NULL, '2026-10-21 11:40:00'),
  (5, 'en_revision', 'aprobado', 3, 'Aprobado. Sin señales de alerta.', '2026-10-24 15:58:00'),
  (6, NULL, 'borrador', NULL, NULL, '2026-10-22 20:10:00'),
  (6, 'borrador', 'en_revision', NULL, NULL, '2026-10-24 09:31:00'),
  (7, NULL, 'borrador', NULL, NULL, '2025-10-01 08:30:00'),
  (7, 'borrador', 'en_revision', NULL, NULL, '2025-10-08 10:12:00'),
  (7, 'en_revision', 'aprobado', 2, 'Aprobado.', '2025-10-15 17:02:00'),
  (8, NULL, 'borrador', NULL, NULL, '2026-10-23 10:14:00'),
  (9, NULL, 'borrador', NULL, NULL, '2026-09-01 08:30:00'),
  (9, 'borrador', 'en_revision', NULL, NULL, '2026-09-03 12:00:00'),
  (9, 'en_revision', 'aprobado', 3, 'Aprobado.', '2026-10-22 14:47:00'),
  (10, NULL, 'borrador', NULL, NULL, '2026-10-15 07:50:00'),
  (10, 'borrador', 'en_revision', NULL, NULL, '2026-10-22 08:20:00'),
  (11, NULL, 'borrador', NULL, NULL, '2026-10-02 16:00:00'),
  (11, 'borrador', 'en_revision', NULL, NULL, '2026-10-28 10:30:00'),
  (11, 'en_revision', 'devuelto', 3, 'Falta la certificación bancaria y el porcentaje de participación del beneficiario final.', '2026-10-30 09:15:00');

-- Avance por paso: los enviados tienen todo completo; los borradores van a medias
INSERT INTO formulario_modulos (formulario_id, modulo_id, estado)
SELECT f.id, m.id, 'completo'
  FROM formularios f JOIN modulos m ON m.cuestionario_id = f.cuestionario_id
 WHERE f.estado <> 'borrador';
INSERT INTO formulario_modulos (formulario_id, modulo_id, estado) VALUES
  (2, 101, 'completo'), (2, 102, 'completo'), (2, 103, 'completo'), (2, 104, 'con_error'),
  (8, 101, 'completo'), (8, 102, 'completo');
UPDATE formulario_modulos SET estado = 'con_error' WHERE formulario_id = 11 AND modulo_id IN (109, 111);

-- Datos generales
INSERT INTO formulario_datos_generales (formulario_id, forma_juridica, naturaleza, fecha_nacimiento, municipio_nacimiento, pais_nacimiento, nacionalidad, ocupacion, empresa_donde_trabaja, cargo, actividad_ciiu, pais, municipio, direccion, telefono) VALUES
  (1, 'sas', 'privada', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '4645', 'CO', '66001', 'Carrera 7 # 18-45, oficina 302', '6063351200'),
  (2, 'sas', 'privada', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '8622', 'CO', '66001', 'Avenida Circunvalar # 9-12', '6063254411'),
  (4, 'sas', 'privada', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '4923', 'CO', '66170', 'Calle 14 # 11-30, bodega 4', '6063328870'),
  (5, 'ltda', 'privada', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '4645', 'CO', '63001', 'Carrera 14 # 21-07', '6067412233'),
  (7, 'sas', 'privada', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '8691', 'CO', '66001', 'Calle 19 # 9-50, piso 2', '6063346677'),
  (8, 'sa', 'privada', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '6420', 'CO', '66001', 'Carrera 13 # 15-20, oficina 801', '6063400200'),
  (10, 'sas', 'privada', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '4645', 'CO', '66001', 'Avenida 30 de Agosto # 40-11', '6063202020'),
  (11, 'sas', 'privada', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '8621', 'CO', '66682', 'Calle 12 # 15-22', '6063641188'),
  (3, NULL, NULL, '1994-05-12', '66001', 'CO', 'CO', 'Profesional de facturación', 'La entidad', 'Profesional', '0010', 'CO', '66001', 'Calle 72 # 23-18, Cuba', '3159876543'),
  (6, NULL, NULL, '1968-11-02', '66682', 'CO', 'CO', 'Empresario', 'Inversiones Salazar Henao S.A.S.', 'Gerente', '0090', 'CO', '66001', 'Carrera 15 # 5-40, Pinares', '3145551234'),
  (9, NULL, NULL, '1998-02-27', '17001', 'CO', 'CO', 'Técnico de sistemas', 'La entidad', 'Técnico', '0010', 'CO', '66170', 'Manzana 4 casa 12, La Pradera', '3162223344');

-- Informacion financiera (patrimonio = activos - pasivos)
INSERT INTO formulario_financiero (formulario_id, fecha_corte, activos, pasivos, patrimonio, ingresos_anuales, otros_ingresos, concepto_otros_ingresos, egresos_anuales) VALUES
  (1, '2025-12-31', 4850000000, 1920000000, 2930000000, 7300000000, 0, NULL, 6810000000),
  (3, '2025-12-31', 185000000, 62000000, 123000000, 58800000, 0, NULL, 41000000),
  (4, '2025-12-31', 2140000000, 1480000000, 660000000, 3900000000, 120000000, 'Arrendamiento de bodega', 3720000000),
  (5, '2025-12-31', 9620000000, 4100000000, 5520000000, 15400000000, 0, NULL, 14650000000),
  (6, '2025-12-31', 3400000000, 350000000, 3050000000, 610000000, 240000000, 'Dividendos', 280000000),
  (7, '2024-12-31', 1760000000, 690000000, 1070000000, 2950000000, 0, NULL, 2700000000),
  (9, '2025-12-31', 42000000, 18000000, 24000000, 31200000, 0, NULL, 27000000),
  (10, '2025-12-31', 6380000000, 3010000000, 3370000000, 11200000000, 85000000, 'Rendimientos financieros', 10600000000),
  (11, '2025-12-31', 2900000000, 1100000000, 1800000000, 5400000000, 0, NULL, 5050000000);

-- Personas vinculadas
INSERT INTO personas_vinculadas (id, formulario_id, rol, orden, tipo_persona, nombre_completo, tipo_documento, numero_documento, correo, celular, cargo, participacion, es_pep, parentesco_id, fecha_nacimiento, municipio_nacimiento, municipio_residencia, direccion, telefono, ocupacion) VALUES
  (1, 1, 'firmante', 1, 'natural', 'Paula Andrea Gómez Restrepo', 'CC', '42125588', 'compras@distribucionesandinas.test', '3104567321', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (2, 1, 'representante_principal', 1, 'natural', 'Paula Andrea Gómez Restrepo', 'CC', '42125588', NULL, NULL, NULL, NULL, NULL, NULL, '1979-03-14', '66001', '66001', 'Calle 4 # 17-30, Álamos', '3104567321', 'Administradora de empresas'),
  (3, 1, 'representante_suplente', 1, 'natural', 'Juan Camilo Gómez Restrepo', 'CC', '10138877', NULL, NULL, NULL, NULL, NULL, NULL, '1982-07-21', '66001', '66170', 'Carrera 16 # 32-08', '3112347788', 'Ingeniero industrial'),
  (4, 1, 'accionista', 1, 'natural', 'Paula Andrea Gómez Restrepo', 'CC', '42125588', NULL, NULL, NULL, 60, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (5, 1, 'accionista', 2, 'natural', 'Juan Camilo Gómez Restrepo', 'CC', '10138877', NULL, NULL, NULL, 40, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (6, 1, 'beneficiario_final', 1, 'natural', 'Paula Andrea Gómez Restrepo', 'CC', '42125588', NULL, NULL, NULL, 60, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (7, 1, 'beneficiario_final', 2, 'natural', 'Juan Camilo Gómez Restrepo', 'CC', '10138877', NULL, NULL, NULL, 40, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (8, 2, 'firmante', 1, 'natural', 'Ricardo Londoño Ceballos', 'CC', '9865412', 'administracion@losalpes.test', '3117780045', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (9, 2, 'representante_principal', 1, 'natural', 'Ricardo Londoño Ceballos', 'CC', '9865412', NULL, NULL, NULL, NULL, NULL, NULL, '1975-09-30', '66001', '66001', 'Avenida Sur # 22-14', '3117780045', 'Odontólogo'),
  (10, 4, 'firmante', 1, 'natural', 'Gustavo Arango Marín', 'CC', '10096321', 'gerencia@transotun.test', '3006541122', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (11, 4, 'representante_principal', 1, 'natural', 'Gustavo Arango Marín', 'CC', '10096321', NULL, NULL, NULL, NULL, NULL, NULL, '1970-01-18', '66170', '66170', 'Calle 50 # 14-02', '3006541122', 'Gerente'),
  (12, 4, 'accionista', 1, 'natural', 'Gustavo Arango Marín', 'CC', '10096321', NULL, NULL, NULL, 100, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (13, 4, 'beneficiario_final', 1, 'natural', 'Gustavo Arango Marín', 'CC', '10096321', NULL, NULL, NULL, 100, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (14, 5, 'firmante', 1, 'natural', 'Diana Marcela Ríos Patiño', 'CC', '41936655', 'contabilidad@quimbaya.test', '3128890011', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (15, 5, 'representante_principal', 1, 'natural', 'Hernán Darío Patiño Ochoa', 'CC', '7543210', NULL, NULL, NULL, NULL, NULL, NULL, '1965-06-05', '63001', '63001', 'Carrera 19 # 8N-30', '3128890000', 'Comerciante'),
  (16, 5, 'accionista', 1, 'natural', 'Hernán Darío Patiño Ochoa', 'CC', '7543210', NULL, NULL, NULL, 70, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (17, 5, 'accionista', 2, 'natural', 'Gloria Inés Ríos de Patiño', 'CC', '41890123', NULL, NULL, NULL, 30, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (18, 5, 'junta_directiva', 1, 'natural', 'Hernán Darío Patiño Ochoa', 'CC', '7543210', NULL, NULL, 'Presidente', NULL, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (19, 5, 'junta_directiva', 2, 'natural', 'Gloria Inés Ríos de Patiño', 'CC', '41890123', NULL, NULL, 'Miembro principal', NULL, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (20, 5, 'beneficiario_final', 1, 'natural', 'Hernán Darío Patiño Ochoa', 'CC', '7543210', NULL, NULL, NULL, 70, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (21, 6, 'familiar_pep', 1, 'natural', 'Martha Lucía Henao de Salazar', 'CC', '24945120', NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL),
  (22, 6, 'familiar_pep', 2, 'natural', 'Santiago Salazar Henao', 'CC', '1088301456', NULL, NULL, NULL, NULL, NULL, 4, NULL, NULL, NULL, NULL, NULL, NULL),
  (23, 7, 'firmante', 1, 'natural', 'Natalia Quintero Duque', 'CC', '1088012345', 'calidad@bioanalisiseje.test', '3208874411', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (24, 7, 'representante_principal', 1, 'natural', 'Natalia Quintero Duque', 'CC', '1088012345', NULL, NULL, NULL, NULL, NULL, NULL, '1988-12-01', '66001', '66001', 'Carrera 8 # 23-15', '3208874411', 'Bacterióloga'),
  (25, 7, 'accionista', 1, 'natural', 'Natalia Quintero Duque', 'CC', '1088012345', NULL, NULL, NULL, 100, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (26, 7, 'beneficiario_final', 1, 'natural', 'Natalia Quintero Duque', 'CC', '1088012345', NULL, NULL, NULL, 100, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (27, 8, 'firmante', 1, 'natural', 'Felipe Arias Botero', 'CC', '1087654321', 'tesoreria@labadea.test', '3016667788', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (28, 10, 'firmante', 1, 'natural', 'Luisa Fernanda Tabares Mejía', 'CC', '42098765', 'ventas@consota.test', '3174448899', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (29, 10, 'representante_principal', 1, 'natural', 'Luisa Fernanda Tabares Mejía', 'CC', '42098765', NULL, NULL, NULL, NULL, NULL, NULL, '1981-04-22', '66001', '66001', 'Calle 21 # 6-40', '3174448899', 'Química farmacéutica'),
  (30, 10, 'accionista', 1, 'natural', 'Luisa Fernanda Tabares Mejía', 'CC', '42098765', NULL, NULL, NULL, 55, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (31, 10, 'accionista', 2, 'natural', 'José Antonio Rendón Rendón', 'CC', '16210987', NULL, NULL, NULL, 45, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (32, 10, 'beneficiario_final', 1, 'natural', 'Luisa Fernanda Tabares Mejía', 'CC', '42098765', NULL, NULL, NULL, 55, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (33, 10, 'beneficiario_final', 2, 'natural', 'José Antonio Rendón Rendón', 'CC', '16210987', NULL, NULL, NULL, 45, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (34, 10, 'grupo_empresarial', 1, 'juridica', 'Grupo Consota S.A.S.', 'NIT', '901220470', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (35, 11, 'firmante', 1, 'natural', 'Óscar Valencia Cardona', 'CC', '18512345', 'juridica@smir.test', '3189990022', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (36, 11, 'representante_principal', 1, 'natural', 'Óscar Valencia Cardona', 'CC', '18512345', NULL, NULL, NULL, NULL, NULL, NULL, '1977-10-09', '66682', '66682', 'Carrera 14 # 10-05', '3189990022', 'Médico'),
  (37, 11, 'accionista', 1, 'natural', 'Óscar Valencia Cardona', 'CC', '18512345', NULL, NULL, NULL, 100, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  (38, 11, 'beneficiario_final', 1, 'natural', 'Óscar Valencia Cardona', 'CC', '18512345', NULL, NULL, NULL, NULL, FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- Respuestas de base: en los formularios enviados, todas las si/no en "no", todas las
-- aceptaciones marcadas y origen de fondos con la opcion principal. Luego se ajustan
-- las que son distintas. Las preguntas que dependen de otra quedan sin responder.
INSERT INTO respuestas (formulario_id, pregunta_id, valor_booleano)
SELECT f.id, p.id, IF(p.tipo = 'aceptacion', TRUE, FALSE)
  FROM formularios f
  JOIN modulos m   ON m.cuestionario_id = f.cuestionario_id
  JOIN preguntas p ON p.modulo_id = m.id
 WHERE f.estado <> 'borrador'
   AND p.tipo IN ('si_no','aceptacion')
   AND p.depende_de_pregunta_id IS NULL;

INSERT INTO respuestas (formulario_id, pregunta_id)
SELECT f.id, p.id
  FROM formularios f
  JOIN modulos m   ON m.cuestionario_id = f.cuestionario_id
  JOIN preguntas p ON p.modulo_id = m.id AND p.codigo = 'origen_fondos'
 WHERE f.estado <> 'borrador';

INSERT INTO respuesta_opciones (respuesta_id, opcion_id)
SELECT r.id, o.id
  FROM respuestas r
  JOIN preguntas p         ON p.id = r.pregunta_id AND p.codigo = 'origen_fondos'
  JOIN pregunta_opciones o ON o.pregunta_id = p.id AND o.valor IN ('objeto_social','salario');

-- Productos o servicios: solo se pregunta a proveedores juridicos
INSERT INTO respuestas (formulario_id, pregunta_id)
SELECT f.id, p.id
  FROM formularios f
  JOIN tercero_relaciones tr ON tr.tercero_id = f.tercero_id AND tr.relacion = 'proveedor'
  JOIN modulos m   ON m.cuestionario_id = f.cuestionario_id
  JOIN preguntas p ON p.modulo_id = m.id AND p.codigo = 'productos_servicios'
 WHERE f.estado <> 'borrador';

INSERT INTO respuesta_opciones (respuesta_id, opcion_id, detalle)
SELECT r.id, o.id, IF(o.valor = 'otro', 'Transporte de carga refrigerada', NULL)
  FROM respuestas r
  JOIN formularios f       ON f.id = r.formulario_id
  JOIN preguntas p         ON p.id = r.pregunta_id AND p.codigo = 'productos_servicios'
  JOIN pregunta_opciones o ON o.pregunta_id = p.id
 WHERE (f.id IN (1, 10) AND o.valor = 'suministros_medicos')
    OR (f.id = 7  AND o.valor = 'servicios_salud')
    OR (f.id = 11 AND o.valor = 'servicios_salud')
    OR (f.id = 4  AND o.valor = 'otro');

-- Jorge Ivan Salazar (formulario 6) es PEP: concejal hasta 2023
UPDATE respuestas r JOIN preguntas p ON p.id = r.pregunta_id
   SET r.valor_booleano = TRUE
 WHERE r.formulario_id = 6 AND p.codigo IN ('pep_servidor_publico','pep_poder_publico','pep_decreto_830');

-- Consota (formulario 10) importa insumos
UPDATE respuestas r JOIN preguntas p ON p.id = r.pregunta_id
   SET r.valor_booleano = TRUE
 WHERE r.formulario_id = 10 AND p.codigo = 'opint_realiza';
INSERT INTO respuestas (formulario_id, pregunta_id)
SELECT 10, p.id FROM preguntas p JOIN modulos m ON m.id = p.modulo_id
 WHERE m.cuestionario_id = 1 AND p.codigo IN ('opint_tipos','opint_paises');
INSERT INTO respuesta_opciones (respuesta_id, opcion_id)
SELECT r.id, o.id
  FROM respuestas r
  JOIN preguntas p         ON p.id = r.pregunta_id
  JOIN pregunta_opciones o ON o.pregunta_id = p.id
 WHERE r.formulario_id = 10
   AND ((p.codigo = 'opint_tipos'  AND o.valor IN ('importaciones','transferencias'))
     OR (p.codigo = 'opint_paises' AND o.valor = 'ninguno'));

-- Consota pertenece a un grupo empresarial
UPDATE respuestas r JOIN preguntas p ON p.id = r.pregunta_id
   SET r.valor_booleano = TRUE
 WHERE r.formulario_id = 10 AND p.codigo = 'grupo_pertenece';

-- Clinica Los Alpes (borrador): alcanzo a responder parte del paso PEP
INSERT INTO respuestas (formulario_id, pregunta_id, valor_booleano)
SELECT 2, p.id, FALSE FROM preguntas p
 WHERE p.modulo_id = 104 AND p.codigo IN ('pep_recursos_publicos','pep_reconocimiento');

-- Soportes (solo la referencia; los PDF no existen en estos datos de prueba)
INSERT INTO soportes (formulario_id, tipo_soporte_id, nombre_original, ruta_archivo, tipo_mime, tamano_bytes,
  sha256, fecha_expedicion, estado, observacion, cargado_en, revisado_por, revisado_en)
SELECT v.* FROM (
SELECT 1 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'RUT') AS t, 'rut.pdf' AS n, 'soportes/2026/1/rut.pdf' AS r, 'application/pdf' AS m, 217000 AS b, '06b05081802129fefe7ead43c6bbaceb0dc455711d73989dbb9fe66dc68317d8' AS h, '2026-10-16' AS e, 'cargado' AS s, NULL AS o, '2026-10-26 06:42:00' AS c, NULL AS rp, NULL AS re
  UNION ALL SELECT 1 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'CAMARA_COMERCIO') AS t, 'camara_comercio.pdf' AS n, 'soportes/2026/1/camara_comercio.pdf' AS r, 'application/pdf' AS m, 254000 AS b, '44e0828201f89d4578274bd915dd4d5de3d09527ba6bf96104f65888b5012a9a' AS h, '2026-10-16' AS e, 'cargado' AS s, NULL AS o, '2026-10-26 06:42:00' AS c, NULL AS rp, NULL AS re
  UNION ALL SELECT 1 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'CEDULA_REPRESENTANTE') AS t, 'cedula_representante.pdf' AS n, 'soportes/2026/1/cedula_representante.pdf' AS r, 'application/pdf' AS m, 291000 AS b, '299bc8de163c023c4ccaba5e660e89cabd97d0ab587204f6a534581dfbcc9f1b' AS h, '2026-10-16' AS e, 'cargado' AS s, NULL AS o, '2026-10-26 06:42:00' AS c, NULL AS rp, NULL AS re
  UNION ALL SELECT 1 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'ESTADOS_FINANCIEROS') AS t, 'estados_financieros.pdf' AS n, 'soportes/2026/1/estados_financieros.pdf' AS r, 'application/pdf' AS m, 328000 AS b, '34244be34db21d80cbf2d9bb1289458dbb3da617733ca6dfe2c6496fa0fa2abf' AS h, '2026-10-16' AS e, 'cargado' AS s, NULL AS o, '2026-10-26 06:42:00' AS c, NULL AS rp, NULL AS re
  UNION ALL SELECT 1 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'CERTIFICACION_BANCARIA') AS t, 'certificacion_bancaria.pdf' AS n, 'soportes/2026/1/certificacion_bancaria.pdf' AS r, 'application/pdf' AS m, 365000 AS b, 'd8d9342dac4d7ceb852b599b6afa2b081ae4d8c739e46aca8c9f94e6faef5e74' AS h, '2026-10-16' AS e, 'cargado' AS s, NULL AS o, '2026-10-26 06:42:00' AS c, NULL AS rp, NULL AS re
  UNION ALL SELECT 3 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'RUT') AS t, 'rut.pdf' AS n, 'soportes/2026/3/rut.pdf' AS r, 'application/pdf' AS m, 217000 AS b, '5a62eb3045df5880caf7b90c9be3aeaa3bafad2e185e9a2d7c75cc808472db3d' AS h, '2026-10-15' AS e, 'aceptado' AS s, NULL AS o, '2026-10-25 08:40:00' AS c, 2 AS rp, '2026-10-25 16:05:00' AS re
  UNION ALL SELECT 3 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'DOCUMENTO_IDENTIDAD') AS t, 'documento_identidad.pdf' AS n, 'soportes/2026/3/documento_identidad.pdf' AS r, 'application/pdf' AS m, 254000 AS b, '197779993938d6f785001a526bea3c3ad4fe8d202a57beddf578940af4a214ad' AS h, '2026-10-15' AS e, 'aceptado' AS s, NULL AS o, '2026-10-25 08:40:00' AS c, 2 AS rp, '2026-10-25 16:05:00' AS re
  UNION ALL SELECT 4 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'RUT') AS t, 'rut.pdf' AS n, 'soportes/2026/4/rut.pdf' AS r, 'application/pdf' AS m, 217000 AS b, 'fe72320d857c16fee37cb172e3f461da486c0e1c87383b460bfa84152ac3fd1a' AS h, '2026-10-04' AS e, 'cargado' AS s, NULL AS o, '2026-10-14 14:50:00' AS c, NULL AS rp, NULL AS re
  UNION ALL SELECT 4 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'CAMARA_COMERCIO') AS t, 'camara_comercio.pdf' AS n, 'soportes/2026/4/camara_comercio.pdf' AS r, 'application/pdf' AS m, 254000 AS b, 'b96fbb039e1bd1a45cd2b5e6ac49f700f43f1f4bd820c8aa1c6d321e9d91275f' AS h, '2026-08-30' AS e, 'rechazado' AS s, 'Expedido hace más de 30 días' AS o, '2026-10-14 14:50:00' AS c, 2 AS rp, '2026-10-25 11:27:00' AS re
  UNION ALL SELECT 4 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'CEDULA_REPRESENTANTE') AS t, 'cedula_representante.pdf' AS n, 'soportes/2026/4/cedula_representante.pdf' AS r, 'application/pdf' AS m, 291000 AS b, '2a997d1d3d4ed1692e0b8bd6da2ca6f39a70c78bf5f3039722a5ccbb3518c6b5' AS h, '2026-10-04' AS e, 'cargado' AS s, NULL AS o, '2026-10-14 14:50:00' AS c, NULL AS rp, NULL AS re
  UNION ALL SELECT 4 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'ESTADOS_FINANCIEROS') AS t, 'estados_financieros.pdf' AS n, 'soportes/2026/4/estados_financieros.pdf' AS r, 'application/pdf' AS m, 328000 AS b, '3df57b538c5acef0c642f45af1da65b8b9756bd08fe164aaf46f2951e2b930ff' AS h, '2026-10-04' AS e, 'rechazado' AS s, 'Sin firma del contador' AS o, '2026-10-14 14:50:00' AS c, 2 AS rp, '2026-10-25 11:27:00' AS re
  UNION ALL SELECT 4 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'CERTIFICACION_BANCARIA') AS t, 'certificacion_bancaria.pdf' AS n, 'soportes/2026/4/certificacion_bancaria.pdf' AS r, 'application/pdf' AS m, 365000 AS b, 'd00aec5b7caf501efeb90f297366b010483d3c128e8f477caefd096a174b1f0a' AS h, '2026-10-04' AS e, 'cargado' AS s, NULL AS o, '2026-10-14 14:50:00' AS c, NULL AS rp, NULL AS re
  UNION ALL SELECT 5 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'RUT') AS t, 'rut.pdf' AS n, 'soportes/2026/5/rut.pdf' AS r, 'application/pdf' AS m, 217000 AS b, '5e70c34114cf0245f7498356eeb33a5406954197cb2002cd04ab0a246705a0aa' AS h, '2026-10-11' AS e, 'aceptado' AS s, NULL AS o, '2026-10-21 11:10:00' AS c, 3 AS rp, '2026-10-24 15:58:00' AS re
  UNION ALL SELECT 5 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'CAMARA_COMERCIO') AS t, 'camara_comercio.pdf' AS n, 'soportes/2026/5/camara_comercio.pdf' AS r, 'application/pdf' AS m, 254000 AS b, '9aa882ea510a2ce3f8bb721cca0d54e0023cac1e81c4c7cdb54d9bbb138e65e9' AS h, '2026-10-11' AS e, 'aceptado' AS s, NULL AS o, '2026-10-21 11:10:00' AS c, 3 AS rp, '2026-10-24 15:58:00' AS re
  UNION ALL SELECT 5 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'CEDULA_REPRESENTANTE') AS t, 'cedula_representante.pdf' AS n, 'soportes/2026/5/cedula_representante.pdf' AS r, 'application/pdf' AS m, 291000 AS b, 'd800ff44a01719a20ba42c275b89f590e82052bf3a4a59218c4a93dc58c5cab0' AS h, '2026-10-11' AS e, 'aceptado' AS s, NULL AS o, '2026-10-21 11:10:00' AS c, 3 AS rp, '2026-10-24 15:58:00' AS re
  UNION ALL SELECT 5 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'ESTADOS_FINANCIEROS') AS t, 'estados_financieros.pdf' AS n, 'soportes/2026/5/estados_financieros.pdf' AS r, 'application/pdf' AS m, 328000 AS b, '7aa2c0f8c1de8376e2484cddabb1e1bdf61bc0419649c2d2dd49451b19d28a5a' AS h, '2026-10-11' AS e, 'aceptado' AS s, NULL AS o, '2026-10-21 11:10:00' AS c, 3 AS rp, '2026-10-24 15:58:00' AS re
  UNION ALL SELECT 5 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'CERTIFICACION_BANCARIA') AS t, 'certificacion_bancaria.pdf' AS n, 'soportes/2026/5/certificacion_bancaria.pdf' AS r, 'application/pdf' AS m, 365000 AS b, '2ebc5ce025bebf96a703daea2b77e03d2368fd50acff8c9c2af6d73dfed37a02' AS h, '2026-10-11' AS e, 'aceptado' AS s, NULL AS o, '2026-10-21 11:10:00' AS c, 3 AS rp, '2026-10-24 15:58:00' AS re
  UNION ALL SELECT 6 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'RUT') AS t, 'rut.pdf' AS n, 'soportes/2026/6/rut.pdf' AS r, 'application/pdf' AS m, 217000 AS b, '79efedb3ecde4592d7837b4114e6a2495a33924c9d12e5e0305bc6fa73cec667' AS h, '2026-10-14' AS e, 'cargado' AS s, NULL AS o, '2026-10-24 09:01:00' AS c, NULL AS rp, NULL AS re
  UNION ALL SELECT 6 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'DOCUMENTO_IDENTIDAD') AS t, 'documento_identidad.pdf' AS n, 'soportes/2026/6/documento_identidad.pdf' AS r, 'application/pdf' AS m, 254000 AS b, 'c848f4ff7aee6c3543fdc12e9fbb228cc5adc9c343233718e860e532c957ba48' AS h, '2026-10-14' AS e, 'cargado' AS s, NULL AS o, '2026-10-24 09:01:00' AS c, NULL AS rp, NULL AS re
  UNION ALL SELECT 7 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'RUT') AS t, 'rut.pdf' AS n, 'soportes/2025/7/rut.pdf' AS r, 'application/pdf' AS m, 217000 AS b, 'c821990df804b64d715368d5188e55fbc9f97fcb6b1157b49dbc389587532e03' AS h, '2025-09-28' AS e, 'aceptado' AS s, NULL AS o, '2025-10-08 09:42:00' AS c, 2 AS rp, '2025-10-15 17:02:00' AS re
  UNION ALL SELECT 7 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'CAMARA_COMERCIO') AS t, 'camara_comercio.pdf' AS n, 'soportes/2025/7/camara_comercio.pdf' AS r, 'application/pdf' AS m, 254000 AS b, 'af0a94b5f70c9e3c5be2197dbf91d265a08d7f99bae96c2ac83a74b436db6f65' AS h, '2025-09-28' AS e, 'aceptado' AS s, NULL AS o, '2025-10-08 09:42:00' AS c, 2 AS rp, '2025-10-15 17:02:00' AS re
  UNION ALL SELECT 7 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'CEDULA_REPRESENTANTE') AS t, 'cedula_representante.pdf' AS n, 'soportes/2025/7/cedula_representante.pdf' AS r, 'application/pdf' AS m, 291000 AS b, '99d820124a3f20817acece2ce6b8209ddd2e17828bd83a185b5be204978c226e' AS h, '2025-09-28' AS e, 'aceptado' AS s, NULL AS o, '2025-10-08 09:42:00' AS c, 2 AS rp, '2025-10-15 17:02:00' AS re
  UNION ALL SELECT 7 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'ESTADOS_FINANCIEROS') AS t, 'estados_financieros.pdf' AS n, 'soportes/2025/7/estados_financieros.pdf' AS r, 'application/pdf' AS m, 328000 AS b, 'afb92191dfa76cad134009d414ba18ad960e52e3243d206a9d69488028a53228' AS h, '2025-09-28' AS e, 'aceptado' AS s, NULL AS o, '2025-10-08 09:42:00' AS c, 2 AS rp, '2025-10-15 17:02:00' AS re
  UNION ALL SELECT 7 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'CERTIFICACION_BANCARIA') AS t, 'certificacion_bancaria.pdf' AS n, 'soportes/2025/7/certificacion_bancaria.pdf' AS r, 'application/pdf' AS m, 365000 AS b, '4fbffde396ee5bf1b3bd7c3bc6239181b8b09ab6dbf2b95574e9fca7a9d19434' AS h, '2025-09-28' AS e, 'aceptado' AS s, NULL AS o, '2025-10-08 09:42:00' AS c, 2 AS rp, '2025-10-15 17:02:00' AS re
  UNION ALL SELECT 9 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'RUT') AS t, 'rut.pdf' AS n, 'soportes/2026/9/rut.pdf' AS r, 'application/pdf' AS m, 217000 AS b, 'c88e7d05a1f985150942ca546644a7c580f395c8c76caf323a2f6f082f3c9afa' AS h, '2026-08-24' AS e, 'aceptado' AS s, NULL AS o, '2026-09-03 11:30:00' AS c, 3 AS rp, '2026-10-22 14:47:00' AS re
  UNION ALL SELECT 9 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'DOCUMENTO_IDENTIDAD') AS t, 'documento_identidad.pdf' AS n, 'soportes/2026/9/documento_identidad.pdf' AS r, 'application/pdf' AS m, 254000 AS b, '5736c5559a34d9fc27b83be4a16c03e9546a3449ecd3cdd2e916b25d1285e696' AS h, '2026-08-24' AS e, 'aceptado' AS s, NULL AS o, '2026-09-03 11:30:00' AS c, 3 AS rp, '2026-10-22 14:47:00' AS re
  UNION ALL SELECT 10 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'RUT') AS t, 'rut.pdf' AS n, 'soportes/2026/10/rut.pdf' AS r, 'application/pdf' AS m, 217000 AS b, '0e51aa54739bea7426b8cef1210d4737859a736553a02ff4d5bcb8a400a84fe5' AS h, '2026-10-12' AS e, 'cargado' AS s, NULL AS o, '2026-10-22 07:50:00' AS c, NULL AS rp, NULL AS re
  UNION ALL SELECT 10 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'CAMARA_COMERCIO') AS t, 'camara_comercio.pdf' AS n, 'soportes/2026/10/camara_comercio.pdf' AS r, 'application/pdf' AS m, 254000 AS b, 'a1a033d6276c17a85eb0b46a23b9ef8aa4d7fde26e8909839037899345302158' AS h, '2026-10-12' AS e, 'cargado' AS s, NULL AS o, '2026-10-22 07:50:00' AS c, NULL AS rp, NULL AS re
  UNION ALL SELECT 10 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'CEDULA_REPRESENTANTE') AS t, 'cedula_representante.pdf' AS n, 'soportes/2026/10/cedula_representante.pdf' AS r, 'application/pdf' AS m, 291000 AS b, '1e5deef9cc729a9042ef35a12177234bf9406db8930bad8a154c61bea184b382' AS h, '2026-10-12' AS e, 'cargado' AS s, NULL AS o, '2026-10-22 07:50:00' AS c, NULL AS rp, NULL AS re
  UNION ALL SELECT 10 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'ESTADOS_FINANCIEROS') AS t, 'estados_financieros.pdf' AS n, 'soportes/2026/10/estados_financieros.pdf' AS r, 'application/pdf' AS m, 328000 AS b, '7323f09564edeb7dd2544f10328d968e7bb92d501857fda17ca39eaf18481c62' AS h, '2026-10-12' AS e, 'cargado' AS s, NULL AS o, '2026-10-22 07:50:00' AS c, NULL AS rp, NULL AS re
  UNION ALL SELECT 10 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'CERTIFICACION_BANCARIA') AS t, 'certificacion_bancaria.pdf' AS n, 'soportes/2026/10/certificacion_bancaria.pdf' AS r, 'application/pdf' AS m, 365000 AS b, '86decbe47ee932a1257d1525608dac35dcee2a43aa8093c57b504a87e6e9e89b' AS h, '2026-10-12' AS e, 'cargado' AS s, NULL AS o, '2026-10-22 07:50:00' AS c, NULL AS rp, NULL AS re
  UNION ALL SELECT 11 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'RUT') AS t, 'rut.pdf' AS n, 'soportes/2026/11/rut.pdf' AS r, 'application/pdf' AS m, 217000 AS b, 'd7b0d10e5f0c2f99e5c27abde5a32c746f038246453e8962d54262e54050f66a' AS h, '2026-10-18' AS e, 'cargado' AS s, NULL AS o, '2026-10-28 10:00:00' AS c, NULL AS rp, NULL AS re
  UNION ALL SELECT 11 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'CAMARA_COMERCIO') AS t, 'camara_comercio.pdf' AS n, 'soportes/2026/11/camara_comercio.pdf' AS r, 'application/pdf' AS m, 254000 AS b, '6bd6d209647e6a850ebfcf0ce89882739509efbeb78e8f8d7cd5079537b0e4af' AS h, '2026-10-18' AS e, 'cargado' AS s, NULL AS o, '2026-10-28 10:00:00' AS c, NULL AS rp, NULL AS re
  UNION ALL SELECT 11 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'CEDULA_REPRESENTANTE') AS t, 'cedula_representante.pdf' AS n, 'soportes/2026/11/cedula_representante.pdf' AS r, 'application/pdf' AS m, 291000 AS b, 'f107b6f527159216a501cccd6e089abf8fb44fed6f25644d72d41d8e5373edb5' AS h, '2026-10-18' AS e, 'cargado' AS s, NULL AS o, '2026-10-28 10:00:00' AS c, NULL AS rp, NULL AS re
  UNION ALL SELECT 11 AS f, (SELECT id FROM tipos_soporte WHERE codigo = 'ESTADOS_FINANCIEROS') AS t, 'estados_financieros.pdf' AS n, 'soportes/2026/11/estados_financieros.pdf' AS r, 'application/pdf' AS m, 328000 AS b, '9f4edac2ad035908e2ec46c68b54b29fb8cea8e513514ac9b113dab721f779e6' AS h, '2026-10-18' AS e, 'cargado' AS s, NULL AS o, '2026-10-28 10:00:00' AS c, NULL AS rp, NULL AS re
) AS v;

-- Consultas en listas: el tercero y su representante en todas las listas activas
INSERT INTO consultas_listas (tercero_id, formulario_id, persona_vinculada_id, lista_id, nombre_consultado,
                              documento_consultado, resultado, origen, consultado_en)
SELECT f.tercero_id, f.id, NULL, l.id, t.nombre, t.numero_documento, 'sin_coincidencia', 'automatica',
       f.enviado_en + INTERVAL 5 MINUTE
  FROM formularios f JOIN terceros t ON t.id = f.tercero_id CROSS JOIN listas_restrictivas l
 WHERE f.enviado_en IS NOT NULL;

INSERT INTO consultas_listas (tercero_id, formulario_id, persona_vinculada_id, lista_id, nombre_consultado,
                              documento_consultado, resultado, origen, consultado_en)
SELECT f.tercero_id, f.id, pv.id, l.id, pv.nombre_completo, pv.numero_documento, 'sin_coincidencia', 'automatica',
       f.enviado_en + INTERVAL 6 MINUTE
  FROM formularios f
  JOIN personas_vinculadas pv ON pv.formulario_id = f.id
       AND pv.rol IN ('representante_principal','accionista','beneficiario_final')
  CROSS JOIN listas_restrictivas l
 WHERE f.enviado_en IS NOT NULL;

-- Consota: homonimo parcial en OFAC del accionista Jose Antonio Rendon
UPDATE consultas_listas c JOIN listas_restrictivas l ON l.id = c.lista_id
   SET c.resultado = 'coincidencia_parcial',
       c.detalle = 'Coincide el nombre con un registro de la lista SDN; el documento no coincide. Requiere análisis.'
 WHERE c.formulario_id = 10 AND l.codigo = 'OFAC' AND c.documento_consultado = '16210987';

-- Transportes del Otun: homonimo en Procuraduria, descartado
UPDATE consultas_listas c JOIN listas_restrictivas l ON l.id = c.lista_id
   SET c.resultado = 'coincidencia_parcial', c.origen = 'manual', c.consultado_por = 3,
       c.detalle = 'Antecedente a nombre de un homónimo con cédula distinta.'
 WHERE c.formulario_id = 4 AND l.codigo = 'PROCURADURIA' AND c.persona_vinculada_id IS NOT NULL
   AND c.documento_consultado = '10096321';

INSERT INTO alertas (tercero_id, formulario_id, consulta_lista_id, origen, severidad, descripcion, estado,
                     asignada_a, decision, creada_en, cerrada_por, cerrada_en)
SELECT 10, 10, c.id, 'lista_restrictiva', 'alta',
       'Coincidencia parcial en la lista OFAC del accionista José Antonio Rendón Rendón (45 %).',
       'en_analisis', 3, NULL, c.consultado_en, NULL, NULL
  FROM consultas_listas c JOIN listas_restrictivas l ON l.id = c.lista_id
 WHERE c.formulario_id = 10 AND l.codigo = 'OFAC' AND c.resultado = 'coincidencia_parcial'
 LIMIT 1;

INSERT INTO alertas (tercero_id, formulario_id, consulta_lista_id, origen, severidad, descripcion, estado,
                     asignada_a, decision, creada_en, cerrada_por, cerrada_en)
SELECT 4, 4, c.id, 'lista_restrictiva', 'media',
       'Coincidencia parcial en antecedentes de la Procuraduría del representante legal.',
       'descartada', 3, 'Homónimo: el número de cédula del registro es distinto. Se adjunta certificado.',
       c.consultado_en, 2, '2026-10-16 09:40'
  FROM consultas_listas c JOIN listas_restrictivas l ON l.id = c.lista_id
 WHERE c.formulario_id = 4 AND l.codigo = 'PROCURADURIA' AND c.resultado = 'coincidencia_parcial'
 LIMIT 1;

INSERT INTO alertas (tercero_id, formulario_id, origen, severidad, descripcion, estado, asignada_a, creada_en)
VALUES (6, 6, 'pep', 'media',
        'El tercero declara ser PEP (Decreto 830 de 2021). Requiere debida diligencia intensificada y aprobación del oficial de cumplimiento.',
        'abierta', 2, '2026-10-24 09:31');

-- Terceros con alertas: nivel de riesgo
UPDATE terceros SET nivel_riesgo = 'bajo'  WHERE id IN (1, 3, 5, 7, 9);
UPDATE terceros SET nivel_riesgo = 'medio' WHERE id IN (4, 6, 10);

-- Una invitacion pendiente
INSERT INTO invitaciones (tipo_documento, numero_documento, correo, relacion, token_hash, enviada_por, enviada_en, vence_en) VALUES
  ('NIT', '901845226', 'contratos@nuevoproveedor.test', 'proveedor', '07804231df9b95fd378ff5bbe65cb4350aca78b7acf64ef546d2c4995138fd24', 2, '2026-11-04 10:00:00', '2026-11-19 10:00:00');

-- Auditoria
INSERT INTO auditoria (ocurrido_en, actor, usuario_id, tercero_id, accion, entidad, entidad_id, detalle, ip) VALUES
  ('2026-10-20 07:58:00', 'tercero', NULL, 1, 'acceso', 'terceros', '1', '{"canal":"correo,sms"}', '181.49.120.11'),
  ('2026-10-20 08:00:00', 'tercero', NULL, 1, 'crear_formulario', 'formularios', '1', '{"periodo":2026,"tipo":"actualizacion"}', '181.49.120.11'),
  ('2026-10-22 18:20:00', 'tercero', NULL, 1, 'guardar_borrador', 'formularios', '1', '{"modulo":"Información financiera"}', '181.49.120.11'),
  ('2026-10-26 07:12:00', 'tercero', NULL, 1, 'firmar_y_enviar', 'formularios', '1', '{"radicado":"SRL-2026-01482","codigo_id":1}', '181.49.120.11'),
  ('2026-10-26 07:17:00', 'sistema', NULL, 1, 'consultar_listas', 'formularios', '1', '{"listas":6,"resultado":"sin_coincidencia"}', '10.20.0.1'),
  ('2026-10-25 16:05:00', 'usuario', 2, 3, 'aprobar', 'formularios', '3', '{"vence_en":"2027-10-25"}', '10.20.0.2'),
  ('2026-10-25 11:27:00', 'usuario', 2, 4, 'rechazar', 'formularios', '4', NULL, '10.20.0.2'),
  ('2026-10-30 09:15:00', 'usuario', 3, 11, 'devolver', 'formularios', '11', NULL, '10.20.0.3'),
  ('2026-11-04 10:00:00', 'usuario', 2, NULL, 'invitar', 'invitaciones', '1', '{"relacion":"proveedor"}', '10.20.0.2'),
  ('2026-11-06 07:30:00', 'usuario', 2, NULL, 'ingreso', 'usuarios', '2', NULL, '10.20.0.2'),
  ('2026-11-06 07:45:00', 'usuario', 3, NULL, 'ingreso', 'usuarios', '3', NULL, '10.20.0.3');

-- Deja el modo de actualizacion segura como estaba
SET SQL_SAFE_UPDATES = @modo_seguro_anterior;
