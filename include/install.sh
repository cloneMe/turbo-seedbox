#!/bin/bash
# MAINTAINER https://github.com/cloneMe

function FONCYES ()
{
[ "$1" = "y" ] || [ "$1" = "Y" ]
}

function FONC_EXIT ()
{
echo -e "docker not found & you have to install it ! Your linux is : "
cat /etc/*-release
exit 1
}

function FUNC_INSTALL_DOCKER ()
{
curl -sSL https://get.docker.com/ | sh
# now install docker-compose
curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version
}

function FONC_INSTALL ()
{
if ! hash docker 2>/dev/null; then
 apt-get update
	if ! hash curl 2>/dev/null; then
	   echo "Install curl & docker ? [y/n]"
	   read -r RESPONSE
	   if FONCYES "$RESPONSE"; then
	     apt-get install -y curl
	   else
	    FONC_EXIT
	   fi
    fi
	if FONCYES "$RESPONSE"; then
	    FUNC_INSTALL_DOCKER
	else
	   echo "Install docker ? [y/n]"
	   read -r RESPONSE
	   if FONCYES "$RESPONSE"; then
	     FUNC_INSTALL_DOCKER
	   else
	     FONC_EXIT
	   fi
	fi

fi
}

FONC_INSTALL

