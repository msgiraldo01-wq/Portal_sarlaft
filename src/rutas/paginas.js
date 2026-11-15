/*
  Rutas de las pantallas.

  Cada ruta hace lo mismo: toma los datos de ejemplo que necesita la
  pantalla y llama a res.render("vista.html", { datos }). No guarda ni
  valida nada: eso es la funcionalidad de los siguientes sprints.
*/
const express = require("express");
const demo = require("../datos_demo");

const rutas = express.Router();

/* Variables que necesitan todas las vistas (menu, usuario, catalogos) */
rutas.use((req, res, next) => {
  res.locals.usuario = demo.usuarioActual;
  res.locals.contadores = demo.contadores;
  res.locals.catalogos = demo.catalogos;
  next();
});

/* Busca un formulario por su id; si no existe, responde 404 */
function buscarFormulario(id, res) {
  const f = demo.formularios.find((x) => x.formulario_id === Number(id));
  if (!f) res.status(404).render("no_encontrada.html");
  return f;
}


/* =====================================================================
   PANTALLAS DEL TERCERO
   ===================================================================== */

rutas.get("/acceso", (req, res) => {
  res.render("acceso.html");
});

rutas.get("/acceso/registro", (req, res) => {
  const tipo = req.query.tipo === "natural" ? "natural" : "juridica";
  res.render("acceso_registro.html", {
    tipo,
    documento: tipo === "juridica" ? "NIT" : req.query.documento || "CC",
    numero: req.query.numero || "",
  });
});

rutas.get("/acceso/codigo", (req, res) => {
  res.render("acceso_codigo.html", { tipo: req.query.tipo === "natural" ? "natural" : "juridica" });
});

/* Un paso del formulario: /formulario/juridica/paso/3 */
rutas.get("/formulario/:tipo/paso/:n", (req, res) => {
  const tipo = req.params.tipo;
  const cuestionario = demo.cuestionarios.find((c) => c.tipo_persona === tipo);
  const n = Number(req.params.n);
  if (!cuestionario || !(n >= 1 && n <= cuestionario.modulos.length)) {
    return res.status(404).render("no_encontrada.html");
  }

  // Los pasos anteriores aparecen completos, el actual marcado y los demas pendientes
  const pasos = cuestionario.modulos.map((m) => ({
    nombre: m.nombre,
    estado: m.orden < n ? "completo" : m.orden === n ? "actual" : "pendiente",
  }));

  // Personas de ejemplo para llenar las tablas (formulario 1 = juridica, 6 = natural)
  const ejemplo = demo.formularios.find((f) => f.formulario_id === (tipo === "juridica" ? 1 : 6));
  const porRol = (rol) => ejemplo.personas.filter((p) => p.rol === rol);
  const personas = {
    representantes_suplentes: porRol("representante_suplente"),
    familiares_pep: porRol("familiar_pep"),
    accionistas: porRol("accionista"),
    junta_directiva: porRol("junta_directiva"),
    beneficiarios_finales: porRol("beneficiario_final"),
    grupo_empresarial: porRol("grupo_empresarial"),
    parientes_directivos: porRol("pariente_directivo"),
  };

  res.render("formulario_paso.html", {
    tipo, cuestionario, n, pasos, personas,
    modulo: cuestionario.modulos[n - 1],
    tipos_soporte: demo.catalogos.tipos_soporte.filter((t) => t.tipo_persona === tipo || t.tipo_persona === "ambas"),
  });
});

rutas.get("/formulario/demo", (req, res) => res.redirect("/formulario/juridica/paso/1"));

rutas.get("/formulario/enviado", (req, res) => {
  res.render("formulario_enviado.html", { f: demo.formularios.find((f) => f.formulario_id === 1) });
});

rutas.get("/mi-formulario", (req, res) => {
  res.render("mi_formulario.html", { f: demo.formularios.find((f) => f.estado === "devuelto") });
});


/* =====================================================================
   PANTALLAS DEL EQUIPO INTERNO
   ===================================================================== */

rutas.get("/ingreso", (req, res) => {
  res.render("ingreso.html");
});

rutas.get("/salir", (req, res) => {
  res.redirect("/ingreso");
});

rutas.get("/", (req, res) => {
  const contar = (estado) => demo.formularios.filter((f) => f.estado === estado).length;
  res.render("inicio.html", {
    seccion: "inicio",
    resumen: {
      pendientes: demo.contadores.pendientes,
      revision: contar("en_revision"),
      aprobados: contar("aprobado"),
      vencidos: demo.vencimientos.filter((v) => v.situacion === "vencido").length,
    },
    recientes: demo.formularios.slice(0, 8),
    alertas: demo.alertas.filter((a) => a.estado === "abierta" || a.estado === "en_analisis"),
    vencimientos: demo.vencimientos.filter((v) => v.situacion !== "vigente"),
  });
});

/* Bandejas de formularios. Cada una muestra unos estados. */
const BANDEJAS = {
  pendientes: { titulo: "Pendientes", detalle: "Borradores sin enviar y formularios devueltos para corregir", estados: ["borrador", "devuelto"] },
  revision: { titulo: "En revisión", detalle: "Formularios enviados que esperan revisión del equipo", estados: ["en_revision"] },
  aprobados: { titulo: "Aprobados y rechazados", detalle: "Formularios con decisión final", estados: ["aprobado", "rechazado"] },
};

for (const [clave, bandeja] of Object.entries(BANDEJAS)) {
  rutas.get(`/formularios/${clave}`, (req, res) => {
    res.render("bandeja.html", {
      seccion: clave,
      bandeja,
      formularios: demo.formularios.filter((f) => bandeja.estados.includes(f.estado)),
    });
  });
}

/* Revision de un formulario: /formularios/1 */
rutas.get("/formularios/:id", (req, res) => {
  const f = buscarFormulario(req.params.id, res);
  if (!f) return;
  // Una persona puede ser accionista y beneficiaria a la vez: su consulta
  // en cada lista se muestra una sola vez.
  const yaVistas = new Set();
  const consultas = f.consultas.filter((c) => {
    const clave = `${c.documento_consultado}-${c.lista}`;
    if (yaVistas.has(clave)) return false;
    yaVistas.add(clave);
    return true;
  });

  res.render("revision.html", {
    seccion: "revision",
    f,
    consultas,
    cuestionario: demo.cuestionarios.find((c) => c.id === f.cuestionario_id),
    alertas: demo.alertas.filter((a) => a.formulario_id === f.formulario_id),
  });
});

/* Terceros por relacion: /terceros/proveedores */
const RELACIONES = {
  clientes: ["cliente", "Clientes"],
  proveedores: ["proveedor", "Proveedores"],
  empleados: ["empleado", "Empleados"],
  accionistas: ["accionista", "Accionistas"],
};

for (const [clave, [relacion, titulo]] of Object.entries(RELACIONES)) {
  rutas.get(`/terceros/${clave}`, (req, res) => {
    const terceros = demo.terceros
      .filter((t) => t.relaciones.includes(relacion))
      .map((t) => ({ ...t, ultimo: demo.formularios.find((f) => f.tercero_id === t.id) }));
    res.render("terceros.html", { seccion: clave, titulo, relacion, terceros });
  });
}

/* Ficha de un tercero: /terceros/ficha/1 */
rutas.get("/terceros/ficha/:id", (req, res) => {
  const t = demo.terceros.find((x) => x.id === Number(req.params.id));
  if (!t) return res.status(404).render("no_encontrada.html");
  res.render("tercero.html", {
    // Marca en el menu la lista a la que pertenece (proveedores, clientes...)
    seccion: Object.keys(RELACIONES).find((clave) => RELACIONES[clave][0] === t.relaciones[0]) || "",
    t,
    formularios: demo.formularios.filter((f) => f.tercero_id === t.id),
    alertas: demo.alertas.filter((a) => a.tercero_id === t.id),
    vencimiento: demo.vencimientos.find((v) => v.tercero_id === t.id),
  });
});

rutas.get("/buscar", (req, res) => {
  const texto = String(req.query.q || "").trim().toLowerCase();
  const terceros = texto
    ? demo.terceros.filter((t) => t.nombre.toLowerCase().includes(texto) || t.numero_documento.includes(texto))
    : [];
  res.render("buscar.html", { seccion: "", busqueda: req.query.q || "", terceros });
});

/* Debida diligencia */
rutas.get("/diligencia/listas", (req, res) => {
  const resultado = req.query.resultado || "";
  res.render("listas.html", {
    seccion: "listas",
    resultado,
    consultas: demo.consultas.filter((c) => !resultado || c.resultado === resultado).slice(0, 40),
    total: demo.consultas.length,
    conteo: {
      coincidencia_parcial: demo.consultas.filter((c) => c.resultado === "coincidencia_parcial").length,
      coincidencia_exacta: demo.consultas.filter((c) => c.resultado === "coincidencia_exacta").length,
      sin_coincidencia: demo.consultas.filter((c) => c.resultado === "sin_coincidencia").length,
    },
  });
});

rutas.get("/diligencia/pep", (req, res) => {
  // Formularios donde se respondio "Si" a alguna pregunta de PEP
  const preguntasPep = ["pep_recursos_publicos", "pep_reconocimiento", "pep_poder_publico", "pep_servidor_publico", "pep_decreto_830", "pep_familiar"];
  const declarados = demo.formularios.filter((f) =>
    preguntasPep.some((codigo) => f.respuestas[codigo] && f.respuestas[codigo].booleano === true));
  // Personas vinculadas marcadas como PEP (socios, junta, beneficiarios)
  const vinculadas = demo.formularios.flatMap((f) =>
    f.personas.filter((p) => p.es_pep).map((p) => ({ ...p, tercero: f.tercero, formulario_id: f.formulario_id })));
  res.render("pep.html", { seccion: "pep", declarados, vinculadas, preguntasPep });
});

rutas.get("/diligencia/alertas", (req, res) => {
  res.render("alertas.html", { seccion: "alertas", alertas: demo.alertas });
});

rutas.get("/diligencia/alertas/:id", (req, res) => {
  const a = demo.alertas.find((x) => x.id === Number(req.params.id));
  if (!a) return res.status(404).render("no_encontrada.html");
  res.render("alerta.html", { seccion: "alertas", a });
});

rutas.get("/reportes", (req, res) => {
  const contarPor = (lista, campo) =>
    lista.reduce((cuenta, x) => ({ ...cuenta, [x[campo]]: (cuenta[x[campo]] || 0) + 1 }), {});
  res.render("reportes.html", {
    seccion: "reportes",
    total: demo.formularios.length,
    porEstado: contarPor(demo.formularios, "estado"),
    porRiesgo: contarPor(demo.terceros, "nivel_riesgo"),
    porResultado: contarPor(demo.consultas, "resultado"),
    totalTerceros: demo.terceros.length,
    totalConsultas: demo.consultas.length,
    vencimientos: demo.vencimientos,
  });
});

/* Ajustes */
rutas.get("/ajustes/preguntas", (req, res) => {
  const tipo = req.query.tipo === "natural" ? "natural" : "juridica";
  res.render("ajustes_preguntas.html", {
    seccion: "preguntas",
    tipo,
    cuestionario: demo.cuestionarios.find((c) => c.tipo_persona === tipo),
  });
});

rutas.get("/ajustes/usuarios", (req, res) => {
  res.render("ajustes_usuarios.html", { seccion: "usuarios", usuarios: demo.usuarios });
});

rutas.get("/ajustes/parametros", (req, res) => {
  res.render("ajustes_parametros.html", { seccion: "parametros", parametros: demo.parametros });
});

rutas.get("/ajustes/guia-estilo", (req, res) => {
  res.render("guia_estilo.html", { seccion: "guia", formularios: demo.formularios.slice(0, 5) });
});

module.exports = rutas;
