# Operación, respaldo y restauración
## Uso diario
Revisar propuestas, unir duplicados mediante las opciones nativas disponibles, responder y actualizar estados. Los votos orientan prioridad, no comprometen fechas. Mantener cuentas de administración limitadas y comprobar enlaces de acceso/notificaciones. No activar logs DEBUG en producción: pueden contener información de mensajes.

Los adjuntos y logos usan BLOB_STORAGE=sql en la tabla blobs; el respaldo PostgreSQL los incluye. No cambie a filesystem/S3 sin ampliar la estrategia de copia. El kit no utiliza Supabase Storage ni Auth, y no tiene volúmenes de negocio locales.

## Respaldo
`python3 scripts/backup.py` detiene app, hace pg_dump de public y guarda .env, Compose y manifiesto con hashes; reinicia si estaba activa. Impida otras instancias, CLI o escrituras simultáneas. La pausa interrumpe recepción de ideas y correos transaccionales. No se promete entrega exactamente una vez tras recuperar una copia antigua.

Guarde copias cifradas fuera del VPS. Incluyen correos de usuarios, contenido, tokens y secretos; hashes detectan daños, no sustituyen cifrado/autenticación. Solo un manifest completed indica copia completa. Configure retención, programación y alertas en el servidor; no se ha creado una tarea programada.

## Restauración en destino nuevo
1. Prepare otro proyecto Supabase vacío y rol/CA, incluida pg_trgm en extensions mediante el SQL administrativo. Use versión 0.38.2, app detenida, .env destino con host/clave DB nuevos y SMTP_READY=false.
2. Recupere JWT_SECRET original desde el respaldo por canal seguro. No copie ciegamente host ni credenciales SMTP antiguos.
3. `docker compose -f compose.yaml -f compose.bootstrap.yaml run --rm preflight`
4. `python3 scripts/restore_db.py /ruta/respaldo`
5. `docker compose -f compose.yaml -f compose.bootstrap.yaml up -d app`
6. Pruebe por túnel y Mailpit: acceso con correo existente, ideas, comentarios, votos y descarga de adjuntos. No cree otro portal; ya está restaurado.
7. Revise notificaciones/integraciones y visibilidad antes de configurar SMTP real, dominio y pasar a producción como en instalación. No mantener dos apps escribiendo en la misma base.

La restauración rechaza public con tablas. No borra ni fusiona instalaciones. Ante un fallo parcial, investigar y usar otro destino vacío; no eliminar el origen. Se respalda solo public, no todo Supabase. Conserve además ZIP, CA vigente, DNS/proxy y política operativa.

## Actualizaciones
Respaldar, probar versión nueva en clon con Mailpit y revisar migraciones. Fider ejecuta sus migraciones nativas al arrancar. No usar scripts de fixtures/desarrollo del repositorio upstream. Revertir imagen no revierte esquema: recuperar copia coherente en destino nuevo.

La imagen Fider y Mailpit están fijadas por digest; postgres:17-alpine recibe parches, registre su digest si necesita congelar las herramientas. Monitorice /app/fider ping, crecimiento de DB, copias y entrega SMTP. Defina RPO/RTO según pruebas reales.
