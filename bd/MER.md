# Modelo entidad-relación · Portal SARLAFT

Sprint 1 · Base de datos. Motor: **MySQL 8.0** (InnoDB, `utf8mb4`, intercalación
`utf8mb4_es_0900_ai_ci`: no distingue mayúsculas ni tildes al buscar, pero sí la ñ).

**31 tablas · 54 llaves foráneas · 3 vistas · 5 disparadores**, en cinco áreas.
Probado en MySQL 8.0.46: estructura, datos de prueba y 17 reglas de integridad (que la base rechace lo que debe rechazar).

| Archivo | Qué hace |
|---|---|
| `00_reiniciar_desarrollo.sql` | Borra la base completa. Solo en desarrollo |
| `01_esquema.sql` | Crea la base, las tablas, las restricciones, los disparadores y las vistas |
| `02_catalogos.sql` | Catálogos, parámetros y la versión 1 de los dos cuestionarios |
| `03_datos_prueba.sql` | Datos ficticios: los mismos terceros que muestra la pantalla de inicio |
| `04_usuario_aplicacion.sql` | Crea el usuario de MySQL de la aplicación, sin permisos para alterar tablas |
| `mer/*.png`, `mer/*.svg` | Los diagramas de este documento como imagen |

## Cómo leer los diagramas

Notación de pata de gallo (Crow's foot):

| Símbolo en el extremo | Significa |
|---|---|
| `||` | exactamente uno |
| `o|` | cero o uno |
| `|{` | uno o muchos |
| `o{` | cero o muchos |
| línea punteada | relación lógica sin llave foránea |

En cada entidad: **PK** llave primaria, **FK** llave foránea, **UK** forma parte de
una restricción de unicidad. En los diagramas por área, las tablas que pertenecen
a otra área aparecen solo con sus llaves.

## Decisiones de diseño

1. **Modelo híbrido: datos estructurados + preguntas parametrizables.**
   Lo que se cruza, se calcula o se reporta tiene columnas propias con su tipo y
   sus llaves: ubicación, actividad CIIU, cifras financieras y todas las personas
   (representantes, accionistas, junta, beneficiarios finales, familiares PEP).
   Lo que la norma cambia con frecuencia (preguntas PEP, operaciones
   internacionales, activos virtuales, origen de fondos, declaraciones) vive en
   `preguntas` y `respuestas`. Así un cambio normativo se resuelve desde
   *Ajustes*, sin tocar código, y las cifras y personas se pueden consultar con
   SQL normal.

2. **Cuestionarios versionados.** Cada formulario guarda qué versión del
   cuestionario respondió (`formularios.cuestionario_id`). Cuando cambie la norma
   se publica una versión nueva; los formularios viejos conservan sus preguntas.
   Solo puede haber una versión publicada por tipo de persona (lo garantiza una
   columna calculada con índice único).

3. **Un formulario por tercero y periodo** (`UNIQUE tercero_id, periodo`). Los
   datos generales y financieros cuelgan del formulario, no del tercero: son lo
   que se declaró *en ese periodo* y sirven como evidencia aunque después cambien.

4. **Una sola tabla para todas las personas** (`personas_vinculadas`, con `rol`).
   Así una cédula se busca en un solo lugar para cruzarla con listas
   restrictivas, sin importar si aparece como accionista, representante o
   familiar. Las columnas que solo aplican a un rol aceptan nulos, y las reglas
   clave se validan con `CHECK` (participación entre 0 y 100, parentesco
   obligatorio para familiares, correo obligatorio para el firmante).

5. **Trazabilidad.** El historial de estados del formulario lo llena un
   disparador (la aplicación indica quién hizo el cambio con `SET @usuario_id`).
   La `auditoria` no admite `UPDATE` ni `DELETE`. Las consultas en listas copian
   el nombre y el documento consultados, para que la evidencia no cambie si la
   persona se corrige después.

6. **Seguridad y datos personales.** Contraseñas con bcrypt; códigos de un solo
   uso guardados como huella SHA-256, nunca en claro. Los PDF de soporte no van
   dentro de la base: se guarda la ruta, el tamaño y la huella SHA-256 para
   probar que el archivo no cambió. Las alertas y el número de ROS ante la UIAF
   son reservados: ninguna pantalla del tercero los consulta.

7. **Integridad en la base, no solo en la aplicación.** Además de las llaves
   foráneas: un tercero jurídico debe tener razón social y NIT con dígito de
   verificación; un formulario enviado debe tener radicado; uno aprobado o
   rechazado debe tener revisor y ya no cambia de estado; una alerta cerrada debe
   tener decisión; si el país es Colombia, el municipio es obligatorio.

### Normalización

El modelo está en tercera forma normal, con tres excepciones deliberadas:

- `terceros.nombre` es una columna **calculada** (razón social o nombres +
  apellidos) para buscar y ordenar rápido. La calcula MySQL; no se puede
  desincronizar.
- `consultas_listas.nombre_consultado` y `documento_consultado` repiten datos de
  la persona a propósito: son una fotografía de lo que se consultó (evidencia).
- `formulario_datos_generales` repite por periodo datos que podrían ser del
  tercero: es la declaración de ese año, no la ficha actual.

## Estados del formulario

| Desde | Acción | Hacia | Quién |
|---|---|---|---|
| (nuevo) | crear | `borrador` | tercero |
| `borrador` | firmar y enviar | `en_revision` | tercero |
| `en_revision` | devolver para corregir | `devuelto` | equipo |
| `devuelto` | corregir y reenviar | `en_revision` | tercero |
| `en_revision` | aprobar | `aprobado` | equipo |
| `en_revision` | rechazar | `rechazado` | equipo |

`aprobado` y `rechazado` son finales. Al aprobar se calcula `vence_en`
(hoy + `periodicidad_actualizacion_meses`); la vista `v_vencimientos` dice quién
está vigente, por vencer o vencido.


## Vista general

Núcleo del modelo, sin catálogos ni usuarios (están en los diagramas por área).

![Vista general](mer/0_general.png)

## 1. Personas y acceso

Quién entra al sistema. El equipo interno entra con usuario y contraseña (`usuarios`); los terceros, con su documento y un código de un solo uso (`codigos_verificacion`). Un tercero puede tener varias relaciones con la entidad a la vez.

![Personas y acceso](mer/1_acceso.png)

| Tabla | Columnas | Para qué sirve |
|---|---|---|
| `tipos_documento` | 4 | Tipos de documento de identidad aceptados |
| `usuarios` | 12 | Equipo interno: oficial de cumplimiento, analistas, auditores |
| `parametros` | 6 | Parametros editables desde Ajustes (periodicidad, tamanos, tiempos) |
| `terceros` | 18 | Proveedores, clientes, empleados, accionistas: quien diligencia el formulario |
| `tercero_relaciones` | 4 | Un tercero puede ser a la vez proveedor y cliente, etc. |
| `codigos_verificacion` | 10 | Codigos de un solo uso para entrar y para firmar |
| `invitaciones` | 11 | Enlaces que el equipo envia para que un tercero diligencie |

<details><summary>Código Mermaid del diagrama</summary>

```mermaid
erDiagram
  tipos_documento {
    varchar codigo PK
  }
  usuarios {
    int id PK
    varchar usuario UK
    varchar nombre
    varchar correo UK
    varchar clave_hash
    enum rol
    int activo
    int intentos_fallidos
    datetime bloqueado_hasta
    datetime ultimo_ingreso_en
    datetime creado_en
    datetime actualizado_en
  }
  parametros {
    varchar clave PK
    varchar valor
    enum tipo
    varchar descripcion
    int actualizado_por FK
    datetime actualizado_en
  }
  terceros {
    int id PK
    enum tipo_persona
    varchar tipo_documento FK, UK
    varchar numero_documento UK
    int digito_verificacion
    varchar razon_social
    varchar nombres
    varchar apellidos
    varchar nombre "calculado"
    varchar contacto_nombre
    varchar correo
    varchar celular
    datetime autorizacion_datos_en
    varchar autorizacion_datos_ip
    enum estado
    enum nivel_riesgo
    datetime creado_en
    datetime actualizado_en
  }
  tercero_relaciones {
    int tercero_id PK, FK
    enum relacion PK
    date desde
    int activa
  }
  codigos_verificacion {
    int id PK
    int tercero_id FK
    enum proposito
    char codigo_hash
    set canales
    datetime creado_en
    datetime vence_en
    int intentos
    datetime usado_en
    varchar ip
  }
  invitaciones {
    int id PK
    varchar tipo_documento FK
    varchar numero_documento
    varchar correo
    enum relacion
    char token_hash UK
    int enviada_por FK
    datetime enviada_en
    datetime vence_en
    datetime usada_en
    int tercero_id FK
  }
  tipos_documento ||--o{ terceros : "identifica"
  usuarios |o--o{ parametros : "actualiza"
  terceros ||--o{ tercero_relaciones : "tiene"
  terceros ||--o{ codigos_verificacion : "recibe"
  tipos_documento ||--o{ invitaciones : "identifica"
  usuarios ||--o{ invitaciones : "envia"
  terceros |o--o{ invitaciones : "acepta"
```

</details>

## 2. Cuestionario parametrizable

Lo que se le pregunta al tercero. Un cuestionario tiene módulos (los pasos del formulario); cada módulo tiene preguntas parametrizables y secciones fijas (bloques de datos estructurados, como la información financiera o la lista de accionistas). Una pregunta o sección puede depender de la respuesta a otra (`depende_de_pregunta_id` + `depende_de_valor`).

![Cuestionario parametrizable](mer/2_cuestionario.png)

| Tabla | Columnas | Para qué sirve |
|---|---|---|
| `cuestionarios` | 10 | Versiones del formulario SARLAFT, una por tipo de persona |
| `modulos` | 5 | Pasos del formulario (Identificacion, PEP, Informacion financiera...) |
| `preguntas` | 13 | Preguntas de cada modulo |
| `pregunta_opciones` | 9 | Opciones de las preguntas de seleccion y multiples |
| `modulo_secciones` | 10 | Bloques fijos (datos generales, financiero, listas de personas) dentro de un modulo |

<details><summary>Código Mermaid del diagrama</summary>

```mermaid
erDiagram
  usuarios {
    int id PK
    varchar usuario UK
    varchar correo UK
  }
  cuestionarios {
    int id PK
    varchar nombre
    enum tipo_persona UK
    int version UK
    enum estado
    datetime publicado_en
    text notas
    int creado_por FK
    datetime creado_en
    enum publicado_tipo UK "calculado"
  }
  modulos {
    int id PK
    int cuestionario_id FK, UK
    int orden UK
    varchar nombre
    text descripcion
  }
  preguntas {
    int id PK
    int modulo_id FK, UK
    int orden
    varchar codigo UK
    text enunciado
    text ayuda
    enum tipo
    int obligatoria
    set relaciones
    int depende_de_pregunta_id FK
    varchar depende_de_valor
    varchar alerta_si_valor
    int activa
  }
  pregunta_opciones {
    int id PK
    int pregunta_id FK, UK
    int orden
    varchar valor UK
    varchar etiqueta
    int pide_detalle
    int excluyente
    int genera_alerta
    int activa
  }
  modulo_secciones {
    int id PK
    int modulo_id FK, UK
    int orden
    enum componente UK
    varchar titulo
    text instrucciones
    int obligatoria
    int minimo_filas
    int depende_de_pregunta_id FK
    varchar depende_de_valor
  }
  usuarios |o--o{ cuestionarios : "crea"
  cuestionarios ||--|{ modulos : "agrupa"
  modulos ||--o{ preguntas : "contiene"
  preguntas |o--o{ preguntas : "depende de"
  preguntas ||--o{ pregunta_opciones : "ofrece"
  modulos ||--o{ modulo_secciones : "muestra"
  preguntas |o--o{ modulo_secciones : "condiciona"
```

</details>

## 3. Formulario

Lo que diligencia el tercero cada periodo: sus respuestas, su avance por paso, sus documentos y la firma con código. `formulario_estados` es el historial de revisión.

![Formulario](mer/3_formulario.png)

| Tabla | Columnas | Para qué sirve |
|---|---|---|
| `formularios` | 17 | Formulario SARLAFT de un tercero en un periodo |
| `formulario_estados` | 7 | Historial de cambios de estado (lo llena un disparador) |
| `formulario_modulos` | 4 | Avance por paso: lo que pinta la barra de pasos |
| `respuestas` | 8 | Respuesta a cada pregunta parametrizable. Las de seleccion guardan sus opciones en respuesta_opciones |
| `respuesta_opciones` | 3 | Opciones marcadas en preguntas de seleccion y multiples |
| `soportes` | 14 | Documentos adjuntos (RUT, camara de comercio, cedulas, estados financieros) |

<details><summary>Código Mermaid del diagrama</summary>

```mermaid
erDiagram
  terceros {
    int id PK
    varchar tipo_documento FK, UK
    varchar numero_documento UK
  }
  cuestionarios {
    int id PK
    enum tipo_persona UK
    int version UK
    int creado_por FK
  }
  modulos {
    int id PK
    int cuestionario_id FK, UK
    int orden UK
  }
  preguntas {
    int id PK
    int modulo_id FK, UK
    varchar codigo UK
    int depende_de_pregunta_id FK
  }
  pregunta_opciones {
    int id PK
    int pregunta_id FK, UK
    varchar valor UK
  }
  codigos_verificacion {
    int id PK
    int tercero_id FK
  }
  usuarios {
    int id PK
    varchar usuario UK
    varchar correo UK
  }
  formularios {
    int id PK
    int tercero_id FK, UK
    int cuestionario_id FK
    enum tipo
    year periodo UK
    enum estado
    varchar radicado UK
    datetime creado_en
    datetime actualizado_en
    datetime enviado_en
    int firma_codigo_id FK
    varchar firma_ip
    int revisado_por FK
    datetime revisado_en
    text observacion_revision
    date vence_en
    enum nivel_riesgo
  }
  formulario_estados {
    int id PK
    int formulario_id FK
    enum estado_anterior
    enum estado_nuevo
    int usuario_id FK
    text observacion
    datetime ocurrido_en
  }
  formulario_modulos {
    int formulario_id PK, FK
    int modulo_id PK, FK
    enum estado
    datetime actualizado_en
  }
  respuestas {
    int id PK
    int formulario_id FK, UK
    int pregunta_id FK, UK
    text valor_texto
    decimal valor_numero
    date valor_fecha
    int valor_booleano
    datetime actualizado_en
  }
  respuesta_opciones {
    int respuesta_id PK, FK
    int opcion_id PK, FK
    varchar detalle
  }
  soportes {
    int id PK
    int formulario_id FK
    int tipo_soporte_id FK
    varchar nombre_original
    varchar ruta_archivo UK
    varchar tipo_mime
    int tamano_bytes
    char sha256
    date fecha_expedicion
    enum estado
    varchar observacion
    datetime cargado_en
    int revisado_por FK
    datetime revisado_en
  }
  tipos_soporte {
    int id PK
    varchar codigo UK
  }
  terceros ||--o{ codigos_verificacion : "recibe"
  usuarios |o--o{ cuestionarios : "crea"
  cuestionarios ||--|{ modulos : "agrupa"
  modulos ||--o{ preguntas : "contiene"
  preguntas |o--o{ preguntas : "depende de"
  preguntas ||--o{ pregunta_opciones : "ofrece"
  terceros ||--o{ formularios : "diligencia"
  cuestionarios ||--o{ formularios : "version usada"
  codigos_verificacion |o--o| formularios : "firma"
  usuarios |o--o{ formularios : "revisa"
  formularios ||--|{ formulario_estados : "historial"
  usuarios |o--o{ formulario_estados : "cambia"
  formularios ||--o{ formulario_modulos : "avance"
  modulos ||--o{ formulario_modulos : "avance de"
  formularios ||--o{ respuestas : "contiene"
  preguntas ||--o{ respuestas : "responde"
  respuestas ||--o{ respuesta_opciones : "marca"
  pregunta_opciones ||--o{ respuesta_opciones : "elegida"
  formularios ||--o{ soportes : "adjunta"
  tipos_soporte ||--o{ soportes : "clasifica"
  usuarios |o--o{ soportes : "revisa"
```

</details>

## 4. Datos declarados

Los datos estructurados del formulario y los catálogos oficiales en que se apoyan (DANE, ISO 3166, CIIU).

![Datos declarados](mer/4_datos_declarados.png)

| Tabla | Columnas | Para qué sirve |
|---|---|---|
| `formulario_datos_generales` | 18 | Ubicacion, actividad economica y datos basicos declarados (1 a 1 con formulario) |
| `formulario_financiero` | 11 | Informacion financiera declarada (1 a 1 con formulario) |
| `personas_vinculadas` | 23 | Todas las personas que aparecen en el formulario: representantes, socios, junta, beneficiarios, familiares |
| `actividades_ciiu` | 3 | Actividades economicas CIIU |
| `paises` | 3 | Paises |
| `departamentos` | 2 | Departamentos de Colombia |
| `municipios` | 3 | Municipios de Colombia |
| `parentescos` | 4 | Parentescos para familiares de PEP y de directivos |

<details><summary>Código Mermaid del diagrama</summary>

```mermaid
erDiagram
  formularios {
    int id PK
    int tercero_id FK, UK
    int cuestionario_id FK
    year periodo UK
  }
  formulario_datos_generales {
    int formulario_id PK, FK
    enum forma_juridica
    enum naturaleza
    date fecha_nacimiento
    char municipio_nacimiento FK
    char pais_nacimiento FK
    char nacionalidad FK
    varchar ocupacion
    varchar empresa_donde_trabaja
    varchar cargo
    char actividad_ciiu FK
    char pais FK
    char municipio FK
    varchar ciudad_exterior
    varchar direccion
    varchar telefono
    varchar sitio_web
    datetime actualizado_en
  }
  formulario_financiero {
    int formulario_id PK, FK
    date fecha_corte
    char moneda
    decimal activos
    decimal pasivos
    decimal patrimonio
    decimal ingresos_anuales
    decimal otros_ingresos
    varchar concepto_otros_ingresos
    decimal egresos_anuales
    datetime actualizado_en
  }
  personas_vinculadas {
    int id PK
    int formulario_id FK
    enum rol
    int orden
    enum tipo_persona
    varchar nombre_completo
    varchar tipo_documento FK
    varchar numero_documento
    char pais_documento FK
    varchar correo
    varchar celular
    varchar cargo
    decimal participacion
    int es_pep
    int parentesco_id FK
    date fecha_nacimiento
    char municipio_nacimiento FK
    char municipio_residencia FK
    varchar direccion
    varchar telefono
    varchar ocupacion
    datetime creado_en
    datetime actualizado_en
  }
  actividades_ciiu {
    char codigo PK
  }
  paises {
    char codigo PK
    varchar nombre UK
  }
  departamentos {
    char codigo PK
  }
  municipios {
    char codigo PK
    char departamento_codigo FK
  }
  parentescos {
    int id PK
    varchar nombre UK
  }
  tipos_documento {
    varchar codigo PK
  }
  departamentos ||--|{ municipios : "contiene"
  formularios ||--o| formulario_datos_generales : "declara"
  actividades_ciiu ||--o{ formulario_datos_generales : "actividad"
  paises ||--o{ formulario_datos_generales : "ubicacion"
  municipios |o--o{ formulario_datos_generales : "ubicacion"
  formularios ||--o| formulario_financiero : "declara"
  formularios ||--o{ personas_vinculadas : "relaciona"
  tipos_documento |o--o{ personas_vinculadas : "identifica"
  paises |o--o{ personas_vinculadas : "expide"
  parentescos |o--o{ personas_vinculadas : "parentesco"
  municipios |o--o{ personas_vinculadas : "nacimiento y residencia"
```

</details>

## 5. Control: listas, alertas y auditoria

El trabajo del oficial de cumplimiento: consultas en listas del tercero y de sus personas vinculadas, señales de alerta con su análisis y decisión, y la bitácora de todo lo que pasa en el sistema.

![Control: listas, alertas y auditoria](mer/5_control.png)

| Tabla | Columnas | Para qué sirve |
|---|---|---|
| `listas_restrictivas` | 6 | Listas restrictivas y de control que se consultan |
| `consultas_listas` | 13 | Cada consulta en listas restrictivas, del tercero o de sus personas vinculadas |
| `alertas` | 14 | Senales de alerta y su analisis. NUNCA visibles para el tercero (reserva del ROS) |
| `auditoria` | 11 | Bitacora de solo escritura: no admite UPDATE ni DELETE |

<details><summary>Código Mermaid del diagrama</summary>

```mermaid
erDiagram
  terceros {
    int id PK
    varchar tipo_documento FK, UK
    varchar numero_documento UK
  }
  formularios {
    int id PK
    int tercero_id FK, UK
    int cuestionario_id FK
    year periodo UK
  }
  personas_vinculadas {
    int id PK
    int formulario_id FK
    varchar tipo_documento FK
    char pais_documento FK
  }
  usuarios {
    int id PK
    varchar usuario UK
    varchar correo UK
  }
  listas_restrictivas {
    int id PK
    varchar codigo UK
  }
  consultas_listas {
    int id PK
    int tercero_id FK
    int formulario_id FK
    int persona_vinculada_id FK
    int lista_id FK
    varchar nombre_consultado
    varchar documento_consultado
    enum resultado
    text detalle
    enum origen
    int consultado_por FK
    datetime consultado_en
    varchar evidencia_ruta
  }
  alertas {
    int id PK
    int tercero_id FK
    int formulario_id FK
    int consulta_lista_id FK
    enum origen
    enum severidad
    text descripcion
    enum estado
    int asignada_a FK
    text decision
    varchar numero_ros
    datetime creada_en
    int cerrada_por FK
    datetime cerrada_en
  }
  auditoria {
    int id PK
    datetime ocurrido_en
    enum actor
    int usuario_id
    int tercero_id
    varchar accion
    varchar entidad
    varchar entidad_id
    json detalle
    varchar ip
    varchar agente
  }
  terceros ||--o{ formularios : "diligencia"
  usuarios |o--o{ formularios : "revisa"
  formularios ||--o{ personas_vinculadas : "relaciona"
  listas_restrictivas ||--o{ consultas_listas : "en"
  terceros |o--o{ consultas_listas : "consultado"
  formularios |o--o{ consultas_listas : "origina"
  personas_vinculadas |o--o{ consultas_listas : "consultada"
  usuarios |o--o{ consultas_listas : "consulta"
  terceros ||--o{ alertas : "genera"
  formularios |o--o{ alertas : "origina"
  consultas_listas |o--o{ alertas : "origina"
  usuarios |o--o{ alertas : "analiza y cierra"
  usuarios |o..o{ auditoria : "registra (sin FK)"
  terceros |o..o{ auditoria : "registra (sin FK)"
```

</details>

## Vistas

| Vista | Para qué |
|---|---|
| `v_bandeja_formularios` | Bandeja del equipo: formulario, tercero, documento, relaciones, estado, peor resultado en listas y alertas abiertas |
| `v_vencimientos` | Último formulario aprobado de cada tercero, días que le quedan y si está vigente, por vencer o vencido |
| `v_avance_formularios` | Pasos completos, con error y porcentaje de avance de cada formulario |

## Disparadores

| Disparador | Qué hace |
|---|---|
| `tr_formularios_historial_alta` y `_cambio` | Registran en `formulario_estados` cada cambio de estado, con el usuario de `@usuario_id` |
| `tr_formularios_cerrado` | Impide cambiar el estado de un formulario aprobado o rechazado |
| `tr_auditoria_sin_cambios` y `_sin_borrado` | La auditoría no se modifica ni se borra |

El detalle de cada columna está en los comentarios de `01_esquema.sql`; en MySQL
Workbench se ven en la pestaña de cada tabla, o con
`SHOW FULL COLUMNS FROM nombre_tabla;`.
