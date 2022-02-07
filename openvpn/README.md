```
pkitest.sh

#!/bin/sh

cd
rm -r easyrsagit
rm -r easyrsa3
mkdir easyrsagit
cd easyrsagit
git clone git@github.com:OpenVPN/easy-rsa.git
git clone git@github.com:TinCanTech/easy-tls.git
cd
cp -r easyrsagit/easy-rsa/easyrsa3/ .
cp easyrsagit/easy-tls/easytls easyrsa3/
cd easyrsa3
cp vars.example vars
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-dh
./easytls init-tls
./easytls build-tls-crypt
```

```
testconf.sh

#!/bin/sh

cd
cd easyrsa3
rm -r conf
mkdir conf
cd conf

grep -Ev "^\s*$|^#|^;|^ca|^cert|^tls|^key|^dh" /usr/share/openvpn/examples/server.conf >basicserver.conf
sed -i 's/10\.8/10.200/' basicserver.conf


grep -Ev "^\s*$|^#|^;|^ca|^cert|^tls|^key|^dh" /usr/share/openvpn/examples/client.conf >basicclient.conf
sed -i 's/my-server-1/xxxxxxx.net/' basicclient.conf

