# DOCKER-VERSION 1.0.0
FROM    centos:centos6

# Install repos
RUN yum update -y >/dev/null
RUN yum install -y http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm

# Install supervisor repo
RUN yum install -y python-meld3 http://dl.fedoraproject.org/pub/epel/6/i386/supervisor-2.1-8.el6.noarch.rpm

#install nginx, php
RUN rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm
RUN ["yum", "-y", "install", "nginx", "php56w", "php56w-common", "php56w-fpm", "php56w-mcrypt", "php56w-curl", "php56w-mysql", "php56w-sqlite", "php56w-pdo", "php56w-devel", "php56w-gd", "php56w-pecl-memcached", "php56w-pecl-memcache", "php56w-pspell", "php56w-snmp", "php56w-xmlrpc", "php56w-xml"]

#install opcache
RUN yum install -y php-opcache

# Create folder for server and add index.php file to for nginx
RUN mkdir -p /var/www/public && chmod a+r /var/www/public && echo "<?php phpinfo(); ?>" > /var/www/public/index.php

# ADD nginx config
ADD docker/nginx.conf /etc/nginx/nginx.conf
ADD docker/default.conf /etc/nginx/conf.d/default.conf

# ADD custom php upload settings
ADD docker/custom.ini /etc/php.d/z-custom.ini

# Add files for Google
COPY docker/ok.txt /usr/share/www/_ah/ok.html

# ADD supervisord config with setup
ADD docker/supervisord.conf /etc/supervisord.conf

#set to start automatically - supervisord, nginx
RUN yum install supervisor -y
RUN chkconfig supervisord on

ADD docker/mime.types /etc/nginx/mime.types

# Memcached is inside the Google instances and added to hosts file as 'memcache'
# This could be used instead of memcached on the instance. It as available on port 11211

# Install local Memcached
RUN yum install memcached -y

# Memcached runs at /var/run/memcached.sock
ADD docker/memcached /etc/init.d/memcached

# Setting health status for Google VM
RUN mkdir /var/www/public/_ah
RUN cp -r /usr/share/www/_ah/* /var/www/public/_ah/

EXPOSE 8080

# Add working dir to /var/www
#ADD . /var/www

# Fix dir perms
RUN chown -Rf apache:apache /var/www
RUN chown -R  nobody:nobody /var/lib/nginx/tmp
RUN chmod -R 755 /var/lib/nginx/tmp

# Executing supervisord
CMD ["supervisord", "-n"]

# build this docker
# sudo docker build -t=ganey/google-mvm-php .

# run this docker
# sudo docker run --name=gvm -v /e/websites/website-name:/var/www -p 8080:8080 ganey/google-mvm-php