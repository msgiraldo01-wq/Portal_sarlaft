/*
  Rutas de las pantallas.

  Cada ruta hace lo mismo: toma los datos de ejemplo que necesita la
  pantalla y llama a res.render("vista.html", { datos }). No guarda ni
  valida nada: eso es la funcionalidad de los siguientes sprints.
*/
const express = require("express");
const demo = require("../datos_demo");
const rutas = express.Router();
const pool = require("../bd");

/* Nombre legible de cada rol (en la base se guarda el código) */
const ROLES = {
  administrador: "Administrador",
  oficial_cumplimiento: "Oficial de cumplimiento",
  analista: "Analista",
  auditor: "Auditor",
};

/* "Laura Restrepo" → "LR" */
function iniciales(nombre) {
  return nombre
    .split(" ")
    .filter((parte) => parte !== "")
    .slice(0, 2)
    .map((parte) => parte[0])
    .join("")
    .toUpperCase();
}

/* Variables que necesitan todas las vistas (menu, usuario, catalogos) */

rutas.use((req, res, next) => {

  const enSesion = req.session.usuario;
  res.locals.usuario = enSesion
    ? {
      nombre: enSesion.nombre,
      rol: ROLES[enSesion.rol] || enSesion.rol,
      iniciales: iniciales(enSesion.nombre),
    }
    : null;
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


/* De aquí hacia abajo, solo el equipo con sesión iniciada */
rutas.use((req, res, next) => {
  if (!req.session.usuario) {
    return res.redirect("/ingreso");
  }
  next();
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

/* Terceros por relación: /terceros/proveedores */
const RELACIONES = {
  clientes: ["cliente", "Clientes"],
  proveedores: ["proveedor", "Proveedores"],
  empleados: ["empleado", "Empleados"],
  accionistas: ["accionista", "Accionistas"],
};


/* Terceros de una relación, con el estado de su formulario más reciente */
const SQL_TERCEROS = `
  SELECT t.id, t.tipo_persona, t.nombre, t.correo, t.nivel_riesgo,
         CONCAT(t.tipo_documento, ' ', t.numero_documento,
                IF(t.digito_verificacion IS NULL, '', CONCAT('-', t.digito_verificacion))) AS documento,
         f.estado  AS ultimo_estado,
         f.periodo AS ultimo_periodo
  FROM terceros t
  JOIN tercero_relaciones r
       ON r.tercero_id = t.id AND r.relacion = ? AND r.activa = TRUE
  LEFT JOIN formularios f
       ON f.tercero_id = t.id
            AND f.periodo = (SELECT MAX(f2.periodo) FROM formularios f2 WHERE f2.tercero_id = t.id)`;;

            const NIVELES_RIESGO = ["bajo", "medio", "alto", "sin_calificar"];

            for (const [clave, [relacion, titulo]] of Object.entries(RELACIONES)) {
              rutas.get(`/terceros/${clave}`, async (req, res) => {
                // Filtros que llegan en la dirección: ?q=texto&riesgo=bajo
                const q = String(req.query.q || "").trim();
                const riesgo = NIVELES_RIESGO.includes(req.query.riesgo) ? req.query.riesgo : "";
            
                // Armar el WHERE solo con los filtros que se usaron
                let sql = SQL_TERCEROS;
                const parametros = [relacion];
                const condiciones = [];
            
                if (q) {
                  condiciones.push("(t.nombre LIKE ? OR t.numero_documento LIKE ?)");
                  parametros.push(`%${q}%`, `%${q}%`);
                }
                if (riesgo) {
                  condiciones.push("t.nivel_riesgo = ?");
                  parametros.push(riesgo);
                }
                if (condiciones.length > 0) {
                  sql += " WHERE " + condiciones.join(" AND ");
                }
                sql += " ORDER BY t.nombre";
            
                try {
                  const [terceros] = await pool.query(sql, parametros);
                  res.render("terceros.html", { seccion: clave, titulo, relacion, terceros, q, riesgo });
                } catch (error) {
                  console.error(`Error al listar ${clave}:`, error);
                  res.status(500).render("terceros.html", {
                    seccion: clave, titulo, relacion, terceros: [], q, riesgo,
                    error: "No se pudo cargar la lista. Intente de nuevo.",
                  });
                }
              });
            }

/* Ficha de un tercero: /terceros/ficha/12 */
rutas.get("/terceros/ficha/:id", async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(404).render("no_encontrada.html");
  }

  try {
    // 1. Datos del tercero y sus relaciones activas
    const [filas] = await pool.query(
      `SELECT t.id, t.tipo_persona, t.nombre, t.contacto_nombre, t.correo, t.celular,
              t.estado, t.nivel_riesgo, t.creado_en,
              CONCAT(t.tipo_documento, ' ', t.numero_documento,
                     IF(t.digito_verificacion IS NULL, '', CONCAT('-', t.digito_verificacion))) AS documento,
              GROUP_CONCAT(r.relacion ORDER BY r.relacion) AS relaciones
       FROM terceros t
       LEFT JOIN tercero_relaciones r ON r.tercero_id = t.id AND r.activa = TRUE
       WHERE t.id = ?
       GROUP BY t.id`,
      [id]
    );
    const t = filas[0];
    if (!t) {
      return res.status(404).render("no_encontrada.html");
    }
    // "proveedor,cliente" → ["proveedor", "cliente"]
    t.relaciones = t.relaciones ? t.relaciones.split(",") : [];

    // 2. Sus formularios, del más reciente al más antiguo, con el peor resultado en listas
    const [formularios] = await pool.query(
      `SELECT f.id AS formulario_id, f.periodo, f.tipo, f.radicado, f.estado, f.vence_en,
              COALESCE((SELECT c.resultado FROM consultas_listas c
                        WHERE c.formulario_id = f.id
                        ORDER BY c.resultado DESC LIMIT 1), 'por_consultar') AS listas
       FROM formularios f
       WHERE f.tercero_id = ?
       ORDER BY f.periodo DESC`,
      [id]
    );

    // 3. Sus alertas, la más reciente primero
    const [alertas] = await pool.query(
      "SELECT id, descripcion, severidad, estado, creada_en FROM alertas WHERE tercero_id = ? ORDER BY creada_en DESC",
      [id]
    );

    // 4. Vencimiento de su actualización (vista SQL del sprint 1)
    const [vencimientos] = await pool.query(
      "SELECT situacion, vence_en FROM v_vencimientos WHERE tercero_id = ?",
      [id]
    );

    res.render("tercero.html", {
      // Marca en el menú la lista a la que pertenece (proveedores, clientes...)
      seccion: Object.keys(RELACIONES).find((clave) => RELACIONES[clave][0] === t.relaciones[0]) || "",
      t,
      formularios,
      alertas,
      vencimiento: vencimientos[0],
    });

  } catch (error) {
    console.error("Error al abrir la ficha del tercero:", error);
    res.status(500).render("no_encontrada.html", {
      titulo_error: "No se pudo cargar la ficha",
      mensaje_error: "Intente de nuevo en unos minutos.",
    });
  }
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
