// Pool de conexiones

const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: process.env.DB_HOST || "localhost",
    port: Number(process.env.DB_PORT) || 3306,             // las variables de entorno llegan como texto
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    charset: 'utf8mb4',                             // soporte tildes, ñ y emojis
    dateStrings: true,   // fechas como texto "AAAA-MM-DD hh:mm:ss", sin convertir zonas horarias

    waitForConnections: true,                       // si no hay conexiones libres espera en vez de fallar
    connectionLimit: 10,                            // maximo de conexiones simultaneas
    queueLimit: 0,             // 0 = sin límite de solicitudes en espera

});

module.exports = pool;