/*
  Motor de plantillas: Nunjucks, con sintaxis casi igual a Jinja2
  ({% extends %}, {% block %}, {% macro %}, {{ variable }}).
  Aqui se registran las variables y los filtros que ven todas las vistas.
*/
const path = require("path");
const nunjucks = require("nunjucks");
const config = require("./config");
const { MENU } = require("./menu");

/* Direccion de un archivo de publico/, con la version para el navegador */
function estatico(ruta) {
  return `/publico/${ruta}?v=${config.VERSION_ESTATICOS}`;
}

/* "2026-10-26 07:12:00" -> "26/10/2026 07:12"   |   "2026-10-26" -> "26/10/2026" */
function fecha(texto, conHora = true) {
  if (!texto) return "";
  const [dia, hora] = String(texto).split(" ");
  const [a, m, d] = dia.split("-");
  return conHora && hora ? `${d}/${m}/${a} ${hora.slice(0, 5)}` : `${d}/${m}/${a}`;
}

/* 4850000000 -> "$ 4.850.000.000" */
const formatoPesos = new Intl.NumberFormat("es-CO", { style: "currency", currency: "COP", maximumFractionDigits: 0 });
function moneda(valor) {
  return valor === null || valor === undefined ? "" : formatoPesos.format(valor);
}

/* 254000 -> "248 KB" */
function tamano(bytes) {
  return bytes >= 1048576 ? `${(bytes / 1048576).toFixed(1)} MB` : `${Math.round(bytes / 1024)} KB`;
}

function configurarVistas(app) {
  const entorno = nunjucks.configure(path.join(__dirname, "..", "vistas"), {
    autoescape: true,
    express: app,
    noCache: true,
  });

  entorno.addGlobal("SISTEMA", config.SISTEMA);
  entorno.addGlobal("SUBTITULO", config.SUBTITULO);
  entorno.addGlobal("ENTIDAD", config.ENTIDAD);
  entorno.addGlobal("IMAGEN_ACCESO", config.IMAGEN_ACCESO);
  entorno.addGlobal("MENU", MENU);
  entorno.addGlobal("estatico", estatico);

  entorno.addFilter("fecha", fecha);
  entorno.addFilter("moneda", moneda);
  entorno.addFilter("tamano", tamano);

  /* lista | tiene("clave", valor): algun elemento con ese valor en ese campo */
  entorno.addFilter("tiene", (lista, campo, valor) =>
    Array.isArray(lista) && lista.some((x) => x && x[campo] === valor));

  /* lista | donde("campo", valor): solo los elementos con ese valor en ese campo */
  entorno.addFilter("donde", (lista, campo, valor) =>
    (lista || []).filter((x) => x && x[campo] === valor));

  /* objeto | claves: nombres de las propiedades (para listar iconos) */
  entorno.addFilter("claves", (objeto) => Object.keys(objeto || {}));

  app.set("view engine", "html");
  return entorno;
}

module.exports = { configurarVistas };
