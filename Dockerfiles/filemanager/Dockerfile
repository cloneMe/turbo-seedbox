# -----------------------------------------------------------------------------
# docker-filemanager
#
# Builds a basic docker image that can run a FileManager
# (https://github.com/simogeo/Filemanager).
#
# Authors: LM, BS
# Updated: February 12rd, 2016
# Require: Docker 1.9.1 (http://www.docker.io/)
# Done on Windobe !
# -----------------------------------------------------------------------------
FROM kelvinchen/seedbox:base
MAINTAINER LM

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        php5-fpm \
        php5-cli \
        php5-gd \
    && apt-get install --no-install-recommends -y apache2-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download and install Filemanager
# Issue with github - easily fixeable
# ADD "https://github.com/simogeo/Filemanager/archive/master.zip" ./
COPY Filemanager-master.zip /
RUN unzip Filemanager-master.zip -d /opt/;  rm /Filemanager-master.zip

# configure supervisor
ADD supervisord.conf /etc/supervisor/conf.d/

# Load in all of our config files.
COPY nginx.conf /etc/nginx/
#Given config file (filemanager.config.json) does not exist !
COPY filemanager.config.js "/opt/Filemanager-master/scripts/filemanager.config.json"

# Increase the upload file size limit
RUN sed -i 's/upload_max_filesize/;upload_max_filesize/g' /etc/php5/cli/php.ini 

# Unlock memory limit to allow large zip upload
RUN sed -i 's/memory_limit = 128M/memory_limit = -1/g' /etc/php5/fpm/php.ini

# /start runs it.
EXPOSE 80

VOLUME /downloads

CMD ["supervisord"]
