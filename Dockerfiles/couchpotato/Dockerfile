FROM linuxserver/baseimage.python
MAINTAINER BS

# set python to use utf-8 rather than ascii, hopefully resolve special characters in movie names
ENV PYTHONIOENCODING="UTF-8"

RUN apt-get update \
    && apt-get install --no-install-recommends -y git-core python python-dev python3-lxml \
    && git clone --depth=1 \
           https://github.com/CouchPotato/CouchPotatoServer.git \
           /opt/couchpotato \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# Monte le dossier "torrents" dans "downloads" afin de permettre le téléchargement personnalisé sur rTorrent 
RUN mkdir /torrents
RUN ln -s /torrents /downloads

VOLUME /config

EXPOSE 5050

CMD python /opt/couchpotato/CouchPotato.py --data_dir /config 
