#!/bin/sh
set -eu
cd /app
case "${HEFESTO_DB_HOST:-}" in ''|*[!a-zA-Z0-9.-]*) echo 'Host DB invalido'; exit 1;; esac
case "${HEFESTO_DB_USER:-}" in ''|*[!a-zA-Z0-9_.-]*) echo 'Usuario DB invalido'; exit 1;; esac
case "${HEFESTO_DB_PASSWORD:-}" in ''|*[!0-9a-f]*) echo 'Mantener DB_PASSWORD hexadecimal generado'; exit 1;; esac
if [ "${HEFESTO_BOOTSTRAP:-false}" != true ]; then
  [ "${INITIAL_SETUP_COMPLETE:-false}" = true ] || { echo 'Falta completar alta privada del portal'; exit 1; }
  case "${SMTP_READY:-false}" in
    true)
      case "$EMAIL_SMTP_HOST" in mailpit|smtp.example.com|'') echo 'Configurar proveedor SMTP real'; exit 1;; esac
      [ "$EMAIL_SMTP_ENABLE_IMPLICIT_TLS" = true ] || { echo 'El kit productivo requiere TLS implicito SMTP'; exit 1; }
      ;;
    *)
      export EMAIL=null
      ;;
  esac
  case "$BASE_URL" in https://*) ;; *) echo 'Produccion requiere URL HTTPS'; exit 1;; esac
fi
./fider migrate
exec ./fider
