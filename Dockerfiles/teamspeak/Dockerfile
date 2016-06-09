# -----------------------------------------------------------------------------
# docker-teamspeak
#
# Builds a basic docker image that can run TeamSpeak
# (http://teamspeak.com/).
#
# Authors: BS
# Updated: February 5rd, 2016
# Require: Docker 1.9.1 (http://www.docker.io/)
# -----------------------------------------------------------------------------
FROM kelvinchen/seedbox:base
MAINTAINER BS

# Set the Teamspeak version to download
ENV TEAMSPEAK_VERSION=3.0.12

# Download and install TeamSpeak 3
ADD "http://dl.4players.de/ts/releases/${TEAMSPEAK_VERSION}/teamspeak3-server_linux_amd64-${TEAMSPEAK_VERSION}.tar.bz2" ./
RUN tar jxf "teamspeak3-server_linux_amd64-${TEAMSPEAK_VERSION}.tar.bz2"; mv "teamspeak3-server_linux_amd64" /opt/teamspeak; rm "teamspeak3-server_linux_amd64-${TEAMSPEAK_VERSION}.tar.bz2"

# Load in all of our config files.
CMD "mdkir /opt"
CMD "mdkir /opt/teamspeak/"
COPY ./scripts/start "/opt/teamspeak/start"

# Fix all permissions
RUN chmod +x "/opt/teamspeak/start"

# /start runs it.
EXPOSE 9987/udp
EXPOSE 30033
EXPOSE 10011

VOLUME "/config"

CMD ["/opt/teamspeak/start"]

