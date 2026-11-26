/*
  Configuracion general del Portal SARLAFT.
  Lo que cambia entre ambientes (puerto, base de datos) ira en variables
  de entorno; aqui queda lo que es igual en todos.
*/

module.exports = {
  SISTEMA: "Portal SARLAFT",
  SUBTITULO: "Conocimiento de terceros",
  ENTIDAD: "Su entidad", // nombre que ven los terceros en el formulario

  // Cambiar este valor en cada despliegue obliga al navegador a bajar de
  
  VERSION_ESTATICOS: "2026.11.06-2",

  /*
    Imagen de las pantallas de ingreso y acceso (ruta dentro de publico/).
    Para cambiarla: copiar el archivo del disenador en publico/img/acceso/
    y ajustar estos valores. No hay que tocar ninguna plantilla.

      claro        imagen para tema claro (y oscuro si no hay otra)
      oscuro       opcional, imagen para tema oscuro
      areaUtil     fraccion del ANCHO de la imagen, desde la izquierda, que
                   no debe quedar tapada por la tarjeta del formulario
                   (0.68 = el 68 % izquierdo tiene el contenido importante)
      colorFondo   color que se ve mientras carga y en las franjas que
                   sobren; conviene tomarlo del borde de la imagen
      posicionMovil que parte de la imagen se ve en la franja del celular
  */
  IMAGEN_ACCESO: {
    claro: "img/acceso/portada.webp",
    oscuro: null,
    areaUtil: 0.68,
    colorFondo: "#022E66",
    posicionMovil: "right center",
  },
};
