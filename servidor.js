/*
  Abre en http://localhost:3000 (o el puerto de la variable PUERTO).
*/
// cargar el .env

const dotenv = require("dotenv");
dotenv.config();

const { crearApp } = require("./src/app");

const PUERTO = Number(process.env.PUERTO) || 3000;

crearApp().listen(PUERTO, () => {
  console.log(`Portal SARLAFT en http://localhost:${PUERTO}`);
});
