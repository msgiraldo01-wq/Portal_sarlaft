/*
  Menu del sistema interno.
  Una sola fuente de verdad: base.html lo recorre para pintar el menu y
  rutas/paginas.js lo recorre para registrar las rutas de cada seccion.

    clave     la que pone cada pagina con {% set seccion = "..." %}
    icono     nombre de un icono de vistas/_iconos.html
    contador  clave dentro del objeto "contadores" (opcional)
    tono      color del contador: neutro, info, atencion, peligro
*/

const MENU = [
  { tipo: "enlace", clave: "inicio", texto: "Inicio", url: "/", icono: "inicio" },
  {
    tipo: "grupo", id: "terceros", texto: "Terceros", abierto: true,
    enlaces: [
      { clave: "clientes", texto: "Clientes", url: "/terceros/clientes", icono: "maletin" },
      { clave: "proveedores", texto: "Proveedores", url: "/terceros/proveedores", icono: "camion" },
      { clave: "empleados", texto: "Empleados", url: "/terceros/empleados", icono: "credencial" },
      { clave: "accionistas", texto: "Accionistas", url: "/terceros/accionistas", icono: "torta" },
    ],
  },
  {
    tipo: "grupo", id: "formularios", texto: "Formularios", abierto: true,
    enlaces: [
      { clave: "pendientes", texto: "Pendientes", url: "/formularios/pendientes", icono: "reloj", contador: "pendientes", tono: "atencion" },
      { clave: "revision", texto: "En revisión", url: "/formularios/revision", icono: "ojo", contador: "revision", tono: "info" },
      { clave: "aprobados", texto: "Aprobados", url: "/formularios/aprobados", icono: "aprobado" },
    ],
  },
  {
    tipo: "grupo", id: "diligencia", texto: "Debida diligencia", abierto: true,
    enlaces: [
      { clave: "listas", texto: "Listas restrictivas", url: "/diligencia/listas", icono: "escudo" },
      { clave: "pep", texto: "PEP", url: "/diligencia/pep", icono: "institucion" },
      { clave: "alertas", texto: "Alertas", url: "/diligencia/alertas", icono: "alerta", contador: "alertas", tono: "peligro" },
    ],
  },
  { tipo: "enlace", clave: "reportes", texto: "Reportes", url: "/reportes", icono: "barras" },
  {
    tipo: "grupo", id: "ajustes", texto: "Ajustes", abierto: false,
    enlaces: [
      { clave: "preguntas", texto: "Preguntas del formulario", url: "/ajustes/preguntas", icono: "interrogacion" },
      { clave: "usuarios", texto: "Usuarios", url: "/ajustes/usuarios", icono: "usuarios" },
      { clave: "parametros", texto: "Parámetros", url: "/ajustes/parametros", icono: "deslizadores" },
      { clave: "guia", texto: "Guía de estilo", url: "/ajustes/guia-estilo", icono: "editar" },
    ],
  },
];

/* Todos los enlaces en una lista plana, con el nombre de su grupo */
function enlacesDelMenu() {
  return MENU.flatMap((entrada) =>
    entrada.tipo === "grupo"
      ? entrada.enlaces.map((e) => ({ ...e, grupo: entrada.texto }))
      : [{ ...entrada, grupo: null }]
  );
}

module.exports = { MENU, enlacesDelMenu };
