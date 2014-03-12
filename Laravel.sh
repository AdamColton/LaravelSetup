#!/bin/bash

# Refs:
#  http://www.unixmen.com/install-lemp-server-nginx-mysql-mariadb-php-ubuntu-13-10-server/
# Todo:
#  pull password from args, or settings,

apt-get update -y
apt-get upgrade -y

dbPass=password

debconf-set-selections <<EOF
mysql-server-5.1 mysql-server/root_password password $dbPass
mysql-server-5.1 mysql-server/root_password_again password $dbPass
phpmyadmin phpmyadmin/app-password-confirm $dbPass
phpmyadmin phpmyadmin/dbconfig-install boolean true
phpmyadmin phpmyadmin/mysql/admin-pass password $dbPass
phpmyadmin phpmyadmin/mysql/app-pass $dbPass
phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2
EOF

apt-get -y install git-core nginx mysql-server mysql-client php5 php5-fpm php5-mysql php5-cli phpmyadmin

# Config files
cp default /etc/nginx/sites-available/default
cp php.ini /etc/php5/fpm/php.ini

#link phpmyadmin to nginx
ln -s /usr/share/phpmyadmin/ /var/www/laravel/public/

# fix mcrypt error
ln -s /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available/mcrypt.ini
php5enmod mcrypt
service php5-fpm restart

# setting up laravel
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
composer create-project laravel/laravel /var/www/laravel/
chgrp -R www-data /var/www/laravel
chmod -R 775 /var/www/laravel/app/storage


service nginx start
service php5-fpm restart