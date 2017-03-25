#!/bin/sh
# (C) Campbell Software Solutions 2015
set -e

# Populate "/data/upload/include/i18n" volume with language packs
if [ ! "$(ls -A /data/upload/include/i18n)" ]; then
    cp -r /data/upload/include/i18n.dist/* /data/upload/include/i18n
    chown -R www-data:www-data /data/upload/include/i18n
fi

# Automate installation
php /data/bin/install.php
echo Applying configuration file security
chmod 644 /data/upload/include/ost-config.php

if [ ! -d "/run/nginx" ]; then
    mkdir /run/nginx
    chown -R www-data:www-data /run/nginx
    chown -R www-data:www-data /var/lib/nginx
    mkdir /var/log/php
    chown -R www-data:www-data /var/log/php
fi
#Launch supervisor to manage processes
exec /usr/bin/supervisord -c /data/supervisord.conf
