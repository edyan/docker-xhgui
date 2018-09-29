FROM        edyan/php:7.2
MAINTAINER  Emmanuel Dyan <emmanueldyan@gmail.com>

ARG         DEBIAN_FRONTEND=noninteractive

# Installation
RUN         apt update && \
            # Upgrade the system
            apt upgrade -y && \
            # Install packages
            apt install -y --no-install-recommends ca-certificates git mongodb-server nginx supervisor && \
            # Clone xhgui and install 0.7.1, then remove useless files
            git clone https://github.com/perftools/xhgui /usr/local/src/xhgui && \
            cd /usr/local/src/xhgui && \
            # Keep Master | git checkout tags/v0.7.1 && \
            rm -Rf /usr/local/src/xhgui/.git \
                   /usr/local/src/xhgui/.scrutinizer.yml \
                   /usr/local/src/xhgui/.travis.yml \
                   /usr/local/src/xhgui/phpunit.xml \
                   /usr/local/src/xhgui/README.md \
                   /usr/local/src/xhgui/tests && \
            # Clean
            apt purge git -y  && \
            apt autoremove -y && \
            apt autoclean && \
            apt clean && \
            rm -rf /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/* /var/cache/* /var/log/*


# Installing XhGui
COPY        conf/xhgui.config.php /usr/local/src/xhgui/config/config.php
# Install composer
RUN         apt update && \
            apt install -y --no-install-recommends curl && \
            cd /usr/local/src/xhgui && \
            curl https://getcomposer.org/download/1.6.4/composer.phar -s -S -o composer.phar && \
            chmod 0755 composer.phar && \
            ./composer.phar selfupdate --stable && \
            sed -i 's/composer\.phar update/composer.phar install --no-dev/g' install.php && \
            php install.php && \
            chown -R www-data:www-data /usr/local/src/xhgui && \
            # Clean
            rm -f composer.phar && \
            apt purge curl -y  && \
            apt autoremove -y && \
            apt autoclean && \
            apt clean && \
            rm -rf /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/* /var/cache/* /var/log/*

# Remove default run.sh
RUN         rm -f /run.sh

# Prepare Mongodb
RUN         mkdir -p /data/db /var/log/mongodb && \
            chown -R mongodb:mongodb /data /var/log/mongodb


# Prepare nginx
COPY        conf/nginx.default.conf /etc/nginx/sites-available/default
RUN         mkdir /var/log/nginx /var/log/php && \
            chown -R www-data:www-data /var/log/nginx

# Supervisord
RUN         mkdir -p /var/log/supervisor
COPY        conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# Global directives
VOLUME      ["/usr/local/src/xhgui"]

EXPOSE      80 27017

ENV         FPM_UID 33
ENV         FPM_GID 33

COPY        tests/test.php /root/test.php
RUN         chmod +x /root/test.php
COPY        post-run.sh /root/post-run.sh
RUN         chmod +x /root/post-run.sh

CMD         ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
