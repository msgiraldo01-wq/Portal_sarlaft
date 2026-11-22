/*
  Dígito de verificación del NIT, con el algoritmo de la DIAN.
  Recibe el NIT sin DV (texto de solo dígitos) y devuelve un número de 0 a 9.
*/

const e = require("express");

const pesos = [3, 7, 13, 17, 19, 23, 29, 37, 41, 43, 47, 53, 59, 67, 71];

function digitoVerificacion(nit) {
  const digitos = String(nit).split("").reverse();
  let suma = 0;
  for (let i = 0; i < digitos.length; i++) {
      suma += Number(digitos[i]) * pesos[i];
  }
  const residuo = suma % 11;
  return residuo > 1 ? 11 - residuo : residuo;
}

module.exports = { digitoVerificacion };

