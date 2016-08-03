FROM inetprocess/php:5.6
MAINTAINER Emmanuel Dyan <emmanuel.dyan@inetprocess.com>


# Upgrade the system, install packages, clone xhgui, remove git
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \

    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \

    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git mongodb-server nginx supervisor && \

    cd /usr/local/src && git clone https://github.com/perftools/xhgui && rm -Rf xhgui/.git && \

    DEBIAN_FRONTEND=noninteractive apt-get purge git -y  && \
    DEBIAN_FRONTEND=noninteractive apt-get autoremove -y && \
    DEBIAN_FRONTEND=noninteractive apt-get clean && \
    rm -Rf /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/*

# Installing XhGui
COPY conf/xhgui.config.php /usr/local/src/xhgui/config/config.php
RUN  cd /usr/local/src/xhgui && \
     sed -i 's/composer\.phar update/composer.phar install --no-dev/g' install.php && \
     php install.php && \
     rm -f composer.phar && \
     chown -R www-data:www-data /usr/local/src/xhgui


# Prepare Mongodb
RUN mkdir -p /data/db /var/log/mongodb && \
    chown -R mongodb:mongodb /data /var/log/mongodb


# Prepare nginx
COPY conf/nginx.default.conf /etc/nginx/sites-available/default


# Supervisord
RUN  mkdir -p /var/log/supervisor
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# Global directives
VOLUME ["/usr/local/src/xhgui"]

EXPOSE 80 27017


COPY scripts/post-run.sh /root/post-run.sh
RUN  chmod +x /root/post-run.sh

CMD ["/usr/bin/supervisord", "-n"]
