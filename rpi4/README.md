[modeline]: # ( vim: set ft=markdown sts=4 sw=4 et: )


# Arch linux install guide raspberry pi 4

[install guide](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4)  

**don't forget to initialise keys**  
```
pacman-key --init
pacman-key --populate archlinuxarm
```

enable fan control  
edit `/boot/config.txt` inserting `dtoverlay=gpio-fan,gpiopin=14,temp=55000`  

[generate locales and set](https://wiki.archlinux.org/title/locale#Generating_locales)

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
`# systemctl disable --now systemd-networkd.socket`  
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

### mount nas as nfs

```
# mkdir /mnt/qnap
# pacman -S nfs-utils
```
edit `/etc/fstab` adding  
`qnap.local:/	/mnt/qnap  nfs 	defaults,timeo=900,retrans=5,_netdev	0	0`  
`# mount -a`  
                                                                                                                          



## install lamp stack

`# pacman -S apache mariadb php7 php7-apache php7-gd php7-imagick wget`

### apache

[apache](https://wiki.archlinux.org/title/Apache_HTTP_Server)

`# systemctl enable --now httpd`  


### php

[php](https://wiki.archlinux.org/title/Apache_HTTP_Server#PHP)  


In /etc/httpd/conf/httpd.conf, comment the line:

`#LoadModule mpm_event_module modules/mod_mpm_event.so`

and uncomment the line:

`LoadModule mpm_prefork_module modules/mod_mpm_prefork.so`

To enable PHP, add these lines to /etc/httpd/conf/httpd.conf:

* Place this at the end of the LoadModule list:

```
LoadModule php7_module modules/libphp7.so
AddHandler php-script .php
```
* Place this at the end of the Include list:
```
Include conf/extra/php7_module.conf
```
Restart httpd.service. 

**Test whether PHP works**

To test whether PHP was correctly configured, create a file called `test.php` in `/srv/http/` with the following contents:

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

[nextcloud in arch wiki](https://wiki.archlinux.org/title/Nextcloud)

[nextcloud docs](https://docs.nextcloud.com/server/latest/admin_manual/installation/source_installation.html)  

[php setup](https://docs.nextcloud.com/server/latest/admin_manual/installation/source_installation.html#prerequisites-label)  

In folder `/etc/php7/conf.d`  
create `gd.ini` with contents `extension=gd`  
create `mysql.ini`  
```
extension=pdo_mysql
extension=mysqli
```  

create `nextcloud.ini`   
```
memory_limit=512M
```

`# systemctl restart httpd`


[database config](https://docs.nextcloud.com/server/latest/admin_manual/configuration_database/linux_database_configuration.html)

```
# mysql -u root -p

mysql> CREATE DATABASE nextcloud DEFAULT CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci';
mysql> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost' IDENTIFIED BY 'password';
mysql> FLUSH PRIVILEGES;
mysql> \q
```
edit `/etc/my.cnf.d/server.cnf` and add under `[mariadb-10.6]`  
`innodb_read_only_compressed = 0`

`# systemctl restart mariadb`



[download server](https://nextcloud.com/install/#instructions-server)  
[installing from command line](https://docs.nextcloud.com/server/latest/admin_manual/installation/command_line_installation.html)  

```
# cd /srv/http
# wget https://download.nextcloud.com/server/releases/latest.tar.bz2
# tar jxvf latest.tar.bz2
# chown -R http.http nextcloud
# cd nextcloud
# php7 occ  maintenance:install --database "mysql" \
      --database-name "nextcloud"  --database-user "nextcloud" --database-pass "password" \
      --admin-user "admin" --admin-pass "password"
 
# chown -R http.http nextcloud
```

add webserver addresses to trusted domains in `/srv/http/nextcloud/config/config.php`

append to `/etc/httpd/conf/httpd.conf`

`Include conf/extra/nextcloud.conf`  

and uncomment  
`LoadModule rewrite_module modules/mod_rewrite.so`




create `/etc/httpd/conf/extra/nextcloud.conf`
```
Alias /nextcloud "/srv/http/nextcloud/"

<Directory /srv/http/nextcloud/>
  Require all granted
  AllowOverride All
  Options FollowSymLinks MultiViews

</Directory>

```



`# systemctl restart httpd`


## openvpn

[openvpn on arch wiki](https://wiki.archlinux.org/title/OpenVPN)  
[easy-rsa windows release](https://github.com/OpenVPN/easy-rsa/releases/)  
[easy-rsa usage on openvpn wiki](https://community.openvpn.net/openvpn/wiki/EasyRSA3-OpenVPN-Howto#PKIprocedure:ProducingyourcompletePKIontheCAmachine)  

```
$ yay -S openvpn easy-rsa  
$ cp -r /etc/easy-rsa/ .  
$ git clone git@github.com:TinCanTech/easy-tls.git  
$ cp easy-tls/easytls easy-rsa/  
$ cd easy-rsa  
$ easyrsa init-pki  
$ easyrsa build-ca nopass  
$ ./easytls init-tls
$ ./easytls build-tls-auth

```
### openvpn server
```
easyrsa build-server-full server3 nopass
./easytls inline-tls-auth server3 0


```
### openvpn clients



## ssmtp - simple mail client

[ssmtp](https://wiki.archlinux.org/title/SSMTP)  
(see [here](https://www.andrews-corner.org/downloads) for a 32-bit binary for windows)   

`$ yay -S ssmtp`
