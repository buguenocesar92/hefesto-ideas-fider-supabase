# Hefesto Ideas — Fider + Supabase
Portal de propuestas, votos, comentarios y seguimiento de mejoras para clientes de Hefesto. Kit de despliegue nativo Fider 0.38.2 con Docker Compose para Coolify/VPS.

## Incluye
- PostgreSQL 16/17 en Supabase exclusivo, rol propio y TLS verify-full.
- Alta privada mediante túnel y Mailpit: enlaces de acceso capturados sin envío externo.
- Producción con SMTP TLS, alta de nuevos portales desactivada y controles previos de portal/administrador activo.
- Archivos y adjuntos en almacenamiento SQL nativo; respaldo completo de public, restauración y traspaso.
- Guías comerciales, moderación y relación con Odoo.

Fider necesita correo para iniciar sesión. Mailpit sirve solo para pruebas. No hay credenciales ni SMTP real conectado; no se han enviado correos a terceros.

Empiece por docs/instalacion.md. Requiere Docker, Compose v2, Python 3.11+, dominio HTTPS, Supabase y proveedor SMTP con TLS implícito puerto 465 para producción.

**Estado:** kit revisado estáticamente, pendiente de ejecutar Docker, instalación, TLS, correo y recuperación reales. No es una instancia desplegada ni una certificación de compatibilidad en producción.

## Despliegue en Coolify (MVP Hefesto)

Coolify despliega este kit con build pack Docker Compose, detrás de Traefik (TLS y dominio automáticos).

Variables nuevas para compartir Postgres con otras apps en el mismo cluster:

- `DB_NAME` (por defecto `postgres`): nombre de la base. Coolify usa `mvp_<slug>` por aplicación.
- `DB_SSLMODE` (por defecto `verify-full`): modo SSL de libpq. Use `disable` para Postgres en la red interna sin TLS.
- `DB_SSLROOTCERT_QS` (opcional): sufijo extra del DSN para `sslrootcert`. Si `DB_SSLMODE` no es `verify-full`, defínalo vacío (`DB_SSLROOTCERT_QS=`) para que el DSN no exija el certificado (que está en `.gitignore` y no existe en el repo publicado).

Si `DB_SSLMODE` no es `verify-full`, el certificado `certs/ca.crt` no es obligatorio y `ops/preflight.sh` no aborta por su ausencia.

Si `SMTP_READY=false`, Fider arranca sin abortar pero el inicio de sesión por correo no funcionará hasta configurar `SMTP_READY=true` y un proveedor SMTP real con TLS implícito (puerto 465). `ops/start.sh` ya no fuerza `EMAIL` a un valor no verificado en Fider 0.38.2.

Las variables `SUPABASE_DEDICATED_CONFIRMED=true` y `SUPABASE_DATA_API_DISABLED=true` se mantienen como obligatorias: la base de esta app es dedicada y no expone PostgREST.

Pasos operativos del diagnóstico (no automatizados por el kit):

1. Crear la base `mvp_<slug>` en el Postgres compartido y correr `sql/01-supabase-app.sql` con un rol administrador para crear el rol `fider_app` (lo exige `ops/preflight.sql`).
2. Instalar la extensión `pg_trgm` en el esquema `extensions` con `CREATE EXTENSION pg_trgm WITH SCHEMA extensions` (lo exige `ops/preflight.sql`).
3. Asegurar PostgreSQL 16 o 17 (lo exige `ops/preflight.sql`).
4. Generar `DB_PASSWORD` en hexadecimal puro (lo exige `ops/start.sh`).
5. Antes del primer arranque productivo, ejecutar el bootstrap privado con `compose.bootstrap.yaml` para crear el administrador; sólo entonces poner `INITIAL_SETUP_COMPLETE=true` (lo exige `ops/production.sql`).
6. Sin SMTP configurado, el inicio de sesión por correo de Fider no funciona: defina un proveedor real con TLS implícito antes de habilitar invitaciones.
