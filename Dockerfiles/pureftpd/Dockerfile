FROM stilliard/pure-ftpd
MAINTAINER https://github.com/cloneMe

ADD createUsersAndStart.sh /
RUN echo "" > /etc/pure-ftpd/pureftpd.passwd
RUN chmod 0770 /etc/pure-ftpd/pureftpd.passwd

VOLUME /downloads
EXPOSE 21 30000-30009
ENV PUBLICHOST localhost

RUN chmod +x createUsersAndStart.sh
#CMD /usr/sbin/pure-ftpd -c 50 -C 10 -l puredb:/etc/pure-ftpd/pureftpd.pdb -E -j -R -P $PUBLICHOST -p 30000:30009
CMD ["/createUsersAndStart.sh", "/etc/nginx/.htpasswd"]
