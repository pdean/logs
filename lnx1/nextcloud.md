# install LAMP stack and nextcloud

https://wiki.archlinux.org/title/Category:Web_applications  

    # pacman -S apache mariadb nextcloud php-fpm php-intl

## apache

https://wiki.archlinux.org/title/Apache_HTTP_Server

    # systemctl enable --now httpd

Enable proxy modules:

    /etc/httpd/conf/httpd.conf

    LoadModule proxy_module modules/mod_proxy.so  
    LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so
	
Create /etc/httpd/conf/extra/php-fpm.conf with the following content:

    DirectoryIndex index.php index.html
    <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/php-fpm/php-fpm.sock|fcgi://localhost/"
    </FilesMatch>

And include it at the bottom of `/etc/httpd/conf/httpd.conf`:

    Include conf/extra/php-fpm.conf

Note: The pipe between sock and fcgi is not allowed to be surrounded by a space! localhost can be replaced by any string. More [here](https://httpd.apache.org/docs/2.4/mod/mod_proxy_fcgi.html)

You can configure PHP-FPM in /etc/php/php-fpm.d/www.conf, but the default setup should work fine.
Uncomment the following line  

    env[PATH] = /usr/local/bin:/usr/bin:/bin    

Start and enable php-fpm.service. Restart httpd.service.

#### Test whether PHP works

To test whether PHP was correctly configured, create a file called test.php in your Apache DocumentRoot directory (e.g. /srv/http/ or ~<username>/public_html/) with the following contents:

    <?php phpinfo(); ?>

Then go to http://localhost/test.php or http://localhost/~<username>/test.php as appropriate. 

## mariadb

https://wiki.archlinux.org/title/MariaDB  


    # mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
    # systemctl enable --now mariadb
    

## nextcloud

https://wiki.archlinux.org/title/Nextcloud

### config

unchanged from install

### mariadb

    # mysql -u root -p

    mysql> CREATE DATABASE nextcloud DEFAULT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci';
    mysql> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost' IDENTIFIED BY 'password';
    mysql> FLUSH PRIVILEGES;
    mysql> \q


### php

make following changes to /etc/php/php.ini

	409c409
	< memory_limit = 128M
	---
	> memory_limit = 512M
	694c694
	< post_max_size = 8M
	---
	> post_max_size = 10G
	846c846
	< upload_max_filesize = 2M
	---
	> upload_max_filesize = 10G
	907,908c907,908
	< ;extension=bcmath
	< ;extension=bz2
	---
	> extension=bcmath
	> extension=bz2
	916c916
	< ;extension=gd
	---
	> extension=gd
	918,919c918,919
	< ;extension=gmp
	< ;extension=iconv
	---
	> extension=gmp
	> extension=iconv
	921c921
	< ;extension=intl
	---
	> extension=intl
	923c923
	< ;extension=mysqli
	---
	> extension=mysqli
	925c925
	< ;zend_extension=opcache
	---
	> zend_extension=opcache
	927c927
	< ;extension=pdo_mysql
	---
	> extension=pdo_mysql
	958c958
	< ;date.timezone =
	---
	> date.timezone = Australia/Brisbane
	1005c1005
	< ;intl.default_locale =
	---
	> ;intl.default_locale = en_AU.UTF-8
	1338c1338
	< ;session.save_path = "/tmp"
	---
	> session.save_path = "/tmp"
	1765c1765
	< ;opcache.enable=1
	---
	> opcache.enable=1
	1771c1771
	< ;opcache.memory_consumption=128
	---
	> opcache.memory_consumption=128
	1774c1774
	< ;opcache.interned_strings_buffer=8
	---
	> opcache.interned_strings_buffer=8
	1778c1778
	< ;opcache.max_accelerated_files=10000
	---
	> opcache.max_accelerated_files=10000
	1796c1796
	< ;opcache.revalidate_freq=2
	---
	> opcache.revalidate_freq=1
	1803c1803
	< ;opcache.save_comments=1
	---
	> opcache.save_comments=1

### php-fpm

    # vim /etc/php/php-fpm.d/nextcloud.conf

    [nextcloud]
    user = nextcloud
    group = nextcloud
    listen = /run/nextcloud/nextcloud.sock
    env[PATH] = /usr/local/bin:/usr/bin:/bin
    env[TMP] = /tmp

    ; should be accessible by your web server
    listen.owner = http
    listen.group = http

    pm = dynamic
    pm.max_children = 15
    pm.start_servers = 2
    pm.min_spare_servers = 1
    pm.max_spare_servers = 3

then 

    # mkdir /etc/systemd/system/php-fpm.service.d 
    # systemctl edit php-fpm.service

    [Service]
    # Your data directory
    ReadWritePaths=/var/lib/nextcloud/data

    # Optional: add if you've set the default apps directory to be writable in config.php
    ReadWritePaths=/usr/share/webapps/nextcloud/apps

    # Optional: unnecessary if you've set 'config_is_read_only' => true in your config.php
    ReadWritePaths=/usr/share/webapps/nextcloud/config
    ReadWritePaths=/etc/webapps/nextcloud/config

    # Optional: add if you want to use Nextcloud's internal update process
    # ReadWritePaths=/usr/share/webapps/nextcloud



### apache 

    # cp /usr/share/doc/nextcloud/apache.example.conf /etc/httpd/conf/extra/nextcloud.conf

*COMMENT OUT* everything from virtual host down  
And include it in /etc/httpd/conf/httpd.conf:

    Include conf/extra/nextcloud.conf

then 

    # pacman -S mod_itk

then

    # vim	/etc/httpd/conf/extra/nextcloud.conf

	   <IfModule mpm_itk_module>
	       AssignUserId nextcloud nextcloud
	   </IfModule>

then

     # vim 	/etc/httpd/conf/httpd.conf

	LoadModule mpm_itk_module modules/mpm_itk.so

and comment and uncomment

	#LoadModule mpm_event_module modules/mod_mpm_event.so  
	LoadModule mpm_prefork_module modules/mod_mpm_prefork.so  





then 

    # systemctl restart php-fpm  
    # systemctl restart httpd  

### /tmp disable automatic mount in ram 

    # systemctl mask tmp.mount


### nextcloud config

  
