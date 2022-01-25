[modeline]: # ( vim: set ft=markdown sts=4 sw=4 et: )


# Arch linux install guide raspberry pi 4

[install guide](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4)  

`# timedatectl set-timezone Australia/Brisbane`  

`# pacman -Syu`  
`# pacman -S sudo mc vim`  
`# pacman -S bash-completion`  
`# pacman -S man-db man-pages`  
`# pacman -S git base-devel`  
`# visudo`  

### avahi

`# pacman -S avahi nss-mdns`  
[configure avahi](https://wiki.archlinux.org/title/avahi)  

Avahi provides local hostname resolution using a "hostname.local" naming scheme. To enable it, install the nss-mdns package and start/enable `avahi-daemon.service`.

Then, edit the file /etc/nsswitch.conf and change the hosts line to include `mdns_minimal [NOTFOUND=return]` before `resolve` and `dns`:

`hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns`


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
