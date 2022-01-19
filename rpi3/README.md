[modeline]: # ( vim: set ft=markdown sts=4 sw=4 et: )


# Arch linux install guide raspberry pi 4

[Read install guide here](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4)

`# pacman -S apache mariadb php wget`

## apache


## php


## mariadb

```
# mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
# systemctl enable --now mariadb

```

## nextcloud

[nextcloud docs](https://docs.nextcloud.com/server/latest/admin_manual/installation/source_installation.html)  
[download server](https://nextcloud.com/install/#instructions-server)  

select 'web installer' tab 

```
wget https://download.nextcloud.com/server/installer/setup-nextcloud.php 
```
