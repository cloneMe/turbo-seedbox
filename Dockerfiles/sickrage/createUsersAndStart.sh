#!/bin/bash

cp /template/supervisord.conf /etc/supervisor/conf.d/


#for each user
web_port=20001

while IFS='' read -r line || [[ -n "$line" ]]; do
    #echo "Text read from file: $line"
    IFS=':' read -r userName string <<< "$line"
    
    userUp=$(echo "$userName" | tr '[:lower:]' '[:upper:]')
	useradd -d /home/$userName -m -s /bin/bash $userName
	sed -e "s/#user#/$userName/g"  /template/sickrage_user.txt > sickrage_$userName
	chmod +x sickrage_$userName
	
    if [ ! -d "/config/sickrage/$userName" ]; then
     echo "Creating: $userName"

     
	 mkdir -p /config/sickrage/$userName
     chown -R $userName:$userName /config/sickrage/$userName
	 
	 ./sickrage_$userName start && ./sickrage_$userName stop
     
    else
     echo "$userName already exists Oo"
    fi
	sed -i.bak "s/web_port = 8081/web_port = $web_port/g" /config/sickrage/$userName/config.ini
    sed -e "s/#user#/$userName/g" /template/supervisord.tmpl >> /etc/supervisor/conf.d/supervisord.conf

    web_port=$[$web_port+1]
    
done < "$1"

echo "done"
supervisord
