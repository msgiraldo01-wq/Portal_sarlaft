/*
  Datos de ejemplo para las pantallas.

  Los archivos .json de la carpeta datos_demo/ se exportaron de la base
  de datos de prueba (bd/03_datos_prueba.sql), asi que las pantallas
  muestran lo mismo que hay en MySQL. Cuando las pantallas se conecten a
  la base, este archivo se reemplaza por consultas SQL.
*/
const catalogos = require("./datos_demo/catalogos.json");
const cuestionarios = require("./datos_demo/cuestionarios.json");
const terceros = require("./datos_demo/terceros.json");
const formularios = require("./datos_demo/formularios.json");
const consultas = require("./datos_demo/consultas.json");
const alertas = require("./datos_demo/alertas.json");
const vencimientos = require("./datos_demo/vencimientos.json");
const usuarios = require("./datos_demo/usuarios.json");
const parametros = require("./datos_demo/parametros.json");

// Usuario que "ingreso" en la demostracion
const usuarioActual = { nombre: "Laura Restrepo", rol: "Oficial de cumplimiento", iniciales: "LR" };

// Numeros del menu lateral
const contadores = {
  pendientes: formularios.filter((f) => f.estado === "borrador" || f.estado === "devuelto").length,
  revision: formularios.filter((f) => f.estado === "en_revision").length,
  alertas: alertas.filter((a) => a.estado === "abierta" || a.estado === "en_analisis").length,
};

module.exports = {
  catalogos, cuestionarios, terceros, formularios, consultas, alertas,
  vencimientos, usuarios, parametros, usuarioActual, contadores,
};
