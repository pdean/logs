# install LAMP stack

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

Note: The pipe between sock and fcgi is not allowed to be surrounded by a space! localhost can be replaced by any string. More here

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

### steps




    


