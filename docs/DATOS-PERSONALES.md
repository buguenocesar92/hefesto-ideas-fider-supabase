# Datos personales — Ideas (Fider)

Contrato del kit `hefesto-ideas-fider-supabase` bajo la **Ley 21.719** (Proteccion de Datos
Personales, Chile). Este documento es normativo para el kit: el despliegue no
se considera completo sin el.

## 1. Inventario de datos

Fider es un buzon de sugerencias: guarda **datos personales** de quien escribe (correo, nombre o alias, avatar), el texto de la idea o de los comentarios, los votos y las suscripciones a las listas de ideas. El kit no administra cuentas de pago ni datos de clientes finales.

## 2. Control de acceso y roles

El rol de base `DB_USER` (`fider_app`) es de aplicacion, no superusuario. Los usuarios administradores de Fider se gestionan dentro de la aplicacion; el kit no expone el panel de administracion fuera del proxy.

## 3. Minimizacion

Fider necesita el correo solo para responder. El kit deja `SMTP_READY` desactivado por defecto: sin correo saliente no hay fuga de direcciones a un tercero. Los votos son agregados y no identifican por si solos a una persona.

## 4. Retencion

Retencion propuesta: **12 meses** para las ideas y sus comentarios, **6 meses** para los votos y **7 dias** para el respaldo verificado. Una idea cerrada puede anonimizarse dejando el conteo. El plazo definitivo lo acuerda el cliente con suasesor.

## 5. Supresion, rectificacion y acceso del titular

La supresion es una operacion del cliente sobre la base: eliminar o anonimizar la idea, sus comentarios y las filas de suscripcion. El kit deja el procedimiento y lo hace verificable con `scripts/check_backup.py` antes de cualquier restauracion.

## 6. Acceso al respaldo, auditoria y transito

El `JWT_SECRET` es la credencial mas sensible del kit: con el se falsifican sesiones de administrador. `scripts/check-env.py --modo real` verifica que tenga al menos 32 caracteres y que no se repita con otra clave, sin imprimir su valor. El respaldo viaja cifrado y el descifrado queda registrado.

### Acceso al respaldo y transito

`DB_SSLMODE` por defecto `verify-full` con la CA de Supabase montada en `certs/`. La publicacion la termina Coolify/Traefik.

## 7. Que NO decide el kit

Los plazos definitivos, la base legal y la incorporacion de los titulares al
registro de actividades de tratamiento son decisiones **del cliente**, no del
kit. Este documento deja la propuesta escrita y verificable; su validacion es
una tarea pendiente de coordinacion.

## 8. Verificacion

```bash
bats tests/                              # ciclo de respaldo con datos sinteticos
python3 scripts/check-env.py --modo real # contrato del .env, sin imprimir valores
python3 scripts/check_backup.py <respaldo>
```
