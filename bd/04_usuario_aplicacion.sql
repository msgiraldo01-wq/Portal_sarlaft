-- =====================================================================
-- PORTAL SARLAFT - 04_usuario_aplicacion.sql
-- Crea el usuario de MySQL con el que se conecta la aplicacion Node.
-- La aplicacion NUNCA debe conectarse como root.
--
-- ANTES DE EJECUTAR: cambie la contrasena y, si la aplicacion corre en
-- otro servidor, cambie 'localhost' por la IP de ese servidor.
-- La misma contrasena se usara en la configuracion de conexion cuando la
-- aplicacion se conecte a la base (siguiente sprint).
-- =====================================================================

CREATE USER IF NOT EXISTS 'portal_sarlaft'@'localhost' IDENTIFIED BY 'cambie_esta_clave';

-- Solo leer y escribir datos. No puede crear, borrar ni alterar tablas.
GRANT SELECT, INSERT, UPDATE, DELETE ON portal_sarlaft.* TO 'portal_sarlaft'@'localhost';

-- Los disparadores de la base ya impiden modificar o borrar la auditoria,
-- aunque el usuario tenga permiso de UPDATE y DELETE.
