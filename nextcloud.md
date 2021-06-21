# install LAMP stack

https://wiki.archlinux.org/title/Category:Web_applications  

## apache

https://wiki.archlinux.org/title/Apache_HTTP_Server


## mariadb

https://wiki.archlinux.org/title/MariaDB  

## php

https://wiki.archlinux.org/title/PHP  

## nextcloud

https://wiki.archlinux.org/title/Nextcloud

### steps

    # pacman -S apache mariadb nextcloud php-fpm php-intl


    # systemctl enable --now httpd

Enable proxy modules:

	/etc/httpd/conf/httpd.conf

	LoadModule proxy_module modules/mod_proxy.so  
	LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so
	    


    # mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
    # systemctl enable --now mariadb
    



