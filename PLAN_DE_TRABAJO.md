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


Anote aquí, con sus palabras, qué hizo en cada paso y qué aprendió.
Le sirve para sustentar.

| Fecha | Paso | Qué hice | Qué aprendí / qué me costó |
|---|---|---|---|
|  |  |  |  |
