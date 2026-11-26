# Portal SARLAFT

Sistema para que proveedores, clientes, empleados y accionistas diligencien su
información SARLAFT (Circular Externa 009 de 2016 de la Supersalud y sus
modificaciones), y para que el equipo de cumplimiento la revise.

## Estado del proyecto

| Entrega | Contenido | Estado |
|---|---|---|
| Sprint 1 | Vistas de todas las pantallas y base de datos (MER y scripts SQL) | Terminado |
| Sprint 2 | Lógica: ingreso del equipo, registro de terceros (persona jurídica y natural) y listas de terceros desde MySQL | Terminado |
| Siguiente | Código de verificación del tercero, ficha del tercero y formularios desde MySQL, auditoría | Pendiente |

El avance paso a paso y la bitácora están en **`PLAN_DE_TRABAJO.md`**.

Estado al 22/11/2026 (noche)
[x] Pasos 0–4. Git, conexión MySQL (src/bd.js), ingreso con bcrypt, sesión con express-session (regenerate, httpOnly, sameSite, 30 min, secreto obligatorio), rutas protegidas, salir.
[x] Pasos 5–6. src/rutas/acceso.js: identificación (POST /acceso) y registro (POST /acceso/registro) con validación en el servidor (listas blancas, expresiones regulares, Ley 1581), src/util/nit.js (DV DIAN) y transacción terceros + tercero_relaciones (commit/rollback, release en finally, ER_DUP_ENTRY).
[x] Pasos 8–9. Listas de terceros desde MySQL en paginas.js (SQL_TERCEROS: JOIN relación activa + LEFT JOIN formulario más reciente). Filtros GET q y riesgo con WHERE dinámico parametrizado.
[x] Extra: ficha /terceros/ficha/:id desde MySQL (probada el 22/11).
req.params validado con Number.isInteger.
Consultas:
datos del tercero con GROUP BY + GROUP_CONCAT de las relaciones;
formularios con el peor resultado en listas (ORDER BY sobre el ENUM DESC + COALESCE);
alertas;
vencimiento desde la vista v_vencimientos.
bd.js con dateStrings: true.
no_encontrada.html acepta titulo_error y mensaje_error, y se usa con estado 500 en el catch.
[x] Documentación:
README nuevo, que declara el uso de IA en ambos sprints;
.env.ejemplo;
verificado que el .env nunca se subió a git;
bitácora, a cargo del autor.
[x] Guía de sustentación creada en Claude Docs.
[ ] Mejoras menores sugeridas en la ficha:
fila «Este tercero aún no tiene formularios» cuando no hay;
«Vinculación/Actualización» con tilde.
[ ] Paso 7: código de verificación. Queda para la versión de la empresa.
[ ] Paso 10: auditoría. Opcional.
[ ] Pendientes para producción:
sesiones en MySQL;
salir por POST;
Cache-Control: no-store;
bloqueo por intentos_fallidos;
HTTPS y cookie secure;
inicio, bandejas y reportes desde MySQL.
Datos de prueba en la base de desarrollo del autor
NIT 900000002 (id 12) y 900000003 (id 13): proveedores.
900000004: prueba del rollback, no quedó.
CC 1000000001 «pedro perez»: proveedor.
Para la demostración se sugirió usar NIT 900000010 y CC 1000000020.

### Qué funciona con datos reales

- **Ingreso del equipo** (`/ingreso`):
  - Usuario y contraseña verificados contra MySQL con bcrypt.
  - Sesión con cookie firmada (`httpOnly`, `sameSite`, vence a los 30 minutos).
  - Pantallas internas protegidas.
  - Cierre de sesión.
- **Identificación del tercero** (`/acceso`):
  - Valida el documento en el servidor.
  - Revisa en la base si ya está registrado.
- **Registro del tercero** (`/acceso/registro`):
  - Persona jurídica (NIT, con dígito de verificación calculado con el algoritmo de la DIAN) o persona natural.
  - Validación de todos los campos en el servidor.
  - Autorización de tratamiento de datos (Ley 1581 de 2012) con fecha e IP.
  - Guardado en `terceros` y `tercero_relaciones` dentro de una transacción.
- **Listas de terceros** (`/terceros/clientes`, `/proveedores`, `/empleados`, `/accionistas`):
  - Leídas de MySQL, con el estado del formulario más reciente.
  - Búsqueda por nombre o documento y filtro por nivel de riesgo.

Las demás pantallas siguen mostrando datos de ejemplo (`src/datos_demo/*.json`).

## Cómo ejecutarlo

Requiere **Node.js 20** o superior y **MySQL 8**.

1. Instalar las dependencias:
   ```bash
   npm install
   ```
2. Crear la base de datos. En la consola `mysql` o en MySQL Workbench, ejecute cada archivo completo, en este orden:
   1. `bd/01_esquema.sql`: tablas, restricciones, disparadores y vistas SQL.
   2. `bd/02_catalogos.sql`: catálogos, parámetros y los dos cuestionarios.
   3. `bd/03_datos_prueba.sql`: datos ficticios. **Solo en desarrollo.**
   4. `bd/04_usuario_aplicacion.sql`: usuario de MySQL para la aplicación, con permisos mínimos. Cambie la contraseña antes de ejecutarlo.

   `bd/00_reiniciar_desarrollo.sql` borra la base completa para empezar de cero.
3. Configurar el entorno: copie `.env.ejemplo` como `.env` y complete los valores (la contraseña del paso 2.4 y un secreto de sesión).
4. Arrancar:
   ```bash
   npm run dev
   ```
5. Abrir http://localhost:3000/ingreso.

**Usuarios de prueba** (solo con `03_datos_prueba.sql`; la contraseña de todos es `Demo2026*`):

| Usuario | Rol |
|---|---|
| `laura.restrepo` | Oficial de cumplimiento |
| `carlos.mejia` | Analista |
| `admin.sistemas` | Administrador |
| `auditoria.interna` | Auditor |

Los terceros entran por http://localhost:3000/acceso, sin usuario.

## Seguridad

- Las contraseñas se guardan con **bcrypt** (hash con sal, costo 12); nunca en texto claro.
- Si el usuario no existe o la clave está mal, el mensaje es el mismo, para no revelar qué usuarios existen.
- Todas las consultas usan **parámetros (`?`)**, lo que evita la inyección SQL. Los filtros de búsqueda arman el `WHERE` solo con fragmentos fijos.
- Validación en el **servidor**: la del navegador solo ayuda a la persona; la que protege es la del servidor.
- Sesión:
  - se **regenera al ingresar**, contra la fijación de sesión;
  - la cookie es `httpOnly` y `sameSite: lax`;
  - vence a los 30 minutos;
  - se destruye al salir.
- El servidor **no arranca** si falta `SESION_SECRETO`.
- La aplicación se conecta con un usuario de MySQL con permisos mínimos, no con `root`.
- Los errores técnicos se escriben en la terminal; la persona solo ve un mensaje general.
- En desarrollo se usan **solo datos ficticios** (Ley 1581 de 2012).

## Pantallas

### Terceros (proveedores, clientes, empleados, accionistas)

| Dirección | Pantalla |
|---|---|
| `/acceso` | Identificación: persona jurídica o natural y documento |
| `/acceso/registro` | Registro de un tercero nuevo |
| `/acceso/codigo` | Código de verificación de un solo uso *(todavía de demostración)* |
| `/formulario/juridica/paso/1` … `/11` | Formulario de persona jurídica, 11 pasos *(demostración)* |
| `/formulario/natural/paso/1` … `/8` | Formulario de persona natural, 8 pasos *(demostración)* |
| `/formulario/enviado` | Confirmación con el radicado *(demostración)* |
| `/mi-formulario` | Estado del formulario cuando el equipo lo devuelve *(demostración)* |

### Equipo de cumplimiento (requiere ingresar)

| Dirección | Pantalla |
|---|---|
| `/ingreso`, `/salir` | Ingreso y cierre de sesión |
| `/` | Inicio: resumen, vencimientos, formularios recientes y alertas |
| `/formularios/pendientes`, `/revision`, `/aprobados` | Bandejas de formularios |
| `/formularios/1` … `/11` | Revisión de un formulario |
| `/terceros/clientes`, `/proveedores`, `/empleados`, `/accionistas` | **Listas de terceros (MySQL)** |
| `/terceros/ficha/1` … `/11` | Ficha de un tercero |
| `/diligencia/listas`, `/pep`, `/alertas` | Debida diligencia |
| `/reportes` | Indicadores y vencimientos |
| `/ajustes/preguntas`, `/usuarios`, `/parametros`, `/guia-estilo` | Ajustes |

Todas funcionan en celular y en tema claro u oscuro.

## Base de datos

Todo está en `bd/`. El diseño, los diagramas y el diccionario de datos están en
**`bd/MER.md`**; los diagramas como imagen, en `bd/mer/`.

## Estructura

```
portal_sarlaft/
├── servidor.js                 Carga el .env y arranca el servidor
├── .env.ejemplo                Plantilla de configuración (copiar como .env)
├── bd/                         Base de datos: MER y scripts SQL
├── src/
│   ├── app.js                  Arma Express: vistas, estáticos, sesión, rutas y 404
│   ├── bd.js                   Pool de conexiones a MySQL (mysql2)
│   ├── rutas/
│   │   ├── autenticacion.js    POST /ingreso y GET /salir
│   │   ├── acceso.js           Identificación y registro del tercero
│   │   └── paginas.js          Pantallas; listas de terceros desde MySQL
│   ├── util/nit.js             Dígito de verificación del NIT (DIAN)
│   ├── config.js, menu.js      Nombre del sistema, imagen y menú
│   ├── vistas.js               Nunjucks y formatos (fecha, moneda)
│   └── datos_demo/             Datos de ejemplo de las pantallas sin lógica
├── vistas/                     Plantillas HTML (Nunjucks)
└── publico/                    CSS, JavaScript del navegador e imágenes
```


Herramientas

.env y process.env deben tener los mismos nombres; reiniciar tras cambiar el .env.
Los paréntesis en la clave (11 vs 9 caracteres).
Cannot find module → npm install o una ruta mal escrita (../db vs ../bd, dos veces).
Workbench: USE y las pestañas de resultados.
Guardar con Ctrl + S antes de probar.
No borrar lo de al lado al reemplazar un bloque (RELACIONES).

Express

Alcance y módulos.
Orden de middlewares y 404.
Direcciones letra por letra.
Opciones mal escritas se ignoran.
Código pegado en la ruta equivocada.
GET para consultar (req.query), POST para modificar (req.body), req.params para partes de la dirección.

JavaScript

Choque con res.locals.usuario.
Ternario, propagación, obj[variable], desestructuración.
Callbacks y });.
Errores de sintaxis vistos.
SQL dinámico solo con fragmentos fijos.

Bases de datos

ACID y rollback; AUTO_INCREMENT no se devuelve.
Llave única.
CHECK.
JOIN vs LEFT JOIN.
Subconsultas, GROUP BY/GROUP_CONCAT, vistas SQL.
Orden de un ENUM, COALESCE.
Intercalación _ai_ci.
dateStrings.
## Cómo se construyó

- **Sprint 1:** las pantallas, el diseño visual, el modelo de datos y los scripts SQL se generaron con asistencia de inteligencia artificial (Claude, de Anthropic), a partir de los requerimientos, la normativa y las pantallas de referencia que definió el autor.
- **Sprint 2:** la lógica la construyó el autor paso a paso con guía de inteligencia artificial (Claude). La guía explicaba cada bloque de código y el autor lo transcribió, lo probó y corrigió los errores. El proceso está en la bitácora de `PLAN_DE_TRABAJO.md`.
