FROM        edyan/php:7.4

ARG         BUILD_DATE
ARG         DEBIAN_FRONTEND=noninteractive

COPY        --from=xhgui/xhgui:0.14.0 --chown=www-data:www-data /var/www/xhgui /usr/local/src/xhgui

# Remove config from docker image
RUN        rm -f /usr/local/src/xhgui/config/config.php

# Install tools
RUN         apt-get update -qq && \
            # Upgrade the system
            apt-get upgrade -qq -y && \
            # Setup mongodb repository
            apt-get install -qq -y gnupg wget && \
            wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add - && \
            echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.4 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.4.list && \
            apt-get update -qq && \
            # Install packages needed by xhgui and that container. Systemctl is to let mongo install itself
            echo "" > /bin/systemctl && chmod +x /bin/systemctl && \
            apt-get install -y mongodb-org-server mongodb-org-shell supervisor libcap2-bin && \
            # Alllow user to open port 80
            setcap CAP_NET_BIND_SERVICE=+eip /usr/bin/php7.4 && \
            mkdir -p /var/log/supervisor && \
            rm -f /bin/systemctl && \
            apt-get autoremove -qq -y gnupg wget && \
            apt-get autoclean -qq && \
            apt-get clean -qq && \
            # Empty some directories from all files and hidden files
            find /root /tmp -mindepth 1 -delete && \
            rm -rf /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/* \
                   /var/cache/* /var/log/* /usr/share/php/docs /usr/share/php/tests

# Install the profiler and create the profiler script like in php 5.6
WORKDIR     /usr/local/src/xhgui/external
RUN         php -r "copy('https://getcomposer.org/download/1.10.13/composer.phar', '/usr/local/bin/composer');" && \
            chmod +x /usr/local/bin/composer && \
            composer require \
                --prefer-dist --no-suggest --no-progress -o --no-ansi -n \
                perftools/php-profiler:^0.12 perftools/xhgui-collector:^1.8 alcaeus/mongo-php-adapter:^1 && \
            chown -R www-data:www-data /usr/local/src/xhgui/external && \
            rm -f /usr/local/bin/composer

COPY        --chown=www-data:www-data header.php /usr/local/src/xhgui/external/header.php

# Prepare Mongodb, supervisord
COPY        conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN         mkdir -p /data/db && chown mongodb:mongodb /data/db

# Global directives
VOLUME      ["/usr/local/src/xhgui"]

EXPOSE      80 27017

ENV         MONGO_PORT              27017
ENV         PHP_WEBSERVER_PORT      80
ENV         XHGUI_SAVE_HANDLER      mongodb
ENV         XHGUI_MONGO_HOST        mongodb://127.0.0.1:27017

COPY        tests/test.php /root/test.php
COPY        post-run.sh /root/post-run.sh
RUN         chmod +x /root/post-run.sh /root/test.php

LABEL       maintainer="Emmanuel Dyan <emmanueldyan@gmail.com>"
LABEL       org.label-schema.build-date=$BUILD_DATE

CMD         ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
