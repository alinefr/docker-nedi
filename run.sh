#!/bin/sh

set -e

export LANG=C
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export TZ=America/New_York

APACHE_DIR="/var/www/html"
NEDI_VERSION="1.5C"
NEDI_DIR="${APACHE_DIR}/nedi"

if [ "$(ls -A $NEDI_DIR)" ]; then
    mkdir $NEDI_DIR && \
    curl -L -o /tmp/nedi-$NEDI_VERSION.tgz http://www.nedi.ch/pub/nedi-$NEDI_VERSION.tgz && \
    cd /var/www/html/nedi && \
    tar -zx -f /tmp/nedi-$NEDI_VERSION.tgz && \
    mkdir -p /etc/service/apache2/supervise && \
    rm -rf /etc/service/sshd && \
    rm -f /etc/my_init.d/00_regen_ssh_host_keys.sh && \
    mv /tmp/build/setup-apache.sh /root && \
    mv /tmp/build/ports.conf /etc/apache2/ports.conf && \
    mv /tmp/build/site.conf /etc/apache2/sites-available/site.conf && \
    cp /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/certs/server.crt && \
    cp /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/certs/ca-bundle.crt && \
    cp /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/private/server.key && \
    /root/setup-apache.sh && \
    apt-get -yq autoremove && \
    apt-get -yq clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*
fi

# set httpd port
if [ -z "$HTTPD_PORT" ] ; then
    export HTTPD_PORT=80
fi

# update LOG_LEVEL
if [ -z "$LOG_LEVEL" ] ; then
    export LOG_LEVEL=warn
fi

# update SERVER_ADMIN
if [ -z "$SERVER_ADMIN" ] ; then
    export SERVER_ADMIN=devops@broadinstitute.org
fi

# update SERVER_NAME
if [ -z "$SERVER_NAME" ] ; then
    export SERVER_NAME=localhost
fi

# set httpd ssl port
if [ -z "$SSL_HTTPD_PORT" ] ; then
    export SSL_HTTPD_PORT=443
fi

# set SSL protocol
if [ -z "$SSL_PROTOCOL" ] ; then
    export SSL_PROTOCOL='-SSLv3 -TLSv1 -TLSv1.1 +TLSv1.2'
fi

# set the SSL Cipher Suite
if [ -z "$SSL_CIPHER_SUITE" ] ; then
    export SSL_CIPHER_SUITE='ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-ES256-SHA:!3DES:!ADH:!DES:!DH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!EXPORT:!KRB5-DES-CBC3-SHA:!MD5:!PSK:!RC4:!aECDH:!aNULL:!eNULL'
fi

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid

exec /usr/sbin/apachectl -DNO_DETACH -DFOREGROUND 2>&1
