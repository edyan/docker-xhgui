FROM    composer:1.8 AS xhgui

# Accelerate installation
RUN     composer global require hirak/prestissimo --no-plugins --no-scripts

# Install mongodb extension
RUN     set -x && \
        apk add --no-cache --virtual .build-deps ${PHPIZE_DEPS} && \
	    pecl install mongodb && docker-php-ext-enable mongodb && \
        apk del .build-deps

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
        # required as php > 7 and driver = mongodb
        /usr/bin/composer require --update-no-dev --no-scripts alcaeus/mongo-php-adapter ^1.1 && \
        # clean
        rm -f composer.phar


# Build the final container
FROM        edyan/php:7.2
MAINTAINER  Emmanuel Dyan <emmanueldyan@gmail.com>

ARG         DEBIAN_FRONTEND=noninteractive

COPY        --from=xhgui --chown=www-data:www-data /usr/local/src/xhgui /usr/local/src/xhgui

# Install tools
RUN         apt update && \
            # Upgrade the system
            apt upgrade -y && \
            # Install packages needed by xhgui and that container
            apt install -y mongodb-server-core supervisor && \
            # Clean
            apt autoremove -y && \
            apt autoclean && \
            apt clean && \
            rm -rf /root/.bashrc /root/.profile /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/* /var/cache/* /var/log/*

# Prepare Mongodb, supervisord
COPY        conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN         mkdir -p /data/db /var/log/mongodb && \
            # Supervisord
            mkdir -p /var/log/supervisor


# Global directives
VOLUME      ["/usr/local/src/xhgui"]

EXPOSE      80 27017

ENV         XHGUI_MONGO_HOST "mongodb://127.0.0.1"

COPY        tests/test.php /root/test.php
COPY        post-run.sh /root/post-run.sh
RUN         chmod +x /root/post-run.sh /root/test.php

CMD         ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
