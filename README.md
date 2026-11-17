# Sócrates · auditoría de respuesta a leads (IA → humano)

Extensión chica de Aristóteles. Pedido de Manu (Slack, 2-nov-2026): de los leads que la IA pasa a un humano, ver
1. la lista en un periodo,
2. si los contactaron en **menos de 24 h**,
3. si tuvieron **al menos un seguimiento dentro de 48 h**.

Primera cuenta: **Instituto Landa**. Siguiente: Green Hills (falta su token y sus etapas).

## Dónde está en vivo
- **URL:** https://digital-crew-socrates.xrzfaj.easypanel.host (EasyPanel, proyecto `digital-crew`, servicio `socrates`, sin contraseña por ser demo).
- **Cómo está desplegado:** EasyPanel construye el `Dockerfile` de este repo (público, rama `main`). Para actualizar: subir el cambio a `main` y pulsar **Desplegar** en el servicio (o pedírselo a Claude, que lo hace con el MCP de EasyPanel).

## Piezas
- `index.html`: página estática (sin build). Llama al webhook y aplica las reglas de 24 h y 48 h en el navegador, así se ajustan sin tocar el flujo.
  `?demo=1` muestra datos de ejemplo.
- `Dockerfile`: nginx:alpine. En EasyPanel, app desde este repo, puerto 80. Sin contraseña (demo).
- `flujo-n8n-socrates.json`: respaldo del flujo, **sin el token de Kommo** (reemplazar `TOKEN_DE_KOMMO` en el nodo `Config Sócrates` si se importa).
- Flujo vivo: instancia `digital-crew-n8n.xrzfaj.easypanel.host`, id `97N4XENSLmiUqPps`, webhook `POST /webhook/SOCRATES` con `{cuenta, desde, hasta}`.

## Cómo se decide qué es un lead de Sócrates
- **Delegado por la IA:** la primera vez que el lead entra a una etapa "delegada" dentro del periodo **y ese cambio lo hizo el sistema** (`created_by = 0`).
  Si lo movió una persona, no cuenta (se informa cuántos fueron).
- Etapas delegadas de Landa: Preparatoria › Delegado Instituto Landa y Delegado Infinity Learning; Infinity Learning IA › Delegado; Embudo de ventas › Interés.
- **Toque humano:** WhatsApp o llamada saliente, nota o tarea completada hecha por una persona (`created_by ≠ 0`) dentro de Kommo.
  Lo que se escribe fuera de Kommo no aparece. Los toques separados por menos de 60 min cuentan como uno (una ráfaga de mensajes no es un seguimiento).
- **Reglas (iteración del director, 17-nov):**
  - **Contacto ideal:** primer toque humano en **20 min o menos** (antes 24 h).
  - **Sin contacto pasadas 24 h:** ningún toque registrado en Kommo. Un lead contactado tarde NO entra aquí, aparece como «Tarde» en la tabla.
  - **Seguimiento:** al menos un toque más, después del primero, dentro de **48 h** desde la asignación.
  - **Cumple** = contacto ideal + seguimiento.
- **Horas hábiles:** los tres tiempos solo cuentan dentro del horario laboral de la cuenta. Landa: lunes a viernes de 9:00 a 18:00 (hora de México, UTC-6). Si la IA entrega un lead fuera de horario, el reloj arranca al abrir el siguiente día hábil.
- **Leads atendidos por la IA (tablero nuevo):** entrantes = leads creados en el periodo en los embudos de `embudos_entrantes` (Landa: Preparatoria, Infinity Learning IA, Embudo de ventas; sin «Inscritos años anteriores»), asignados = los que la IA pasó a un humano en el periodo, tasa = asignados / entrantes. Es una tasa de flujo: los asignados pueden haber entrado antes del periodo.
- **Colores:** rojo franco (no guinda). Los porcentajes usan semáforo: 80 % o más verde, 50-79 % ámbar, menos de 50 % rojo (supuesto, el director no dio umbrales). «Sin contacto pasadas 24 h» va en rojo si hay alguno.

## Limitaciones conocidas
- En el Kommo de Landa todo el equipo comparte **un solo usuario**, por eso "Por asesor" muestra una sola fila.
- "Sin contacto" significa **sin registro en Kommo**: si el equipo escribió desde otro WhatsApp fuera de Kommo, no se ve.
- El webhook es abierto (igual que los demás tableros en demo) y devuelve nombres de leads. Si se comparte fuera del equipo, protegerlo con una clave.
- Cada consulta tarda de ~7 s (una semana) a ~20 s (un mes) y hace de ~20 a ~50 peticiones a Kommo. Periodo máximo: 62 días.
- Pendiente (hablado con el director): distinguir mejor «no cumplió el parámetro pero ya se contactó» de «nunca se contactó»; hoy «Tarde» y «Sin contacto» ya van separados en la tabla.

## Agregar otra cuenta
En el nodo `Config Sócrates` agregar `cuentas.<clave>` con `subdominio`, `token`, `zona_horas`, `delegadas` (pipeline_id, status_id, nombre) y habilitar la opción en el selector de `index.html`.
Cada cliente tiene su horario (Green Hills sale a las 15-16 h, hay escuelas que trabajan de lunes a sábado): hay que preguntárselo y ponerlo en la cuenta:
- `horario: { ini: 9, fin: 18, dias: [1,2,3,4,5] }` (dias: 0 = domingo ... 6 = sábado; `ini`/`fin` aceptan decimales, 8.5 = 8:30)
- `reglas: { primer_contacto_min: 20, sin_contacto_horas: 24, seguimiento_horas: 48 }` (en horas hábiles)
- `embudos_entrantes: [ids de embudo]` (por omisión, los embudos de las etapas `delegadas`)
La página lee todo esto de la respuesta del flujo; no hay que tocar `index.html` para cambiar horario o reglas.
