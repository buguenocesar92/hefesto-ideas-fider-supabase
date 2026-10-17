# Instalación privada
1. Cree proyecto Supabase dedicado PostgreSQL 16/17. Desactive Data API. Ejecute sql/01-supabase-app.sql en SQL Editor como administrador. Aborta si public tiene tablas. El SQL instala pg_trgm en extensions y configura search_path=public,extensions; si ya existe en otro esquema, revise con el administrador antes de moverla.
2. Ejecute `python3 scripts/configure.py`; .env se crea 0600 sin sobrescribir. Edite DB_HOST/DB_USER y asigne DB_PASSWORD a fider_app mediante `\password fider_app` en psql administrativo. Mantenga contraseña hexadecimal generada para la URL Compose; no pegar contraseñas con caracteres reservados sin adaptar construcción.
3. Guarde CA en certs/ca.crt. Conexión directa 5432 recomendada, con IPv6 o complemento IPv4. Si necesita Session pooler 5432, copie host real y use usuario `fider_app.REFERENCIA`. No Transaction pooler 6543: las migraciones usan la misma conexión. Pruebe desde el VPS.
4. Confirme SUPABASE_DEDICATED_CONFIRMED y SUPABASE_DATA_API_DISABLED true solo después de cumplirlos. Son declaraciones del operador; el script comprueba permisos/tablas, no los ajustes del panel.
5. `docker compose -f compose.yaml -f compose.bootstrap.yaml config --quiet`
6. `docker compose -f compose.yaml -f compose.bootstrap.yaml run --rm preflight`
7. `docker compose -f compose.yaml -f compose.bootstrap.yaml up -d app`
8. Desde su equipo: `ssh -L 8098:127.0.0.1:8098 -L 8026:127.0.0.1:8026 usuario@servidor`.
9. Visite http://localhost:8098 y cree el portal con el correo real que usará el administrador. Abra http://localhost:8026 para leer el correo capturado y seguir su enlace de activación. Ningún correo sale a Internet por Mailpit.
10. Configure nombre, idioma disponible, privacidad, moderación y visibilidad del feed. Cree una idea de prueba y un segundo usuario de ensayo. Verifique estados y permisos antes de publicar.

## Pasar a producción
Configure BASE_URL exacta (https://ideas.su-dominio.cl), remitente verificado, SMTP_HOST, SMTP_USERNAME y SMTP_PASSWORD. Este kit utiliza puerto 465 con TLS implícito verificado. No acepta SMTP sin cifrar en producción; si su proveedor solo ofrece 587, adapte y pruebe un transporte que exija STARTTLS antes de usarlo.

Marque INITIAL_SETUP_COMPLETE=true después de activar portal y administrador. Configure SMTP_READY=true tras revisar los datos SMTP; este flag NO prueba entrega. Haga una prueba de inicio de sesión real por HTTPS antes de dar acceso al cliente. El kit no realiza dicha prueba ni envía mensajes por sí solo durante su creación.

Ejecute `docker compose up -d --force-recreate app` sin bootstrap. Retire el contenedor Mailpit ya innecesario con `docker compose -f compose.yaml -f compose.bootstrap.yaml rm -sf mailpit`; eso elimina sus mensajes de prueba. Verifique que 8098 y 8026 ya no estén publicados. Los tokens capturados son sensibles: nunca haga pública la bandeja Mailpit.

## Coolify
Use compose.yaml desde el directorio completo/repositorio privado, monte certs y ops y mantenga las variables secretas. Asigne HTTPS al servicio app, puerto interno 3000. El proxy debe preservar Host y X-Forwarded-Proto. Haga bootstrap con el mismo nombre Compose que utilizará Coolify. Valide que el panel respeta preflight y no cambia recursos inadvertidamente.

SIGNUP_DISABLED=true impide crear nuevos portales, NO prohíbe que visitantes accedan o se registren en el portal existente. La privacidad y admisión de participantes se configuran dentro de Fider y se deben probar. No se configura OAuth ni autenticación Supabase en este kit.
