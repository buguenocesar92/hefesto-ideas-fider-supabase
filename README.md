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

Si `DB_SSLMODE` no es `verify-full`, el certificado `certs/ca.crt` no es obligatorio y `ops/preflight.sh` no aborta por su ausencia.

Si `SMTP_READY=false`, el correo queda desactivado (`EMAIL=null`); no se requiere `EMAIL_SMTP_HOST` ni TLS implícito.

Las variables `SUPABASE_DEDICATED_CONFIRMED=true` y `SUPABASE_DATA_API_DISABLED=true` se mantienen como obligatorias: la base de esta app es dedicada y no expone PostgREST.
