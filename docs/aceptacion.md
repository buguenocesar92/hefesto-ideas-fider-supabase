# Aceptación antes de producción
Revisión realizada: opciones de Fider 0.38.2, migración y almacenamiento SQL, SMTP/TLS, YAML, sintaxis Python/shell, generación .env e integridad ZIP. No se ejecutó Docker, PostgreSQL, Fider ni envío SMTP en este entorno.

Pendiente:
- [ ] Preflight pasa con rol propio y falla con CA incorrecta; no hay tablas ajenas.
- [ ] Bootstrap crea exactamente un portal activo y administrador confirmado por Mailpit.
- [ ] Segundo usuario puede proponer, comentar y votar según permisos; administrador modera y cambia estado.
- [ ] Privacidad, feed y admisión se comportan como se acordó; signup_disabled no se confunde con cierre de usuarios.
- [ ] Subir/descargar un adjunto; reiniciar y comprobar persistencia SQL.
- [ ] En producción, enlaces usan dominio HTTPS y correo real llega al destinatario previsto.
- [ ] Mailpit y puertos locales eliminados del despliegue definitivo.
- [ ] Restaurar en otro proyecto con Mailpit; comparar ideas, votos, comentarios y adjuntos.
- [ ] Documentar retención, RPO/RTO medidos, responsables y aceptación.
