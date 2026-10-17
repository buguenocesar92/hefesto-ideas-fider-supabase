# Oferta comercial y entrega
Ofrecer instalación del portal, adaptación de identidad desde ajustes, definición de categorías/etiquetas, capacitación, alojamiento, copias y mantenimiento. Un servicio adicional puede ser moderación y revisión mensual de solicitudes, con responsable y plazo acordados. No se inventan precios ni SLA.

Casos: comunidad de usuarios de un SaaS, clientes de una agencia, propuestas internas de mejora o solicitudes de evolución de una plataforma. No reemplaza la mesa de ayuda para incidencias urgentes, un canal de denuncias ni un sistema de expedientes.

## Configuración manual sugerida
Título: «Ideas para mejorar nuestro servicio». Bienvenida: «Cuéntanos qué problema necesitas resolver. Busca propuestas similares antes de publicar y evita incluir información personal o confidencial».

Plantilla de propuesta: problema / quién lo enfrenta / resultado esperado / alternativa actual. Moderación: revisar duplicados, retirar datos expuestos y justificar cambios de estado. Los estados se asignan según opciones disponibles en la versión nativa; no se cargan ideas ni votos artificiales.

## Traspaso
Entregar dominio/DNS/proxy, propiedad del proyecto Supabase, rol, versión/digest, remitente/proveedor de correo, usuarios administradores y copia restaurada. Transferir secretos en un gestor y rotar accesos del operador anterior. Cada cliente debe controlar su correo de administrador: los enlaces de acceso dependen de él.

Una instalación/proyecto Supabase por cliente. Para compartir VPS use COMPOSE_PROJECT_NAME distinto en cada .env y manténgalo en todos los comandos. No se activa modo multi-tenant ni facturación SaaS en este kit.

## Relación con Odoo y n8n
Una propuesta aceptada podría convertirse en tarea Odoo mediante API/webhook y un flujo diseñado con control de duplicados. Mapeo sugerido: ID Fider → referencia externa; título/descripción → tarea; estado → etapa acordada; URL → enlace de contexto. No trasladar votos como horas ni comentarios privados a proyectos públicos.

No se incluye ese conector ni una automatización ya activa. Para trasladar el portal completo, usar restauración PostgreSQL; el dump no debe importarse en la base Odoo. Evaluar por separado usuarios, consentimiento, permisos y archivo del histórico si se migra de herramienta.

Conservar créditos y obligaciones de licencia AGPL-3.0 de Fider. El kit distribuye configuración y scripts, no se presenta el motor como desarrollo original de Hefesto.
