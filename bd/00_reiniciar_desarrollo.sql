-- =====================================================================
-- PORTAL SARLAFT - 00_reiniciar_desarrollo.sql
--
-- ¡CUIDADO! BORRA LA BASE portal_sarlaft COMPLETA CON TODOS SUS DATOS.
-- Solo para el equipo de desarrollo, nunca en el servidor de la empresa.
--
-- Orden para dejar todo desde cero:
--   00_reiniciar_desarrollo.sql -> 01_esquema.sql -> 02_catalogos.sql -> 03_datos_prueba.sql
-- =====================================================================
DROP DATABASE IF EXISTS portal_sarlaft;
