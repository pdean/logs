[modeline]: # ( vim: set ft=markdown sts=4 sw=4 et: )


# Arch linux install guide raspberry pi 4

[install guide](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4)  

`# pacman -Syu`  
`# pacman -S sudo mc vim`  
`# pacman -S bash-completion`  
`# pacman -S man-db man-pages`  
`# pacman -S avahi nss-mdns`  
[configure avahi](https://wiki.archlinux.org/title/avahi)  
`# systemctl disable --now systemd-resolved.service`  




## set static ip

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
reboot

                                                                                                                          
## install lamp stack

`# pacman -S apache mariadb php wget`

### apache


### php


### mariadb

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
