# Plan de trabajo · Lógica del Portal SARLAFT

Alcance acordado con el docente para esta etapa:

1. **Ingreso (login)** del equipo de cumplimiento.
2. **Registro de terceros**, en sus dos opciones: persona jurídica y persona natural.
3. **Pantalla de clientes** con datos reales de la base.

El resto de pantallas sigue mostrando datos de ejemplo (`src/datos_demo/`)
hasta que les llegue su turno.

## Forma de trabajo

- Un paso a la vez. Cada paso dice qué construir, cómo probarlo y qué
  concepto se aprende.
- El código lo escribo yo (el autor del proyecto). La guía explica y revisa;
  no entrega el código hecho.
- Al terminar cada paso: probarlo, anotarlo en la bitácora y guardar una
  versión (commit) con Git.

## Pasos

### Preparación
- [ ] **Paso 0.** Control de versiones con Git.
- [ ] **Paso 1.** Conectar Node.js con MySQL y comprobar la conexión.

### Ingreso del equipo
- [ ] **Paso 2.** Recibir los datos del formulario de ingreso en el servidor.
- [ ] **Paso 3.** Buscar el usuario en la base y comparar la contraseña cifrada (bcrypt).
- [ ] **Paso 4.** Recordar quién ingresó (sesión), proteger las pantallas internas y cerrar sesión.

### Registro de terceros
- [ ] **Paso 5.** Recibir y validar los datos de identificación y registro (incluye el dígito de verificación del NIT).
- [ ] **Paso 6.** Guardar el tercero y su relación con la entidad (transacción); evitar documentos duplicados.
- [ ] **Paso 7.** Código de verificación: generarlo, guardarlo cifrado y verificarlo.

### Clientes
- [ ] **Paso 8.** Consultar los terceros con relación «cliente» y mostrarlos en la pantalla.
- [ ] **Paso 9.** Buscar y filtrar clientes desde la pantalla.

### Cierre
- [ ] **Paso 10.** Registrar en la auditoría los ingresos y los registros.

## Bitácora

# Avance de la lógica · Portal SARLAFT

Forma de trabajo: el autor escribe el código; la guía explica cada paso, revisa y corrige. No se entrega código hecho.
Alcance pedido por el docente: login, registro (persona jurídica y natural) y pantalla de clientes.

## Estado al 14/11/2026

- [x] Paso 0. Git iniciado.
- [x] Paso 1. Conexión Node → MySQL. `src/bd.js` con `mysql2/promise` (pool), variables `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` en `.env`; `dotenv` cargado en la primera línea de `servidor.js`. Ruta `GET /api/salud` en `src/app.js` responde la versión (MySQL 8.0.43). Usuario MySQL `portal_sarlaft` con SELECT/INSERT/UPDATE/DELETE.
- [x] Paso 2. Formulario de ingreso por POST. `express.urlencoded` en `app.js`; `src/rutas/autenticacion.js` con `POST /ingreso` que valida campos vacíos (con `.trim()`), vuelve a mostrar la vista con `error` y `usuarioEscrito`, o hace `console.log` del usuario y redirige a `/`.
- [ ] Paso 3. Buscar el usuario en la tabla `usuarios` y comparar con bcrypt (`bcryptjs`). Contraseña de prueba de los usuarios de `03_datos_prueba.sql`: Demo2026*.
- [ ] Paso 4. Sesión (`express-session`), proteger rutas internas, salir.
- [ ] Pasos 5–7. Registro de terceros (validación, DV del NIT, transacción, código de verificación).
- [ ] Pasos 8–9. Clientes desde MySQL.
- [ ] Paso 10. Auditoría.

Estado al 21/11/2026
[x] Paso 0. Git iniciado.
[x] Paso 1. Conexión Node → MySQL. src/bd.js con mysql2/promise (pool), variables DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME en .env; dotenv cargado en la primera línea de servidor.js. Ruta GET /api/salud en src/app.js responde la versión (MySQL 8.0.43). Usuario MySQL portal_sarlaft con SELECT/INSERT/UPDATE/DELETE.
[x] Paso 2. Formulario de ingreso por POST. express.urlencoded en app.js; src/rutas/autenticacion.js con POST /ingreso que valida campos vacíos (con .trim()) y vuelve a mostrar la vista con error y usuarioEscrito.
[x] Paso 3. Ingreso real (probado el 21/11):
SELECT id, nombre, rol, clave_hash, activo FROM usuarios WHERE usuario = ?;
bcrypt.compare con bcryptjs;
el mismo mensaje cuando el usuario no existe, está inactivo o la clave no coincide;
UPDATE usuarios SET ultimo_ingreso_en = NOW() WHERE id = ?;
redirección PRG a /;
un try/catch que muestra un mensaje genérico a la persona y deja el error real en la terminal (probado dañando una variable del .env).
Contraseña de prueba de los usuarios de 03_datos_prueba.sql: Demo2026*. Pendiente de cierre: corregir res.redirect("/inicio") → "/", quitar la nota «Vista de demostración» de ingreso.html, escribir la bitácora y hacer el commit.
[ ] Paso 4. Sesión (express-session), proteger rutas internas, salir, mostrar en el menú al usuario real (hoy sale siempre la demo «Laura Restrepo» de res.locals).
[ ] Pasos 5–7. Registro de terceros (validación, DV del NIT, transacción, código de verificación).
[ ] Pasos 8–9. Clientes desde MySQL.
[ ] Paso 10. Auditoría.

[x] Paso 0. Git iniciado.
[x] Paso 1. Conexión Node → MySQL.
src/bd.js con mysql2/promise (pool).
Variables DB_* en .env; dotenv cargado en servidor.js.
GET /api/salud (hoy protegida por sesión).
Usuario MySQL portal_sarlaft con mínimo privilegio.
[x] Paso 2. Formulario de ingreso por POST (express.urlencoded, POST /ingreso en src/rutas/autenticacion.js).
[x] Paso 3. Ingreso real.
SELECT ... WHERE usuario = ?, luego bcrypt.compare.
El mismo mensaje cuando el usuario no existe, está inactivo o la clave no coincide.
UPDATE ultimo_ingreso_en = NOW().
Redirección PRG a /.
try/catch con mensaje genérico en pantalla y detalle en la terminal.
Contraseña de prueba: Demo2026*.
[x] Paso 4. Sesión.
express-session:
cookie sarlaft.sid;
SESION_SECRETO en .env, y el servidor no arranca si falta;
httpOnly, sameSite: "lax", 30 min.
Al ingresar: regenerate y luego req.session.usuario = { id, nombre, rol }.
paginas.js: tabla ROLES, función iniciales(), res.locals.usuario tomado de la sesión, y middleware que exige sesión ubicado después de /ingreso y antes de /.
GET /salir en autenticacion.js con destroy y clearCookie.
Mejoras futuras: salir con POST, Cache-Control: no-store, sesiones guardadas en MySQL.
[x] Paso 5. Identificación del tercero.
src/rutas/acceso.js, montado en app.js antes de paginas.
POST /acceso:
lista blanca de tipos de documento;
expresiones regulares (el pasaporte acepta letras, los demás solo dígitos);
SELECT por tipo + número: si ya existe va a /acceso/codigo, si es nuevo va a /acceso/registro?....
acceso.html envía por POST y conserva tipo, documento y número si hay error.
Probado quitando pattern y required desde la Consola: el servidor rechaza el dato.
[x] Paso 6. Registro del tercero (probado el 21/11).
src/util/nit.js con digitoVerificacion() (algoritmo DIAN, función pura, probada con node -e).
acceso.js:
funciones validarDocumento() (compartida, DRY) y validarRegistro() (retorno temprano), que validan correo, celular 3XXXXXXXXX, relación en lista blanca y autorización Ley 1581;
POST /acceso/registro hace un SELECT previo y luego una transacción con getConnection, beginTransaction, INSERT terceros, insertId, INSERT tercero_relaciones (con CURDATE()) y commit;
rollback + throw en el catch interno y release() en el finally;
ER_DUP_ENTRY → va al código;
guarda req.session.terceroId.
acceso_registro.html: POST, campos name con el nombre de las columnas, campos hidden para tipo, documento y número, valores conservados si hay error.
Terceros de prueba en desarrollo: id 12 (NIT 900000002, DV 1) e id 13 (NIT 900000003, DV 7).
Prueba del rollback: con tercero_relacionesX, el NIT 900000004 no quedó en terceros.
[ ] Paso 7. Código de verificación (hash, vencimiento). Hoy /acceso/codigo sigue siendo demostración.
[ ] Pasos 8–9. Clientes desde MySQL. Hoy /terceros/clientes lee el JSON de demostración. Se propuso hacerlos antes del paso 7, porque son parte del alcance del docente.
[ ] Paso 10. Auditoría.

## Aprendizajes y tropiezos del autor (para repasar)

- Diferencia entre `node archivo` y `npm run script`.
- Nombres del `.env` deben coincidir exactamente con `process.env.X`; `npm run dev` no se reinicia al cambiar `.env`.
- Depuración del "Access denied": se comparó la longitud de la clave que leía Node (11) con la real (9); sobraban paréntesis en el `.env`. Las comillas sí las quita dotenv.
- Alcance (scope): `app` solo existe dentro de `crearApp()`.
- `app.get("ruta", función)`: con un solo argumento lee una configuración y no crea ruta.
- Choque de nombres con `res.locals.usuario` (objeto del menú) → `[object Object]`; se usó `usuarioEscrito`.
- Propiedad abreviada `{ x }` equivale a `{ x: x }`.

Herramientas y configuración

Diferencia entre node archivo y npm run script.
Los nombres del .env deben coincidir exactamente con process.env.X. npm run dev no se reinicia al cambiar el .env.
Depuración del «Access denied»: se comparó la longitud de la clave que leía Node (11) con la real (9); sobraban paréntesis en el .env. Las comillas sí las quita dotenv.
Paquete no instalado → Cannot find module 'bcryptjs'; se resuelve con npm install bcryptjs.
Workbench: el error 1046 (no hay base seleccionada) se evita con USE portal_sarlaft; o con doble clic en el esquema.

Express

Alcance (scope): app solo existe dentro de crearApp().
app.get("ruta", función): con un solo argumento lee una configuración y no crea ninguna ruta.
La dirección de res.redirect debe existir: redirigir a /inicio dio 404, porque el inicio es /.

JavaScript

Choque de nombres con res.locals.usuario (el objeto del menú) → aparecía [object Object]; se usó usuarioEscrito.
La propiedad abreviada { x } equivale a { x: x }.

Herramientas y configuración

Diferencia entre node archivo y npm run script.
Los nombres del .env deben coincidir exactamente con process.env.X. npm run dev no se reinicia al cambiar el .env.
Depuración del «Access denied»: se comparó la longitud de la clave que leía Node (11) con la real (9); sobraban paréntesis en el .env.
Cannot find module → falta npm install.
Workbench error 1046: falta USE portal_sarlaft;.
Workbench: cada resultado sale en su propia pestaña.
Técnica de depuración: imprimir para comprobar en vez de adivinar. console.log(require('./archivo')) muestra qué exporta un módulo.
Un cambio que no se guarda (Ctrl + S) no se prueba: la primera prueba del rollback no falló por eso.

Express

Alcance: app solo existe dentro de crearApp(); router (autenticacion.js, acceso.js) y rutas (paginas.js) no se ven entre sí.
app.get con un solo argumento no crea ninguna ruta.
Orden: middlewares antes de las rutas, el 404 siempre de último; un rutas.use protege solo lo registrado debajo.
Las direcciones deben coincidir letra por letra (/api/session ≠ /api/sesion), aunque Express ignora mayúsculas.
Una opción mal escrita en una librería se ignora en silencio (conecctionLimit, secret).
Ubicación: el código del registro quedó primero dentro de la ruta /acceso (paso 5) en vez de /acceso/registro (paso 6). Pista: datos solo existe en la ruta del registro.

JavaScript

[object Object] por choque de nombres → usuarioEscrito.
Propiedad abreviada { x }, plantillas ${}, ternario c ? a : b, propagación ...obj, obj[variable].
Encadenar split/filter/slice/map/join; reverse() y % en el DV.
Callbacks (regenerate, destroy): su error no lo atrapa el catch; el cierre es });.
module.exports = { f } se importa con const { f } = require(...) (desestructuración de objeto).
Funciones anidadas por un } que falta: se revisan contrayendo bloques en VS Code.
Errores de sintaxis vistos: ( sin cerrar, if !x), "" dobles, touperCase.

Bases de datos

Transacción = atomicidad (la «A» de ACID).
AUTO_INCREMENT no se devuelve con rollback: los id no son consecutivos.
La garantía real contra duplicados la da la llave única de la base.
Columna calculada nombre.
Los CHECK validan también desde la base.


Anote aquí, con sus palabras, qué hizo en cada paso y qué aprendió.
Le sirve para sustentar.

| Fecha | Paso | Qué hice | Qué aprendí / qué me costó |
|---|---|---|---|
|  |  |  |  |
