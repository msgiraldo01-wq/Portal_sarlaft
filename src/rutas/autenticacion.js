//Importar express y crear el router

const pool = require("../bd");
const bcrypt = require("bcryptjs");
const express = require("express");
const router = express.Router();

// Procesar el formulario de ingreso

router.post("/ingreso", async (req, res) => {
const usuario = (req.body.usuario || "").trim();
const clave = req.body.clave || "";

// validar que no este vacio

if (!usuario || !clave) {
    return res.render("ingreso.html",{
       error: "debe escribir el usuario y la clave.",
       usuarioEscrito: usuario, 
    });
}

try {
    // aqui iran los 4.

    // Buscar el usuario en la base de datos

    const [filas] = await pool.query("SELECT id, nombre, rol, clave_hash, activo  FROM usuarios WHERE usuario = ?", [usuario]);
    const encontrado = filas[0];

    // si no existe o esta desactivado: mismo mensaje, sin decir cual de la dos paso
    if (!encontrado || !encontrado.activo) {
        return res.render("ingreso.html", {
            error: "Usuario o clave incorrectos.",
            usuarioEscrito: usuario,
        });
    }

    // comparar la contraseña escrita con el hash guardado en la base

    const coincide = await bcrypt.compare(clave, encontrado.clave_hash);

    // si no coincide: el mismo mensaje, sin decir cual de las dos paso

    if (!coincide) {
        return res.render("ingreso.html", {
            error: "Usuario o clave incorrectos.",
            usuarioEscrito: usuario,
        });
    }   

    // registrar  la fecha y hora de ingreso en la base de datos

    await pool.query("UPDATE usuarios SET ultimo_ingreso_en = NOW() WHERE id = ?", [encontrado.id]);
    console.log(`Ingreso correcto: ${encontrado.nombre} (${encontrado.rol})`);

    // ir al inicio
    res.redirect("/inicio");
    
}   catch (error){

    // el detalle tecnico solo se ve en la terminal
    console.error("Error en el ingreso", error);

    // A la persona se le muestra un mensaje generico
    res.render("ingreso.html", {
        error: "Error al procesar el ingreso, intente nuevamente.",
        usuarioEscrito: usuario,
    });
}

})

module.exports = router;

