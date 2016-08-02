FROM inetprocess/php:5.6
MAINTAINER Emmanuel Dyan <emmanuel.dyan@inetprocess.com>


RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git mongodb-server nginx supervisor


# Installing XhGui
RUN  cd /usr/local/src && git clone https://github.com/perftools/xhgui && rm -Rf xhgui/.git
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


# Clean everything
RUN apt-get purge git -y  && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -Rf /var/lib/apt/lists/* \
    rm -Rf /usr/share/man/* /usr/share/doc/*


# Supervisord
RUN  mkdir -p /var/log/supervisor
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf


VOLUME ["/data/db", "/usr/local/src/xhgui"]

ENV FPM_UID 33
ENV FPM_GID 33

EXPOSE 80 27017


COPY scripts/post-run.sh /root/post-run.sh
RUN  chmod +x /root/post-run.sh

CMD ["/usr/bin/supervisord", "-n"]
