FROM nginx:1.31.8-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html favicon.ico /usr/share/nginx/html/
COPY js/    /usr/share/nginx/html/js/
COPY style/ /usr/share/nginx/html/style/
COPY meta/  /usr/share/nginx/html/meta/

EXPOSE 8080