# turbo-seedbox

This project deploys a multi-users seedbox, using Docker. It will install docker automatically, if needed, and deploy following servers:
- rtorrent: to download torrent.
- sickrage: Automatic Video Library Manager for TV Shows. It watches for new episodes of your favorite shows, and when they are posted it does its magic.
- couchpotato: same thing but for films.
- plex: to stream videos from your server.
- openVPN: a VPN server.
- teamspeak server.
- a FTP server, a file manager (https://github.com/simogeo/Filemanager), ...
- WARNING: By default, fail2ban is deployed to protect the host. You have only one try to connect using SSH. If you enter an incorrect password, you will be ban during 1 hour. See include/fail2ban.

## 0. Download sources
### 0.1 Install Docker
- On Linux:
You can skip this part, it's done automatically.
- On Mac or Windows:
see: https://docs.docker.com/engine/installation/

### 0.2 Download sources
On Windows, I recommend you to install this project in your home, i.e.: C:\Users\< user >\docker.
```bash
git clone https://github.com/cloneMe/turbo-seedbox.git
cd turbo-seedbox
chmod +x build.sh
```

## 1. Configure following files
### 1.1 Create your users
Run the following command to create an user:
```bash
 printf "<user name>:$(openssl passwd -crypt <password>)\n" >> htpasswd.txt
```
Or do nothing and a htpasswd.txt file will be generated with two users: foo and bar, using the password foo.
Example to create bar:
```bash
   printf "bar:$(openssl passwd -crypt foo)\n" >> htpasswd.txt
```

### 1.2 Edit properties in build.sh
By default:
- The host is 192.168.99.100. Please update the `server_name` property.
- All servers with the property at true will be deployed.
- Files created by servers are saved in the parent folder. To use another folder, change the `seedboxFiles` property. Following folders will be created:
 * config
 * downloads
 * log


## 2. Run build.sh
It will:
- Install Docker if needed.
- Build custom containers.
- Generate docker-compose & nginx. These files depend on users in htpasswd.txt. If you add or remove an user, you have to launch ./build.sh again.
To note: take a coffee or a beer ;) This step depends of your connection (you have to download 1.7G or 3G :/ ).

## 3. Configure your DNS
Following subdomains are used: files, rtorrent, sickrage, couchpotato and explorer.
If your DNS handle wildcards, you are lucky.
Otherwise, you need to declare each subdomain.

## 4. Launch servers

* To start all servers: `docker-compose up -d`
* To see logs: `docker-compose logs`
* To stop all servers: `docker-compose stop`
* To stop all servers+: `docker stop $(docker ps -q)`
* To check resources used: `docker stats`
* all containers use restart, so run the following command to not launch containers at startup:
`docker-compose rm`
* To remove images: `docker ps -a |  awk '{print $1}' | xargs --no-run-if-empty docker rm`
* Delete all containers `docker rm $(docker ps -a -q)`
* Delete all images `docker rmi $(docker images -q)`

# [For dev]
- run  `cp build.sh local.sh` and work with local.sh
- Edit your C:\Windows\System32\drivers\etc\hosts

And add (if the docker's IP is 192.168.99.100, run "docker-machine ip default" to know it)
```
192.168.99.100 dock
192.168.99.100 rtorrent.dock
192.168.99.100 files.dock
192.168.99.100 plex.dock
192.168.99.100 sickrage.dock
192.168.99.100 couchpotato.dock
192.168.99.100 explorer.dock
```
Then you can access to servers using these urls:
```
http://rtorrent.dock
http://files.dock
http://sickrage.dock
http://couchpotato.dock
http://explorer.dock
```

# Links
https://github.com/Kelvin-Chen/seedbox

Docker : https://github.com/wsargent/docker-cheat-sheet

Plex: https://hub.docker.com/r/timhaak/plex/

Explorer: https://github.com/soyuka/explorer

Sickrage: https://mondedie.fr/viewtopic.php?id=6674

rtorrent : https://github.com/gaaara/gaaara/blob/master/rtorrent-useradd
https://mondedie.fr/viewtopic.php?id=5399
https://github.com/ifsred/media-server
https://github.com/david-sawatzke/rtorrent-rutorrent
https://github.com/diameter/rtorrent-rutorrent

HTTPS
https://mondedie.fr/viewtopic.php?id=7414
https://www.kassianoff.fr/blog/fr/let-encrypt-certificat-gratuit-valide
https://blog.ouvrard.it/2016/03/18/lets-encrypt-nginx/
https://github.com/mazelab/docker-ftp/blob/master/Dockerfile
https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion
 Webserver with nginx, letsencrypt and fail2ban built-in:
https://hub.docker.com/r/aptalca/nginx-letsencrypt/
https://github.com/luiz-simples/docker-webserver

e-mails
https://mondedie.fr/viewtopic.php?id=5750
https://github.com/hardware/mailserver/blob/master/docker-compose.sample.yml

Fail2ban
https://mondedie.fr/viewtopic.php?id=6978
https://hub.docker.com/r/voobscout/base-deb/

Other
https://github.com/webdevops/Dockerfile


## Why?
I did this to learn and because I could not find a seedbox easy to install & multi-users.

Kiss.
