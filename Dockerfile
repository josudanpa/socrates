# Sócrates: auditoría de respuesta a leads (IA → humano). Página estática en nginx, sin contraseña (demo).
# Los datos salen del flujo de n8n de la agencia (webhook /webhook/SOCRATES), que la página llama directo.
# En EasyPanel: app desde este repo, puerto 80.
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
