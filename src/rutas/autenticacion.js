//Importar express y crear el router

const express = require("express");
const router = express.Router();

// Procesar el formulario de ingreso

router.post("/ingreso", (req, res) => {
const usuario = (req.body.usuario || "").trim();
const clave = req.body.clave || "";

// validar que no este vacio

if (!usuario || !clave) {
    return res.render("ingreso.html",{
       error: "debe escribir el usuario y la clave.",
       usuarioEscrito: usuario, 
    });
}

 // Por ahora solo registra el intento y envía al inicio

 console.log("Intento de ingreso:", usuario);
 res.redirect("/");

})

module.exports = router;

