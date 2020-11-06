# Deployment doesn't work on Alpine
FROM php:7.3-cli AS deployer
ENV OSTICKET_VERSION=1.14.3
RUN set -x \
    && apt-get update \
    && apt-get install -y git-core \
    && git clone -b v${OSTICKET_VERSION} --depth 1 https://github.com/osTicket/osTicket.git \
    && cd osTicket \
    && php manage.php deploy -sv /data/upload \
    # www-data is uid:gid 82:82 in php:7.0-fpm-alpine
    && chown -R 82:82 /data/upload \
    # Hide setup
    && mv /data/upload/setup /data/upload/setup_hidden \
    && chown -R root:root /data/upload/setup_hidden \
    && chmod -R go= /data/upload/setup_hidden

FROM php:7.3-fpm-alpine
MAINTAINER Martin Campbell <martin@campbellsoftware.co.uk>
# environment for osticket
ENV HOME=/data
# setup workdir
WORKDIR /data
COPY --from=deployer /data/upload upload
RUN set -x && \
    # requirements and PHP extensions
    apk add --no-cache --update \
        wget \
        msmtp \
        ca-certificates \
        supervisor \
        nginx \
        libpng \
        c-client \
        openldap \
        libintl \
        libxml2 \
        libzip \
        icu \
        openssl \
        git && \
    apk add --no-cache --virtual .build-deps \
        imap-dev \
        libpng-dev \
        curl-dev \
        openldap-dev \
        gettext-dev \
        libxml2-dev \
        libzip-dev \
        icu-dev \
        autoconf \
        g++ \
        make \
        pcre-dev \
        git && \
    docker-php-ext-install gd curl ldap mysqli sockets gettext mbstring xml intl opcache zip && \
    docker-php-ext-configure imap --with-imap-ssl && \
    docker-php-ext-install imap && \
    pecl install apcu && docker-php-ext-enable apcu && \
    apk del .build-deps && \
    rm -rf /var/cache/apk/* && \
    # Download languages packs
    wget -nv -O upload/include/i18n/fr.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/fr.phar && \
    wget -nv -O upload/include/i18n/ar.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/ar.phar && \
    wget -nv -O upload/include/i18n/pt_BR.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/pt_BR.phar && \
    wget -nv -O upload/include/i18n/it.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/it.phar && \
    wget -nv -O upload/include/i18n/es_ES.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/es_ES.phar && \
    wget -nv -O upload/include/i18n/de.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/de.phar && \
    wget -nv -O upload/include/i18n/sq.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/sq.phar && \
    wget -nv -O upload/include/i18n/ar_EG.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/ar_EG.phar && \
    wget -nv -O upload/include/i18n/az.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/az.phar && \
    wget -nv -O upload/include/i18n/eu.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/eu.phar && \
    wget -nv -O upload/include/i18n/bn.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/bn.phar && \
    wget -nv -O upload/include/i18n/bs.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/bs.phar && \
    wget -nv -O upload/include/i18n/bg.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/bg.phar && \
    wget -nv -O upload/include/i18n/ca.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/ca.phar && \
    wget -nv -O upload/include/i18n/zh_CN.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/zh_CN.phar && \
    wget -nv -O upload/include/i18n/zh_TW.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/zh_TW.phar && \
    wget -nv -O upload/include/i18n/hr.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/hr.phar && \
    wget -nv -O upload/include/i18n/cd.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/cs.phar && \
    wget -nv -O upload/include/i18n/da.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/da.phar && \
    wget -nv -O upload/include/i18n/nl.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/nl.phar && \
    wget -nv -O upload/include/i18n/en_GB.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/en_GB.phar && \
    wget -nv -O upload/include/i18n/et.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/et.phar && \
    wget -nv -O upload/include/i18n/fi.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/fi.phar && \
    wget -nv -O upload/include/i18n/gl.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/gl.phar && \
    wget -nv -O upload/include/i18n/ka.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/ka.phar && \
    wget -nv -O upload/include/i18n/el.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/el.phar && \
    wget -nv -O upload/include/i18n/he.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/he.phar && \
    wget -nv -O upload/include/i18n/hi.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/hi.phar && \
    wget -nv -O upload/include/i18n/hu.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/hu.phar && \
    wget -nv -O upload/include/i18n/is.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/is.phar && \
    wget -nv -O upload/include/i18n/id.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/id.phar && \
    wget -nv -O upload/include/i18n/ja.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/ja.phar && \
    wget -nv -O upload/include/i18n/km.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/km.phar && \
    wget -nv -O upload/include/i18n/ko.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/ko.phar && \
    wget -nv -O upload/include/i18n/lv.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/lv.phar && \
    wget -nv -O upload/include/i18n/lt.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/lt.phar && \
    wget -nv -O upload/include/i18n/mk.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/mk.phar && \
    wget -nv -O upload/include/i18n/ms.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/ms.phar && \
    wget -nv -O upload/include/i18n/mn.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/mn.phar && \
    wget -nv -O upload/include/i18n/no.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/no.phar && \
    wget -nv -O upload/include/i18n/fa.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/fa.phar && \
    wget -nv -O upload/include/i18n/pl.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/pl.phar && \
    wget -nv -O upload/include/i18n/ro.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/ro.phar && \
    wget -nv -O upload/include/i18n/ru.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/ru.phar && \
    wget -nv -O upload/include/i18n/sr.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/sr.phar && \
    wget -nv -O upload/include/i18n/sr_CS.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/sr_CS.phar && \
    wget -nv -O upload/include/i18n/sk.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/sk.phar && \
    wget -nv -O upload/include/i18n/sl.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/sl.phar && \
    wget -nv -O upload/include/i18n/es_AR.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/es_AR.phar && \
    wget -nv -O upload/include/i18n/es_MX.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/es_MX.phar && \
    wget -nv -O upload/include/i18n/sw.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/sw.phar && \
    wget -nv -O upload/include/i18n/sv_SE.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/sv_SE.phar && \
    wget -nv -O upload/include/i18n/th.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/th.phar && \
    wget -nv -O upload/include/i18n/tr.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/tr.phar && \
    wget -nv -O upload/include/i18n/uk.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/uk.phar && \
    wget -nv -O upload/include/i18n/ur_IN.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/ur_IN.phar && \
    wget -nv -O upload/include/i18n/ur_PK.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/ur_PK.phar && \
    wget -nv -O upload/include/i18n/vi.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/vi.phar && \
    mv upload/include/i18n upload/include/i18n.dist && \
    # Download official plugins
    wget -nv -O upload/include/plugins/auth-ldap.phar https://s3.amazonaws.com/downloads.osticket.com/plugin/auth-ldap.phar && \
    wget -nv -O upload/include/plugins/auth-passthru.phar https://s3.amazonaws.com/downloads.osticket.com/plugin/auth-passthru.phar && \
    wget -nv -O upload/include/plugins/storage-fs.phar https://s3.amazonaws.com/downloads.osticket.com/plugin/storage-fs.phar && \
    wget -nv -O upload/include/plugins/storage-s3.phar https://s3.amazonaws.com/downloads.osticket.com/plugin/storage-s3.phar && \
    wget -nv -O upload/include/plugins/audit.phar https://s3.amazonaws.com/downloads.osticket.com/plugin/audit.phar && \
    
    # Download community plugins
    ## Archiver
    git clone https://github.com/clonemeagain/osticket-plugin-archiver upload/include/plugins/archiver && \
    ## Attachment Preview
    git clone https://github.com/clonemeagain/attachment_preview upload/include/plugins/attachment-preview && \
    ## Auto Closer
    git clone https://github.com/clonemeagain/plugin-autocloser upload/include/plugins/auto-closer && \
    ## Fetch Note
    git clone https://github.com/bkonetzny/osticket-fetch-note upload/include/plugins/fetch-note && \
    ## Field Radio Buttons
    git clone https://github.com/Micke1101/OSTicket-plugin-field-radiobuttons upload/include/plugins/field-radiobuttons && \
    ## Mentioner
    git clone https://github.com/clonemeagain/osticket-plugin-mentioner upload/include/plugins/mentioner && \
    ## Multi LDAP Auth
    git clone https://github.com/philbertphotos/osticket-multildap-auth upload/include/plugins/multi-ldap && \
    mv upload/include/plugins/multi-ldap/multi-ldap/* upload/include/plugins/multi-ldap/ && \
    rm -rf upload/include/plugins/multi-ldap/multi-ldap && \
    ## Prevent Autoscroll
    git clone https://github.com/clonemeagain/osticket-plugin-preventautoscroll upload/include/plugins/prevent-autoscroll && \
    ## Rewriter
    git clone https://github.com/clonemeagain/plugin-fwd-rewriter upload/include/plugins/rewriter && \
    ## Slack
    git clone https://github.com/clonemeagain/osticket-slack upload/include/plugins/slack && \
    ## Teams (Microsoft)
    git clone https://github.com/ipavlovi/osTicket-Microsoft-Teams-plugin upload/include/plugins/teams && \
    
    # Create msmtp log
    touch /var/log/msmtp.log && \
    chown www-data:www-data /var/log/msmtp.log && \
    # File upload permissions
    mkdir -p /var/tmp/nginx && \
    chown nginx:www-data /var/tmp/nginx && chmod g+rx /var/tmp/nginx
COPY files/ /
RUN chmod +x /data/bin/start.sh
VOLUME ["/data/upload/include/plugins","/data/upload/include/i18n","/var/log/nginx"]
EXPOSE 80
CMD ["/data/bin/start.sh"]