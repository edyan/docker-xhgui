FROM        edyan/php:5.6
MAINTAINER  Emmanuel Dyan <emmanuel.dyan@inetprocess.com>

ENV         DEBIAN_FRONTEND noninteractive

# Upgrade the system, install packages, clone xhgui, remove git
RUN         apt-get update && \

            apt-get upgrade -y && \

            apt-get install -y --no-install-recommends ca-certificates git mongodb-server nginx supervisor && \

            git clone https://github.com/perftools/xhgui /usr/local/src/xhgui && \
            rm -Rf /usr/local/src/xhgui/{.git,tests,phpunit.xml} && \

            apt-get purge git -y  && \
            apt-get autoremove -y && \
            apt-get clean && \
            rm -Rf /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/*


# Installing XhGui
COPY        conf/xhgui.config.php /usr/local/src/xhgui/config/config.php

WORKDIR     /usr/local/src/xhgui
# Install composer
RUN         php -r "copy('https://getcomposer.org/download/1.5.1/composer.phar', 'composer.phar');" && \
            php -r "if (hash_file('SHA384', 'composer.phar') === 'fd3800adeff12dde28e9238d2bb82ba6f887bc6d718eee3e3a5d4f70685a236b9e96afd01aeb0dbab8ae6211caeb1cbe') {echo 'Composer installed';} else {echo 'Hash invalid for downloaded composer.phar'; exit(1);}" && \
            chmod 0755 composer.phar && \
            ./composer.phar selfupdate --stable

RUN         sed -i 's/composer\.phar update/composer.phar install --no-dev/g' install.php && \
            php install.php && \
            rm -f composer.phar && \
            chown -R www-data:www-data /usr/local/src/xhgui


# Prepare Mongodb
RUN         mkdir -p /data/db /var/log/mongodb && \
            chown -R mongodb:mongodb /data /var/log/mongodb


# Prepare nginx
COPY        conf/nginx.default.conf /etc/nginx/sites-available/default


# Supervisord
RUN         mkdir -p /var/log/supervisor
COPY        conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# Global directives
VOLUME      ["/usr/local/src/xhgui"]

EXPOSE      80 27017


COPY scripts/post-run.sh /root/post-run.sh
RUN  chmod +x /root/post-run.sh

CMD ["/usr/bin/supervisord", "-n"]
