/*
  Crea la aplicacion Express: motor de vistas, archivos estaticos y rutas.
*/
const path = require("path");
const express = require("express");
const { configurarVistas } = require("./vistas");

function crearApp() {
  const app = express();
  app.disable("x-powered-by");

  configurarVistas(app);

  // Archivos de publico/ (CSS, JS, imagenes) se sirven en /publico
  app.use("/publico", express.static(path.join(__dirname, "..", "publico")));

  // Pantallas
  app.use("/", require("./rutas/paginas"));

  // Direccion que no existe
  app.use((req, res) => {
    res.status(404).render("no_encontrada.html");
  });

  return app;
}

module.exports = { crearApp };
