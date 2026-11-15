/*
  Crea la aplicacion Express: motor de vistas, archivos estaticos y rutas.
*/
const path = require("path");
const express = require("express");
const { configurarVistas } = require("./vistas");
const pool = require("./bd");

function crearApp() {
  const app = express();
  app.disable("x-powered-by");

  configurarVistas(app);

  // Archivos de publico/ (CSS, JS, imagenes) se sirven en /publico
  app.use("/publico", express.static(path.join(__dirname, "..", "publico")));
  app.use(express.urlencoded({ extended: false }));
  app.use("/", require("./rutas/autenticacion"));

  // Pantallas
  app.use("/", require("./rutas/paginas"));

  // ruta de prueba verifica la conexion a la base de datos

  app.get("/api/salud", async (req, res) => {
    try {
      const [filas] = await pool.query("SELECT VERSION() AS version");
      res.json({
        estado: "base de datos conectada",
        version: filas[0].version,
      });
    } catch (error) {
      res.status(500).json({
        estado: "Error al conectar con la base de datos",
        error: error.message
      });
    }
  });

  // Direccion que no existe
  app.use((req, res) => {
    res.status(404).render("no_encontrada.html");
  });

  return app;
}

module.exports = { crearApp };


