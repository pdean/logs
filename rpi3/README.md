[modeline]: # ( vim: set ft=markdown sts=4 sw=4 et: )


# Arch linux install guide raspberry pi 4

[install guide](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4)  

enable fan control  
edit `/boot/config.txt` inserting `dtoverlay=gpio-fan,gpiopin=14,temp=55000`  

`# timedatectl set-timezone Australia/Brisbane`  
`# vi /etc/pacman.d/mirrorlist`  
`# pacman -Syu`  
`# pacman -S sudo mc vim`  
`# pacman -S bash-completion`  
`# pacman -S man-db man-pages`  
`# pacman -S git base-devel`  
`# visudo`  
`# useradd -m peter`  
`# passwd peter`  
`# usermod -aG wheel peter`  

### avahi

[avahi](https://wiki.archlinux.org/title/avahi)  
`# pacman -S avahi nss-mdns`  

Avahi provides local hostname resolution using a "hostname.local" naming scheme. To enable it, install the nss-mdns package and start/enable `avahi-daemon.service`.

Then, edit the file /etc/nsswitch.conf and change the hosts line to include `mdns4_minimal [NOTFOUND=return]` before `resolve` and `dns`:

`hosts: mymachines mdns4_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns`


`# systemctl disable --now systemd-resolved.service`  




### set static ip

[netctl](https://wiki.archlinux.org/title/netctl)


`# vim /etc/netctl/eth0`
```
Description='A basic static ethernet connection'
Interface=eth0
Connection=ethernet
IP=static
Address=('192.168.1.23/24')
Gateway='192.168.1.1'
DNS=('192.168.1.1')
```

`# netctl enable eth0`  
`# systemctl disable --now systemd-networkd.service`  
`# rm /etc/resolv.conf`  
`# resolvconf -u`  
`# reboot  `

### install yay

```
$ mkdir build
$ cd build
$ git clone https://aur.archlinux.org/yay.git
$ cd yay
$ makepkg -si
```
                                                                                                                          
## install lamp stack

`# pacman -S apache mariadb php wget`

### apache

[apache](https://wiki.archlinux.org/title/Apache_HTTP_Server)

`# systemctl enable --now httpd`  


### php

[php](https://wiki.archlinux.org/title/Apache_HTTP_Server#PHP)  

`# pacman -S php-apache`  

In /etc/httpd/conf/httpd.conf, comment the line:

`#LoadModule mpm_event_module modules/mod_mpm_event.so`

and uncomment the line:

`LoadModule mpm_prefork_module modules/mod_mpm_prefork.so`

To enable PHP, add these lines to /etc/httpd/conf/httpd.conf:

* Place this at the end of the LoadModule list:

```
LoadModule php_module modules/libphp.so
AddHandler php-script .php
```
* Place this at the end of the Include list:
```
Include conf/extra/php_module.conf
```
Restart httpd.service. 

**Test whether PHP works**

To test whether PHP was correctly configured, create a file called test.php in your Apache DocumentRoot directory (e.g. /srv/http/ or ~<username>/public_html/) with the following contents:

```
<?php phpinfo(); ?>
```


### mariadb

[mariadb](https://wiki.archlinux.org/title/MariaDB)

```
# mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
# systemctl enable --now mariadb

```

## nextcloud

[nextcloud docs](https://docs.nextcloud.com/server/latest/admin_manual/installation/source_installation.html)  

[database config](https://docs.nextcloud.com/server/latest/admin_manual/configuration_database/linux_database_configuration.html)



[download server](https://nextcloud.com/install/#instructions-server)  

select 'web installer' tab 

```
wget https://download.nextcloud.com/server/installer/setup-nextcloud.php 
```
