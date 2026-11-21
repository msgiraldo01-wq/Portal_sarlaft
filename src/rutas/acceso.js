//Rutas del tercero: identificacion y registros

const pool = require("../bd");
const express = require("express");
const router = express.Router();

//Tipos de documento permitido para persona natural

const DOCUMENTOS_NATURAL = ["CC", "CE", "PPT", "PA", "TI"];


router.post("/acceso", async (req, res) => {
    const tipo = req.body.tipo === "natural" ? "natural" : "juridica";
    const documento = tipo === "juridica" ? "NIT" : req.body.documento;
    const numero = (req.body.numero || "").trim().toUpperCase();

    /// Validar: el tipo de documento debe uno de la lista

    let error = "";
    if (tipo === "natural" && !DOCUMENTOS_NATURAL.includes(documento)) {
        error = "Tipo de documento no permitido para persona natural.";
    }
    // El pasaporte admite letras; los demas, solo numeros

    else if (documento === "PA" ? !/^[A-Z0-9]{5,12}$/.test(numero) : !/^[0-9]{5,12}$/.test(numero)) {
        error = "Escriba el número sin puntos, guiones ni espacios (entre 5 y 12 caracteres).";
    }
    if (error) {
        return res.render("acceso.html", {
            error,
            tipo,
            documento,
            numero,
        });
    }

    try {
        // Buscar el registro en la base de datos

        const [filas] = await pool.query(
            "SELECT id FROM terceros WHERE tipo_documento = ? AND numero_documento = ?",
            [documento, numero]
        );

        if (filas.length > 0) {
            // Ya existe: va a pedir el código de verificación (paso 7)
            return res.redirect(`/acceso/codigo?tipo=${tipo}`);
        }

        // Es nuevo: Va al registro con sus datos ya escritos

        res.redirect(`/acceso/registro?tipo=${tipo}&documento=${documento}&numero=${numero}`);
    } catch (error) {
        console.error("Error en la identificación del tercero:",error);
        res.render("acceso.html", {
            error: "No pudimos verificar sus datos. Intente de nuevo.",
            tipo, documento, numero,
        });
    }
});

module.exports = router;