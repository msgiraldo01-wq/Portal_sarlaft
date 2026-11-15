/*
  Portal SARLAFT - arranque del servidor.

    npm install
    npm run dev        (se reinicia solo al guardar cambios)

  Abre en http://localhost:3000 (o el puerto de la variable PUERTO).
*/
const { crearApp } = require("./src/app");

const PUERTO = Number(process.env.PUERTO) || 3000;

crearApp().listen(PUERTO, () => {
  console.log(`Portal SARLAFT en http://localhost:${PUERTO}`);
});
