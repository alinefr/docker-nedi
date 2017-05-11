FROM phusion/baseimage:0.9.19

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8

COPY . /tmp/build

RUN apt-get update && \
    add-apt-repository -y ppa:ondrej/php && \
    apt-get update && \
    apt-get -yq upgrade && \
    apt-get -yq install apache2 libalgorithm-diff-perl libapache2-mod-php5.6 \
        libcrypt-des-perl libcrypt-hcesha-perl libcrypt-rijndael-perl \
        libdbd-mysql-perl libdbi-perl libdigest-hmac-perl libio-pty-perl \
        liblwp-useragent-determined-perl libnet-dns-perl libnet-ntp-perl \
        libnet-snmp-perl libnet-telnet-perl librrds-perl libsocket6-perl \
        php5.6-gd php5.6-mcrypt php5.6-mysql php5.6-snmp rrdtool 

CMD /tmp/build/run.sh
