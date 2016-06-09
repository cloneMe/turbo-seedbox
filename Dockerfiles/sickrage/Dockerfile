FROM kelvinchen/seedbox:base
MAINTAINER https://github.com/cloneMe, Kelvin Chen <kelvin@kelvinchen.org>

RUN apt-get update \
    && apt-get install -y --force-yes supervisor \
    && apt-get install --no-install-recommends -y python-cheetah \
    && git clone --depth=1 \
        https://github.com/SickRage/SickRage.git \
        /opt/sickrage \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Monte le dossier "torrents" dans "downloads" afin de permettre le téléchargement personnalisé sur rTorrent 
RUN mkdir /torrents
RUN ln -s /torrents /downloads

COPY createUsersAndStart.sh /
COPY template/* /template/
COPY rules-htpasswd /etc/nginx/.htpasswd

VOLUME /config

EXPOSE 8081

RUN chmod +x createUsersAndStart.sh
CMD ["/createUsersAndStart.sh", "/etc/nginx/.htpasswd"]

#CMD python /opt/sickrage/SickBeard.py --nolaunch --datadir \
#    /config >> /dev/null 2>&1
