FROM nginx:$VERSION AS base

# ARG PHP_UPSTREAM_CONTAINER=php-fpm
ARG PHP_UPSTREAM_CONTAINER=php
ARG PHP_UPSTREAM_PORT=9000
ARG PUID=1000

# Set upstream conf and remove the default conf
RUN sed -i "s/^nginx:x:\d\+:\d\+:/nginx:x:${PUID}:0:/" /etc/passwd \
    && mkdir -p /etc/nginx/sites-available \
    && echo "upstream php-upstream { server ${PHP_UPSTREAM_CONTAINER}:${PHP_UPSTREAM_PORT}; }" > /etc/nginx/conf.d/upstream.conf

CMD ["nginx"]

EXPOSE 80 443
