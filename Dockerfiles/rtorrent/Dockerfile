FROM ubuntu:trusty
MAINTAINER https://github.com/cloneMe
USER root

# add extra sources 
ADD ./extra.list /etc/apt/sources.list.d/extra.list

# install
RUN apt-get update && \
    apt-get install -y --force-yes rtorrent unzip unrar mediainfo curl php5-fpm php5-cli php5-geoip nginx wget ffmpeg supervisor && \
    rm -rf /var/lib/apt/lists/*


# download rutorrent
RUN mkdir -p /var/www && \
    wget --no-check-certificate https://bintray.com/artifact/download/novik65/generic/ruTorrent-3.7.zip && \
    unzip ruTorrent-3.7.zip && \
    mv ruTorrent-master /var/www/rutorrent && \
    rm ruTorrent-3.7.zip
ADD ./config.php /var/www/rutorrent/conf/
ADD ./rules-htpasswd /.htpasswd

# add startup scripts and configs
ADD startup-nginx.sh startup-php.sh /root/

RUN groupadd share

COPY createUsersAndStart.sh /
COPY template/* /template/

ENV USE_SSL=false
VOLUME /downloads /ssl

RUN chmod +x createUsersAndStart.sh /root/startup-nginx.sh /root/startup-php.sh
CMD ["/createUsersAndStart.sh", ".htpasswd"]