/* =====================================================================
   PORTAL SARLAFT - base.js
   Comportamiento de la interfaz comun a todas las pantallas.
   JavaScript plano, sin librerias. No guarda ni valida datos: eso es
   logica de negocio y va en el servidor.

   1. Tema claro / oscuro
   2. Grupos plegables del menu (recuerda cuales dejo abiertos)
   3. Menu lateral en el celular
   4. Dialogos (ventanas modales)
   5. Lista de pasos del formulario en escritorio
   ===================================================================== */
(function () {
  "use strict";

  var raiz = document.documentElement;

  /* localStorage puede estar bloqueado (modo privado): si falla, se sigue */
  function leer(clave) {
    try { return localStorage.getItem(clave); } catch (e) { return null; }
  }
  function guardar(clave, valor) {
    try { localStorage.setItem(clave, valor); } catch (e) { /* sin memoria */ }
  }


  /* -------------------------------------------------------------------
     1. Tema claro / oscuro
     El script del <head> (_cabeza.html) ya aplico el tema guardado antes
     de pintar. Aqui solo se atiende el boton de luna/sol.
     ------------------------------------------------------------------- */
  var sistemaOscuro = window.matchMedia("(prefers-color-scheme: dark)");

  function temaActual() {
    var tema = raiz.getAttribute("data-tema");
    if (tema) return tema;
    return sistemaOscuro.matches ? "oscuro" : "claro";
  }

  document.querySelectorAll('[data-accion="tema"]').forEach(function (boton) {
    boton.addEventListener("click", function () {
      var nuevo = temaActual() === "oscuro" ? "claro" : "oscuro";
      raiz.setAttribute("data-tema", nuevo);
      guardar("sarlaft.tema", nuevo);
    });
  });


  /* -------------------------------------------------------------------
     2. Grupos plegables del menu
     Cada <details data-grupo="..."> recuerda si estaba abierto.
     El grupo de la pagina actual siempre se abre.
     ------------------------------------------------------------------- */
  var abiertos = {};
  try { abiertos = JSON.parse(leer("sarlaft.menu.grupos") || "{}"); } catch (e) { abiertos = {}; }

  document.querySelectorAll("details[data-grupo]").forEach(function (grupo) {
    var id = grupo.getAttribute("data-grupo");
    if (grupo.querySelector('[aria-current="page"]')) {
      grupo.open = true;
    } else if (id in abiertos) {
      grupo.open = abiertos[id];
    }
    grupo.addEventListener("toggle", function () {
      abiertos[id] = grupo.open;
      guardar("sarlaft.menu.grupos", JSON.stringify(abiertos));
    });
  });


  /* -------------------------------------------------------------------
     3. Menu lateral en el celular (pantallas de menos de 760 px)
     El boton "Menu" lo abre; se cierra con Esc, con el fondo oscuro o
     con la X.
     ------------------------------------------------------------------- */
  var menu = document.getElementById("menu-lateral");
  var botonMenu = document.querySelector('[data-accion="menu"]');
  var velo = document.querySelector(".fondo-menu");

  function abrirMenu() {
    menu.classList.add("abierto");
    botonMenu.setAttribute("aria-expanded", "true");
    velo.hidden = false;
    document.body.classList.add("menu-abierto");
  }

  function cerrarMenu() {
    menu.classList.remove("abierto");
    botonMenu.setAttribute("aria-expanded", "false");
    velo.hidden = true;
    document.body.classList.remove("menu-abierto");
    botonMenu.focus();
  }

  if (menu && botonMenu && velo) {
    botonMenu.addEventListener("click", abrirMenu);
    velo.addEventListener("click", cerrarMenu);
    menu.querySelectorAll('[data-accion="cerrar-menu"]').forEach(function (b) {
      b.addEventListener("click", cerrarMenu);
    });
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape" && menu.classList.contains("abierto")) cerrarMenu();
    });
  }


  /* -------------------------------------------------------------------
     4. Dialogos
     <button data-abrir-dialogo="id-del-dialogo">  abre un <dialog>
     <button data-cerrar-dialogo>                  cierra el que lo contiene
     Un <form method="dialog"> dentro del dialogo tambien lo cierra al
     enviarse (comportamiento propio del navegador). Esc lo cierra.
     ------------------------------------------------------------------- */
  document.addEventListener("click", function (e) {
    var abrir = e.target.closest("[data-abrir-dialogo]");
    if (abrir) {
      var dialogo = document.getElementById(abrir.getAttribute("data-abrir-dialogo"));
      if (dialogo) dialogo.showModal();
      return;
    }
    var cerrar = e.target.closest("[data-cerrar-dialogo]");
    if (cerrar) cerrar.closest("dialog").close();
  });


  /* -------------------------------------------------------------------
     5. Lista de pasos del formulario
     En el celular es un plegable; en escritorio siempre va abierta.
     ------------------------------------------------------------------- */
  var escritorio = window.matchMedia("(min-width: 901px)");
  function abrirPasos() {
    if (!escritorio.matches) return;
    document.querySelectorAll("details.pasos-plegable").forEach(function (d) { d.open = true; });
  }
  abrirPasos();
  escritorio.addEventListener("change", abrirPasos);
})();
