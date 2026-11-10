# Sócrates · auditoría de respuesta a leads (IA → humano)

Extensión chica de Aristóteles. Pedido de Manu (Slack, 2-nov-2026): de los leads que la IA pasa a un humano, ver
1. la lista en un periodo,
2. si los contactaron en **menos de 24 h**,
3. si tuvieron **al menos un seguimiento dentro de 48 h**.

Primera cuenta: **Instituto Landa**. Siguiente: Green Hills (falta su token y sus etapas).

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
- **Seguimiento:** al menos un toque más, después del primero, dentro de 48 h desde la asignación. Horas corridas (24/7), no horario laboral.

## Limitaciones conocidas
- En el Kommo de Landa todo el equipo comparte **un solo usuario**, por eso "Por asesor" muestra una sola fila.
- "Sin contacto" significa **sin registro en Kommo**: si el equipo escribió desde otro WhatsApp fuera de Kommo, no se ve.
- El webhook es abierto (igual que los demás tableros en demo) y devuelve nombres de leads. Si se comparte fuera del equipo, protegerlo con una clave.
- Cada consulta tarda ~7 s y hace ~20 peticiones a Kommo. Periodo máximo: 62 días.

## Agregar otra cuenta
En el nodo `Config Sócrates` agregar `cuentas.<clave>` con `subdominio`, `token`, `zona_horas`, `delegadas` (pipeline_id, status_id, nombre) y habilitar la opción en el selector de `index.html`.
