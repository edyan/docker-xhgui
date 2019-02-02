#!/bin/bash
envsubst '${NGINX_PORT},${MONGO_PORT},${PHPFPM_PORT}' < /etc/nginx/sites-available/default.template > /etc/nginx/sites-available/default
envsubst '${PHPFPM_PORT}' < /etc/php/7.2/fpm/pool.d/www.conf.template > /etc/php/7.2/fpm/pool.d/www.conf

exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
