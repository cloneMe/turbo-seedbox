FROM kelvinchen/seedbox:base
MAINTAINER Kelvin Chen <kelvin@kelvinchen.org>

RUN apt-get update \
    && apt-get install --no-install-recommends -y apache2-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME /config

EXPOSE 80 443

ENV USE_SSL=false \
    server_name=localhost 

COPY common_default.conf ssl.conf /etc/nginx/
COPY nginx.conf /etc/nginx/nginx.conf

COPY start /

COPY rules-htpasswd /etc/nginx/.htpasswd

RUN rm -rf /var/www \
    && mkdir /var/www
COPY www /var/www/

RUN chmod +x start
CMD ["/start"]
