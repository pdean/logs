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

**NOTE** rest of instructions are quite general, not just for rpi.

[generate locales and set](https://wiki.archlinux.org/title/locale#Generating_locales)

`# timedatectl set-timezone Australia/Brisbane`  
`# vi /etc/pacman.d/mirrorlist`  
`# pacman -Syu`  
`# pacman -S sudo mc vim`  
`# pacman -S bash-completion`  
`# pacman -S man-db man-pages`  
`# pacman -S git base-devel`  
`# visudo`  
`# useradd -m xxxx`  
`# passwd xxxx`  
`# usermod -aG wheel xxxx`  

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
                                                                                                                          
----------------------------------------------------------------------


## install lamp stack

`# pacman -S apache mariadb php7 php7-apache php7-gd php7-imagick wget`

**NOTE** I'm installing php7 because nextcloud won't work with 8.1 which is current on arch, only 8.0 or lower.  Hard to install 8.0 on rpi.

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
---------------------------------------------------------------------

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

--------------------------------------------------------------------

## openvpn

[openvpn on arch wiki](https://wiki.archlinux.org/title/OpenVPN)  
[easy-rsa windows release](https://github.com/OpenVPN/easy-rsa/releases/)  
[easy-rsa usage on openvpn wiki](https://community.openvpn.net/openvpn/wiki/EasyRSA3-OpenVPN-Howto#PKIprocedure:ProducingyourcompletePKIontheCAmachine)  

`$ yay -S openvpn`

### easyrsa3

```
$ cd
$ mkdir git
$ cd git
$ git clone git@github.com:OpenVPN/easy-rsa.git
$ git clone git@github.com:TinCanTech/easy-tls.git  
$ cd 
$ cp -r git/easy-rsa/easyrsa3/ .  
$ cp git/easy-tls/easytls easyrsa3/  
$ cd easyrsa3  
$ cp vars.example vars
$ ./easyrsa init-pki  
$ ./easyrsa build-ca nopass  
$ ./easyrsa gen-dh
$ ./easytls init-tls
$ ./easytls build-tls-auth

```

#### openvpn server

#### openvpn basic server config

`$ mkdir conf`  
`$ vim conf/basic-udp-server.conf`  
```
proto udp
port 1194
dev tun

server 10.200.0.0 255.255.255.0

persist-key
persist-tun
keepalive 10 60

push "route 192.168.1.0 255.255.255.0"
topology subnet

user  nobody
group nobody

daemon
log-append /var/log/openvpn.log
```

#### create server ovpn  

`$ mkdir files`  
`$ ./easyrsa build-server-full server3 nopass`  
`$ ./easytls inline-tls-auth server3 0 add-dh`  
`$ cat conf/basic-udp-server.conf pki/easytls/server3.inline >files/server3.ovpn`   


### server setup

#### iptables

```
# pacman -S iptables
# systemctl enable --now iptables

# iptables -A INPUT -i tun+ -j ACCEPT
# iptables -A FORWARD -i tun+ -j ACCEPT
# iptables -A FORWARD -s 10.200.0.0/24 -j ACCEPT
# iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
# iptables -t nat -A POSTROUTING -s 10.200.0.0/24 -o eth0 -j MASQUERADE

# iptables-save > /etc/iptables/iptables.rules
# systemctl restart iptables

```

#### ipforwarding

```
# vim /etc/sysctl.d/30-ipforward.conf

net.ipv4.ip_forward=1
net.ipv6.conf.default.forwarding=1
net.ipv6.conf.all.forwarding=1


```
#### start server
```
$ sudo cp easyrsa3/files/server3.ovpn /etc/openvpn/server/server3.conf
$ sudo systemctl enable --now openvpn-server@server3.service
```

### openvpn clients

#### openvpn basic client config  

```
$ vim conf/basic-udp-client.conf  

client
proto udp
remote mywebaddress
port 1194

dev tun
nobind

remote-cert-tls server
```

#### create client ovpn

`$ ./easyrsa build-client-full frednerk nopass`  
`$ ./easytls inline-tls-auth frednerk 1`  
`$ cat conf/basic-udp-client.conf pki/easytls/frednerk.inline >files/frednerk.ovpn`  




---------------------------------------------

## msmtp - simple mail client

[msmtp docs](https://marlam.de/msmtp/documentation/)  
[msmtp on arch wiki](https://wiki.archlinux.org/title/Msmtp)  
(see [here](https://www.andrews-corner.org/downloads) for a 32-bit binary for windows)   
(see [here](https://reinersmann.wordpress.com/tag/msmtp/) for example on windows)  

install on rpi  
`$ yay -S msmtp msmtp-mta s-nail`  
```
~/.msmtprc


# Set default values for all following accounts.
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        ~/.msmtp.log

# Gmail
account gmail
host smtp.gmail.com
port 587
user xxxxx@gmail.com
from xxxxx@gmail.com
password xxxxx@

# Set a default account
account default : gmail
```

`$ chmod 600 ~/.msmtprc`

```
/etc/msmtprc

aliases               /etc/aliases
```
```
/etc/aliases

# Example aliases file
     
# Send root to me
root: xxx@gmail.com
   
# Send everything else to me
default: zzz@gmail.com
```

test  
`$ printf "Subject: Test\nhello there username." | msmtp -a default username@domain.com`


---------------------------------------------

## send with mutt

`echo "find attached your ovpn file"|mutt -a easyrsa3/files/frednerk.ovpn -s "frednerk.ovpn" -- xxx@gmail.com

```
~/.muttrc


set sendmail="/usr/bin/msmtp"
set use_from=yes
set realname="xxx yyy"
set from=zzzz@gmail.com
set envelope_from=yes
```

---------------------------------------

## script to create client certificate and mail

see [openvpn](https://github.com/pdean/logs/tree/main/openvpn) for more up to date instructions
