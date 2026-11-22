// Rutas del tercero: identificación y registro

const pool = require("../bd");
const express = require("express");
const router = express.Router();
const { digitoVerificacion } = require("../util/nit");

// Tipos de documento permitidos para persona natural
const DOCUMENTOS_NATURAL = ["CC", "CE", "PPT", "PA", "TI"];

// Relaciones permitidas (las mismas del ENUM de tercero_relaciones)
const RELACIONES = ["proveedor", "cliente", "empleado", "accionista", "otro"];

// Revisa tipo y número de documento. Devuelve el mensaje de error, o "" si está bien
function validarDocumento(tipo, documento, numero) {
    if (tipo === "natural" && !DOCUMENTOS_NATURAL.includes(documento)) {
        return "Tipo de documento no permitido para persona natural.";
    }
    // El pasaporte admite letras; los demás, solo números
    const patron = documento === "PA" ? /^[A-Z0-9]{5,12}$/ : /^[0-9]{5,12}$/;
    if (!patron.test(numero)) {
        return "Escriba el número sin puntos, guiones ni espacios (entre 5 y 12 caracteres).";
    }
    return "";
}

// Revisa todos los datos del registro. Devuelve el primer error que encuentre, o ""
function validarRegistro(tipo, documento, numero, datos, autoriza) {
    const errorDocumento = validarDocumento(tipo, documento, numero);
    if (errorDocumento) return errorDocumento;

    if (tipo === "juridica" && (!datos.razon_social || !datos.contacto_nombre)) {
        return "Escriba la razón social y el nombre de quien diligencia.";
    }
    if (tipo === "natural" && (!datos.nombres || !datos.apellidos)) {
        return "Escriba sus nombres y apellidos.";
    }
    if (!RELACIONES.includes(datos.relacion)) {
        return "Seleccione su relación con la entidad.";
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(datos.correo)) {
        return "Escriba un correo electrónico válido.";
    }
    if (!/^3[0-9]{9}$/.test(datos.celular)) {
        return "El celular debe tener 10 dígitos y empezar por 3.";
    }
    if (autoriza !== "si") {
        return "Debe autorizar el tratamiento de sus datos personales para continuar.";
    }
    return "";
}


// PASO 5: identificación del tercero
router.post("/acceso", async (req, res) => {
    const tipo = req.body.tipo === "natural" ? "natural" : "juridica";
    const documento = tipo === "juridica" ? "NIT" : req.body.documento;
    const numero = (req.body.numero || "").trim().toUpperCase();

    const error = validarDocumento(tipo, documento, numero);
    if (error) {
        return res.render("acceso.html", { error, tipo, documento, numero });
    }

    try {
        // ¿Ya está registrado?
        const [filas] = await pool.query(
            "SELECT id FROM terceros WHERE tipo_documento = ? AND numero_documento = ?",
            [documento, numero]
        );

        if (filas.length > 0) {
            // Ya existe: va a pedir el código de verificación (paso 7)
            return res.redirect(`/acceso/codigo?tipo=${tipo}`);
        }

        // Es nuevo: va al registro con sus datos ya escritos
        res.redirect(`/acceso/registro?tipo=${tipo}&documento=${documento}&numero=${numero}`);
    } catch (error) {
        console.error("Error en la identificación del tercero:", error);
        res.render("acceso.html", {
            error: "No pudimos verificar sus datos. Intente de nuevo.",
            tipo, documento, numero,
        });
    }
});


// PASO 6: registro del tercero nuevo
router.post("/acceso/registro", async (req, res) => {
    const tipo = req.body.tipo === "natural" ? "natural" : "juridica";
    const documento = tipo === "juridica" ? "NIT" : req.body.documento;
    const numero = (req.body.numero || "").trim().toUpperCase();

    // Leer un campo de texto sin espacios a los lados (vacío si no llegó)
    const texto = (campo) => (req.body[campo] || "").trim();

    const datos = {
        razon_social: texto("razon_social"),
        contacto_nombre: texto("contacto_nombre"),
        nombres: texto("nombres"),
        apellidos: texto("apellidos"),
        relacion: texto("relacion"),
        correo: texto("correo").toLowerCase(),
        celular: texto("celular"),
    };

    const error = validarRegistro(tipo, documento, numero, datos, req.body.autoriza);
    if (error) {
        return res.render("acceso_registro.html", { error, tipo, documento, numero, datos });
    }

    try {
        // ¿Ya existe? Pudo registrarse en otra pestaña mientras llenaba el formulario
        const [existentes] = await pool.query(
            "SELECT id FROM terceros WHERE tipo_documento = ? AND numero_documento = ?",
            [documento, numero]
        );
        if (existentes.length > 0) {
            return res.redirect(`/acceso/codigo?tipo=${tipo}`);
        }

        // Una sola conexión para toda la transacción
        const conexion = await pool.getConnection();
        try {
            await conexion.beginTransaction();

            // 1. El tercero
            const [resultado] = await conexion.query(
                `INSERT INTO terceros
                   (tipo_persona, tipo_documento, numero_documento, digito_verificacion,
                    razon_social, contacto_nombre, nombres, apellidos,
                    correo, celular, autorizacion_datos_en, autorizacion_datos_ip)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), ?)`,
                [
                    tipo, documento, numero,
                    tipo === "juridica" ? digitoVerificacion(numero) : null,
                    tipo === "juridica" ? datos.razon_social : null,
                    tipo === "juridica" ? datos.contacto_nombre : null,
                    tipo === "natural" ? datos.nombres : null,
                    tipo === "natural" ? datos.apellidos : null,
                    datos.correo, datos.celular, req.ip,
                ]
            );
            const terceroId = resultado.insertId;

            // 2. Su relación con la entidad
            await conexion.query(
                "INSERT INTO tercero_relaciones (tercero_id, relacion, desde) VALUES (?, ?, CURDATE())",
                [terceroId, datos.relacion]
            );

            // Todo salió bien: confirmar los dos INSERT
            await conexion.commit();

            req.session.terceroId = terceroId;   // lo usará el paso 7
            console.log(`Tercero registrado: ${documento} ${numero} (id ${terceroId})`);
            res.redirect(`/acceso/codigo?tipo=${tipo}`);

        } catch (errorBD) {
            // Algo falló: deshacer todo lo de esta transacción
            await conexion.rollback();
            throw errorBD;
        } finally {
            // Siempre devolver la conexión al pool
            conexion.release();
        }

    } catch (error) {
        // Dos registros del mismo documento al mismo tiempo: la base lo impide
        if (error.code === "ER_DUP_ENTRY") {
            return res.redirect(`/acceso/codigo?tipo=${tipo}`);
        }
        console.error("Error al registrar el tercero:", error);
        res.render("acceso_registro.html", {
            error: "No pudimos completar su registro. Intente de nuevo.",
            tipo, documento, numero, datos,
        });
    }
});

module.exports = router;