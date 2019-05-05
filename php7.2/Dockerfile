FROM    composer:1.8 AS xhgui

# Accelerate installation
RUN     composer global require hirak/prestissimo --no-plugins --no-scripts

# Install mongodb extension
RUN     apk add --no-cache alpine-sdk openssl-dev php7-dev && \
        pecl install mongodb && pecl clear-cache && \
        apk del alpine-sdk openssl-dev php7-dev
RUN     echo "extension=mongodb.so" > $PHP_INI_DIR/conf.d/mongodb.ini

# Clone xhgui and install master as there is no suitable tag, then remove useless files
RUN     git clone https://github.com/perftools/xhgui /usr/local/src/xhgui && \
        cd /usr/local/src/xhgui && \
        ln -s /usr/bin/composer composer.phar && \
        # Keep Master | git checkout tags/v0.7.1 && \
        rm -rf /usr/local/src/xhgui/.git \
               /usr/local/src/xhgui/.scrutinizer.yml \
               /usr/local/src/xhgui/.travis.yml \
               /usr/local/src/xhgui/phpunit.xml \
               /usr/local/src/xhgui/README.md \
               /usr/local/src/xhgui/tests

COPY    conf/xhgui.config.php /usr/local/src/xhgui/config/config.php

WORKDIR /usr/local/src/xhgui

RUN     sed -i 's/composer\.phar install --prefer-dist/composer.phar install --prefer-dist --no-dev/g' install.php && \
        php install.php && \
        rm -f composer.phar && \
        chown -R www-data:www-data /usr/local/src/xhgui


# Build the final container
FROM        edyan/php:7.2
MAINTAINER  Emmanuel Dyan <emmanueldyan@gmail.com>

ARG         DEBIAN_FRONTEND=noninteractive

COPY        --from=xhgui /usr/local/src/xhgui /usr/local/src/xhgui

# Install tools
RUN         apt update && \
            # Upgrade the system
            apt upgrade -y && \
            # Install packages
            apt install -y mongodb-server nginx supervisor && \
            # Clean
            apt autoremove -y && \
            apt autoclean && \
            apt clean && \
            rm -rf /root/.bashrc /root/.profile /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/* /var/cache/* /var/log/*

# Prepare Mongodb, nginx, supervisord
COPY        conf/nginx.default.conf /etc/nginx/sites-available/default
COPY        conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN         mkdir -p /data/db /var/log/mongodb && \
            chown -R mongodb:mongodb /data /var/log/mongodb && \
            # Nginx
            mkdir /var/log/nginx && \
            chown -R www-data:www-data /var/log/nginx && \
            # Supervisord
            mkdir -p /var/log/supervisor


# Global directives
VOLUME      ["/usr/local/src/xhgui"]

EXPOSE      80 27017

ENV         FPM_UID 33
ENV         FPM_GID 33

COPY        tests/test.php /root/test.php
COPY        post-run.sh /root/post-run.sh
RUN         chmod +x /root/post-run.sh /root/test.php

CMD         ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
