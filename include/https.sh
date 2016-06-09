#!/bin/bash

function letsencrypt ()
{
mkdir -p ssl
}

function self ()
{
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout ssl/nginx.key -out ssl/nginx.crt

}

