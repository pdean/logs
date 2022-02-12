
# openvpn on linux

## openvpn server/client config

### server port forward

```
/etc/sysctl.d/30-ipforward.conf

net.ipv4.ip_forward=1
net.ipv6.conf.default.forwarding=1
net.ipv6.conf.all.forwarding=1
```

### server iptables

install, enable and start iptables

```
# iptables -t nat -A POSTROUTING -s 10.200.0.0/24 -o eth0 -j MASQUERADE
# iptables-save -f /etc/iptables/iptables.rules
```


### create a new pki in current directory (use root login)

need to add ssh key to github first

```
pkitest.sh

#!/bin/sh

rm -r git
rm -r easyrsa3
mkdir git
cd git
git clone git@github.com:OpenVPN/easy-rsa.git
git clone git@github.com:TinCanTech/easy-tls.git
cd ..
cp -r git/easy-rsa/easyrsa3/ .
cp git/easy-tls/easytls easyrsa3/
cd easyrsa3
cp vars.example vars
./easyrsa init-pki
./easyrsa --batch build-ca nopass
./easyrsa gen-dh
./easytls init-tls
./easytls build-tls-crypt

```

### create test server and client key

in same directory as above

```
testconf.sh


#!/bin/sh

SERVER=server3
CLIENT=client3
PORT=1196

cd easyrsa3
mkdir ovpn
mkdir conf
cd conf

sed '/^ *$/d;/^#/d;/^;/d;/^ca/d;/^cert/d;/^key/d;/^dh/d;/^tls/d;s/CBC/GCM/;s/10\.8/10.200/'\
	/usr/share/openvpn/examples/server.conf >basicserver.conf
sed -i "s/1194/$PORT/" basicserver.conf
printf "\n\ntopology subnet\n"	>>basicserver.conf
printf "push \"route 192.168.1.0 255.255.255.0\"\n\n" >>basicserver.conf
printf "user  nobody\ngroup nobody\n\n" >>basicserver.conf
printf "#daemon\n#log-append /var/log/openvpn.log\n" >>basicserver.conf

sed '/^ *$/d;/^#/d;/^;/d;/^ca/d;/^cert/d;/^key/d;/^tls/d;s/CBC/GCM/;s/my-server-1/xxxxxxxxxxxxxxxxxxx/'\
       	/usr/share/openvpn/examples/client.conf >basicclient.conf
sed -i "s/1194/$PORT/" basicclient.conf

cd ..
./easyrsa build-server-full $SERVER nopass
./easytls inline-tls-crypt $SERVER add-dh
cat conf/basicserver.conf pki/easytls/${SERVER}.inline >ovpn/${SERVER}.ovpn
cp ovpn/${SERVER}.ovpn /etc/openvpn/server/${SERVER}.conf
systemctl enable --now openvpn-server@${SERVER}.service

./easyrsa build-client-full $CLIENT nopass
./easytls inline-tls-crypt $CLIENT
cat conf/basicclient.conf pki/easytls/${CLIENT}.inline >ovpn/${CLIENT}.ovpn
echo "your ovpn file"|mutt -s ${CLIENT}.ovpn -a ovpn/${CLIENT}.ovpn -- xxxxxxxxxxxxxxxxx


```

# easyrsa on windows

[easyrsa on github](https://github.com/OpenVPN/easy-rsa)  
[easytls on github](https://github.com/TinCanTech/easy-tls)  
[easrsa3 howto](https://community.openvpn.net/openvpn/wiki/EasyRSA3-OpenVPN-Howto#PKIprocedure:ProducingyourcompletePKIontheCAmachine)  

## install on network drive w:

* copy C:/Program Files/OpenVPN to w:  
* download easyrsa windows release, unzip and copy contents to W:/OpenVPN/easy-rsa
* download easytls script and copy to W:/OpenVPN/easy-rsa
* create W:/OpenVPN/easy-rsa/vars with

        export EASYTLS_base_dir="W:/OpenVPN"  
        export EASYTLS_tmp_dir="W:/tmp"  
* create w:/tmp
* copy basic config files from old location to easy-rsa/conf
* create easy-rsa/ovpn 
* start shell with EasyRSA-Start.bat
* initialize pki

        ./easyrsa init-pki
        ./easyrsa --batch build-ca nopass
        ./easyrsa gen-dh
        ./easytls init-tls
        ./easytls build-tls-crypt

* create server key

        export SERVER=server1
        ./easyrsa build-server-full $SERVER nopass
        ./easytls inline-tls-crypt $SERVER add-dh
        cat conf/basicserver.conf pki/easytls/${SERVER}.inline >ovpn/${SERVER}.ovpn

* install server key (see linux above)
* create client keys

        export CLIENT=client1
        ./easyrsa build-client-full $CLIENT nopass
        ./easytls inline-tls-crypt $CLIENT
        cat conf/basicclient.conf pki/easytls/${CLIENT}.inline >ovpn/${CLIENT}.ovpn

* script to create and email all client keys in a file

        shouldn't be hard



        
