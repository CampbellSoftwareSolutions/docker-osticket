FROM ubuntu:14.04
MAINTAINER Martin Campbell <martin@campbellsoftware.co.uk>

# setup workdir
RUN mkdir /data
WORKDIR /data

# environment for osticket
ENV OSTICKET_VERSION 1.9.7
ENV HOME /data

# requirements
RUN apt-get update && apt-get -y install \
  nano \
  wget \
  unzip \
  supervisor \
  nginx \
  php5-cli \
  php5-fpm \
  php5-imap \
  php5-gd \
  php5-mysql && \
  rm -rf /var/lib/apt/lists/*

# Download & install OSTicket
RUN wget -O osTicket.zip http://osticket.com/sites/default/files/download/osTicket-v${OSTICKET_VERSION}.zip && \
    unzip osTicket.zip && \
    rm osTicket.zip && \
    chown -R www-data:www-data /data/upload/ && \
    mv /data/upload/setup /data/upload/setup_hidden && \
    chown -R root:root /data/upload/setup_hidden && \
    chmod 700 /data/upload/setup_hidden
    
# Download more languages packs...
RUN wget -O fr.phar http://osticket.com/sites/default/files/download/lang/fr.phar && \
    mv fr.phar /data/upload/include/i18n/ && \
    wget -O ar.phar http://osticket.com/sites/default/files/download/lang/ar.phar && \
    mv ar.phar /data/upload/include/i18n/ && \
    wget -O pt_BR.phar http://osticket.com/sites/default/files/download/lang/pt_BR.phar && \
    mv pt_BR.phar /data/upload/include/i18n/ && \
    wget -O it.phar http://osticket.com/sites/default/files/download/lang/it.phar && \
    mv it.phar /data/upload/include/i18n/ && \
    wget -O es_ES.phar http://osticket.com/sites/default/files/download/lang/es_ES.phar && \
    mv es_ES.phar /data/upload/include/i18n/ && \
    wget -O de.phar http://osticket.com/sites/default/files/download/lang/de.phar && \
    mv de.phar /data/upload/include/i18n/

# Configure nginx
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf && \
    sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf && \
    echo "daemon off;" >> /etc/nginx/nginx.conf

# Configure php-fpm & PHP5
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini && \
    sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/fpm/php.ini && \
    sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/fpm/php.ini && \
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf && \
    sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf && \
    php5enmod imap

# Add nginx site
ADD virtualhost /etc/nginx/sites-available/default
ADD supervisord.conf /data/supervisord.conf
ADD bin/ /data/bin

VOLUME ["/data/upload/include/plugins","/var/log/nginx"]
EXPOSE 80
CMD ["/data/bin/start.sh"]
