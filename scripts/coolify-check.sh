#!/usr/bin/env bash
# Verifica que el compose principal cumple el contrato Coolify del MVP Hefesto.
# Reglas: sin ports/container_name/capacidades del host, sin name fijo,
# DB_NAME y DB_SSLMODE parametrizables.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
COMPOSE="$ROOT/compose.yaml"

if ! command -v docker >/dev/null 2>&1; then
  echo "FAIL: docker no esta instalado" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "FAIL: jq no esta instalado" >&2
  exit 1
fi

log() { printf '%s\n' "$*"; }
err() { printf 'FAIL: %s\n' "$*" >&2; }

echo "===== coolify-check $(date -Iseconds) ====="
echo "compose: $COMPOSE"

# Extraer todas las variables ${VAR}, ${VAR:-default} y ${VAR:?error} del compose.
mapfile -t VARS < <(grep -oE '\$\{[A-Z_][A-Z0-9_]*(:?[?]?[^}]*)?\}' "$COMPOSE" \
  | sed -E 's/^\$\{([A-Z_][A-Z0-9_]*).*/\1/' \
  | sort -u)
log "variables detectadas: ${VARS[*]}"

# Generar .env temporal con valores ficticios.
TMP_ENV="$(mktemp)"
trap 'rm -f "$TMP_ENV"' EXIT
{
  for v in "${VARS[@]}"; do
    val="x1234567890abcdef"
    case "$v" in
      DB_HOST|BASE_URL|SMTP_HOST|EMAIL_NOREPLY)
        val="https://ejemplo.invalid" ;;
      SUPABASE_DEDICATED_CONFIRMED|SUPABASE_DATA_API_DISABLED|SMTP_READY|INITIAL_SETUP_COMPLETE)
        val="true" ;;
      DB_NAME)
        val="mvp_prueba" ;;
      DB_SSLMODE)
        val="disable" ;;
    esac
    echo "$v=$val"
  done
} > "$TMP_ENV"
log "env temporal generado en $TMP_ENV"

# Renderizar el compose. Aislar stderr para no contaminar el JSON con warnings.
DOCKER_ERR="$(mktemp)"
RENDER_JSON_FILE="$(mktemp)"
trap 'rm -f "$TMP_ENV" "$DOCKER_ERR" "$RENDER_JSON_FILE"' EXIT
if ! RENDER_JSON="$(docker compose --project-directory "$ROOT" -f "$COMPOSE" --env-file "$TMP_ENV" config --format json 2>"$DOCKER_ERR")"; then
  err "docker compose config fallo:"
  cat "$DOCKER_ERR" >&2
  exit 1
fi
if [ -s "$DOCKER_ERR" ]; then
  log "--- stderr de docker compose config ---"
  cat "$DOCKER_ERR" >&2
  log "--- fin stderr ---"
fi
if ! printf '%s' "$RENDER_JSON" | jq -e . >/dev/null 2>&1; then
  err "la salida de docker compose config no es JSON valido"
  printf '%s' "$RENDER_JSON" | head -c 500 >&2
  echo >&2
  exit 1
fi
printf '%s' "$RENDER_JSON" > "$RENDER_JSON_FILE"
log "render json: $RENDER_JSON_FILE"

ERRORS=()

# Punto 2: sin name: raiz fijo. Coolify deriva el nombre del directorio del proyecto;
# cualquier `name:` literal en el compose es una fijacion que rompe ese contrato.
if grep -E '^[[:space:]]*name:[[:space:]]+' "$COMPOSE" >/dev/null 2>&1; then
  fixed_name="$(grep -E '^[[:space:]]*name:[[:space:]]+' "$COMPOSE" | head -1 | sed -E 's/^[[:space:]]*name:[[:space:]]+//')"
  ERRORS+=("raiz: name fijado a '$fixed_name'; Coolify debe asignar el nombre")
fi

# Inspeccionar servicios sin profiles.
mapfile -t SERVICES < <(printf '%s' "$RENDER_JSON" | jq -r '.services | keys[]')
for svc in "${SERVICES[@]}"; do
  prof_count="$(printf '%s' "$RENDER_JSON" | jq -r ".services[\"$svc\"].profiles // [] | length")"
  if [ "$prof_count" != "0" ]; then
    continue
  fi

  # Punto 1: nada que salte Traefik ni de poder sobre el host.
  ports_len="$(printf '%s' "$RENDER_JSON" | jq -r ".services[\"$svc\"].ports // [] | length")"
  if [ "$ports_len" != "0" ]; then
    ERRORS+=("$svc: expone 'ports'; Traefik debe enrutar")
  fi
  cn_len="$(printf '%s' "$RENDER_JSON" | jq -r ".services[\"$svc\"].container_name // \"\" | length")"
  if [ "$cn_len" != "0" ]; then
    ERRORS+=("$svc: container_name fijo; Coolify debe nombrarlo")
  fi
  priv="$(printf '%s' "$RENDER_JSON" | jq -r ".services[\"$svc\"].privileged // false")"
  if [ "$priv" = "true" ]; then
    ERRORS+=("$svc: privileged habilitado; expone el host")
  fi
  cap_len="$(printf '%s' "$RENDER_JSON" | jq -r ".services[\"$svc\"].cap_add // [] | length")"
  if [ "$cap_len" != "0" ]; then
    ERRORS+=("$svc: cap_add habilitado; expone el host")
  fi
  dev_len="$(printf '%s' "$RENDER_JSON" | jq -r ".services[\"$svc\"].devices // [] | length")"
  if [ "$dev_len" != "0" ]; then
    ERRORS+=("$svc: devices habilitado; expone el host")
  fi
  net="$(printf '%s' "$RENDER_JSON" | jq -r ".services[\"$svc\"].network_mode // \"\"")"
  if [ "$net" = "host" ]; then
    ERRORS+=("$svc: network_mode host; evade la red de Docker")
  fi
  pid="$(printf '%s' "$RENDER_JSON" | jq -r ".services[\"$svc\"].pid // \"\"")"
  if [ "$pid" = "host" ]; then
    ERRORS+=("$svc: pid host; expone procesos del host")
  fi
  ipc="$(printf '%s' "$RENDER_JSON" | jq -r ".services[\"$svc\"].ipc // \"\"")"
  if [ "$ipc" = "host" ]; then
    ERRORS+=("$svc: ipc host; expone IPC del host")
  fi
  sec="$(printf '%s' "$RENDER_JSON" | jq -r ".services[\"$svc\"].security_opt // [] | join(\" \")")"
  case "$sec" in *unconfined*) ERRORS+=("$svc: security_opt unconfined; evade AppArmor/SELinux");; esac

  # Binds fuera del repo y docker.sock.
  while IFS= read -r src; do
    [ -z "$src" ] && continue
    case "$src" in
      /var/run/docker.sock*|docker.sock*) ERRORS+=("$svc: monta docker.sock; escapada total"); continue ;;
    esac
    case "$src" in
      "$ROOT"/*) ;;
      *) ERRORS+=("$svc: bind fuera del repo: $src") ;;
    esac
  done < <(printf '%s' "$RENDER_JSON" | jq -r ".services[\"$svc\"].volumes // [] | .[] | select(type==\"object\") | select(.type==\"bind\" or (.type|not)) | .source")

done

# Punto 3 (supabase-pg): DB_NAME y DB_SSLMODE parametrizables.
if ! printf '%s' "$RENDER_JSON" | grep -q "mvp_prueba"; then
  ERRORS+=("supabase-pg: DB_NAME=mvp_prueba no aparece en el render")
fi
if ! printf '%s' "$RENDER_JSON" | grep -q "disable"; then
  ERRORS+=("supabase-pg: DB_SSLMODE=disable no aparece en el render")
fi

if [ "${#ERRORS[@]}" -gt 0 ]; then
  {
    echo "incumplimientos: ${#ERRORS[@]}"
    for e in "${ERRORS[@]}"; do echo "  - $e"; done
  } >&2
  exit 1
fi

log "OK: compose cumple el contrato Coolify"