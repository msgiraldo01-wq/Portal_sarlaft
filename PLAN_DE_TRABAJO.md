# Plan de trabajo · Lógica del Portal SARLAFT

Alcance acordado con el docente para esta etapa:

1. **Ingreso (login)** del equipo de cumplimiento.
2. **Registro de terceros**, en sus dos opciones: persona jurídica y persona natural.
3. **Pantalla de clientes** con datos reales de la base.

El resto de pantallas sigue mostrando datos de ejemplo (`src/datos_demo/`)
hasta que les llegue su turno.

## Forma de trabajo

- Un paso a la vez. Cada paso dice qué construir, cómo probarlo y qué
  concepto se aprende.
- El código lo escribo yo (el autor del proyecto). La guía explica y revisa;
  no entrega el código hecho.
- Al terminar cada paso: probarlo, anotarlo en la bitácora y guardar una
  versión (commit) con Git.

## Pasos

### Preparación
- [ ] **Paso 0.** Control de versiones con Git.
- [ ] **Paso 1.** Conectar Node.js con MySQL y comprobar la conexión.

### Ingreso del equipo
- [ ] **Paso 2.** Recibir los datos del formulario de ingreso en el servidor.
- [ ] **Paso 3.** Buscar el usuario en la base y comparar la contraseña cifrada (bcrypt).
- [ ] **Paso 4.** Recordar quién ingresó (sesión), proteger las pantallas internas y cerrar sesión.

### Registro de terceros
- [ ] **Paso 5.** Recibir y validar los datos de identificación y registro (incluye el dígito de verificación del NIT).
- [ ] **Paso 6.** Guardar el tercero y su relación con la entidad (transacción); evitar documentos duplicados.
- [ ] **Paso 7.** Código de verificación: generarlo, guardarlo cifrado y verificarlo.

### Clientes
- [ ] **Paso 8.** Consultar los terceros con relación «cliente» y mostrarlos en la pantalla.
- [ ] **Paso 9.** Buscar y filtrar clientes desde la pantalla.

### Cierre
- [ ] **Paso 10.** Registrar en la auditoría los ingresos y los registros.

## Bitácora

Anote aquí, con sus palabras, qué hizo en cada paso y qué aprendió.
Le sirve para sustentar.

| Fecha | Paso | Qué hice | Qué aprendí / qué me costó |
|---|---|---|---|
|  |  |  |  |
