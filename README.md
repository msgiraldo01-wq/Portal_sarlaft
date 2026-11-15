# Portal SARLAFT · Sprint 1: vistas y base de datos

Sistema para que proveedores, clientes, empleados y accionistas diligencien su
información SARLAFT (Circular Externa 009 de 2016 de la Supersalud y sus
modificaciones), y para que el equipo de cumplimiento la revise.

**Esta entrega contiene:**

- **Vistas:** todas las pantallas de la plataforma, navegables, con datos de
  ejemplo tomados de la base de datos de prueba.
- **Base de datos:** modelo entidad-relación (MER) y scripts SQL para MySQL 8.

**Fuera de esta entrega (siguientes sprints):** la lógica de negocio. En esta
versión los botones navegan entre pantallas o abren sus ventanas, pero nada se
guarda, se valida contra la base ni se envía por correo.

## Estado actual

Las pantallas y la base de datos están terminadas. La lógica se está
desarrollando paso a paso: ver **`PLAN_DE_TRABAJO.md`**.

## Cómo ejecutarlo

Requiere Node.js 20 o superior.

```bash
npm install
npm run dev
```

Abrir http://localhost:3000/ingreso (cualquier usuario y contraseña).

## Pantallas

### Terceros (proveedores, clientes, empleados, accionistas)

| Dirección | Pantalla |
|---|---|
| `/acceso` | Identificación: persona jurídica o natural y documento |
| `/acceso/registro` | Registro de un tercero nuevo |
| `/acceso/codigo` | Código de verificación de un solo uso |
| `/formulario/juridica/paso/1` … `/11` | Formulario de persona jurídica, 11 pasos |
| `/formulario/natural/paso/1` … `/8` | Formulario de persona natural, 8 pasos |
| `/formulario/enviado` | Confirmación con el radicado |
| `/mi-formulario` | Estado del formulario cuando el equipo lo devuelve para corregir |

Los pasos del formulario los dibuja **una sola plantilla** (`formulario_paso.html`)
a partir del cuestionario guardado en la base (tablas `modulos`, `preguntas`,
`modulo_secciones`). Si se cambia una pregunta en la base, la pantalla cambia.
Las preguntas que dependen de otra («si respondió Sí…») aparecen y desaparecen
solo con CSS.

### Equipo de cumplimiento

| Dirección | Pantalla |
|---|---|
| `/ingreso` | Ingreso con usuario y contraseña |
| `/` | Inicio: resumen, vencimientos, formularios recientes y alertas |
| `/formularios/pendientes`, `/revision`, `/aprobados` | Bandejas de formularios |
| `/formularios/1` … `/11` | Revisión de un formulario: datos, personas, respuestas, soportes, listas, historial; aprobar, devolver o rechazar |
| `/terceros/clientes`, `/proveedores`, `/empleados`, `/accionistas` | Listas de terceros |
| `/terceros/ficha/1` … `/11` | Ficha de un tercero |
| `/diligencia/listas` | Consultas en listas restrictivas |
| `/diligencia/pep` | Personas expuestas políticamente |
| `/diligencia/alertas` y `/diligencia/alertas/1` | Alertas y su análisis |
| `/reportes` | Indicadores y vencimientos |
| `/ajustes/preguntas` | Preguntas del formulario (cuestionario versionado) |
| `/ajustes/usuarios` | Usuarios y roles |
| `/ajustes/parametros` | Parámetros del sistema |
| `/ajustes/guia-estilo` | Todos los componentes visuales |

Todas funcionan en celular y en tema claro u oscuro (botón de la luna).

## Base de datos

Todo está en `bd/`. El diseño, los diagramas y el diccionario de datos están en
**`bd/MER.md`**; los diagramas como imagen, en `bd/mer/`.

Instalar, en este orden (consola `mysql` o MySQL Workbench, ejecutando cada
archivo completo):

1. `bd/01_esquema.sql`: tablas, restricciones, disparadores y vistas SQL.
2. `bd/02_catalogos.sql`: catálogos, parámetros y los dos cuestionarios.
3. `bd/03_datos_prueba.sql`: datos ficticios (solo en desarrollo).
4. `bd/04_usuario_aplicacion.sql`: usuario de MySQL para la aplicación (cambie la contraseña antes).

`bd/00_reiniciar_desarrollo.sql` borra la base completa para empezar de cero.

Los datos que muestran las pantallas (`src/datos_demo/*.json`) se exportaron de
esa base de prueba, así que coinciden con lo que hay en MySQL.

## Estructura

```
portal_sarlaft/
├── servidor.js                 Arranca el servidor
├── package.json                Dependencias: express y nunjucks
├── bd/                         Base de datos: MER y scripts SQL
├── src/
│   ├── app.js                  Arma la aplicación Express
│   ├── config.js               Nombre del sistema e imagen de ingreso
│   ├── menu.js                 Menú lateral
│   ├── vistas.js               Motor de plantillas y formatos (fecha, moneda)
│   ├── datos_demo.js           Carga los datos de ejemplo
│   ├── datos_demo/*.json       Datos exportados de la base de prueba
│   └── rutas/paginas.js        Qué pantalla se muestra en cada dirección
├── vistas/                     Plantillas HTML (Nunjucks)
└── publico/
    ├── css/estilo.css          Hoja de estilos única (comentada)
    ├── js/base.js              Comportamiento de la interfaz
    └── img/                    Imagen de ingreso e icono
```

### El JavaScript de esta entrega

| Archivo | Qué hace |
|---|---|
| `servidor.js` | Arranca el servidor en el puerto 3000 |
| `src/app.js` | Configura Express: plantillas, archivos estáticos, rutas y página 404 |
| `src/vistas.js` | Configura Nunjucks y define los formatos de fecha, moneda y tamaño de archivo |
| `src/config.js`, `src/menu.js` | Solo datos: nombre del sistema, imagen, opciones del menú |
| `src/datos_demo.js` | Carga los archivos JSON y calcula los números del menú |
| `src/rutas/paginas.js` | Una ruta por pantalla: elige los datos y llama a `res.render` |
| `publico/js/base.js` | Tema claro/oscuro, grupos del menú, menú en el celular, abrir y cerrar diálogos |

No hay lógica de negocio: no se valida, no se guarda y no se consulta la base.

## Cómo se construyó

Las pantallas, el diseño visual, el modelo de datos y los scripts SQL se
generaron con asistencia de inteligencia artificial (Claude, de Anthropic), a
partir de los requerimientos, la normativa y las pantallas de referencia que
definió el autor del proyecto.
