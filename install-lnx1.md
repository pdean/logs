
# Arch linux install guide

[Read install guide here](https://wiki.archlinux.org/title/Installation_guide)

## Specific instructions for lnx1


### create install disks

Procure 2 new usb sticks, say 4gb.

On windows box, download

- [Rufus](https://rufus.ie/en_US/). 
- [Gparted iso](https://gparted.org/download.php). Choose i686.
- [Arch Linux install iso](https://archlinux.org/download/).

Using Rufus, burn Gparted and Arch to usb.

### partition hard disk

- Boot Gparted.  Hit F11 early in boot process.
- Delete existing partitions
- Create GPT partition table
- Create partitions
  1. /dev/nvme0n1p1  fat32 512mb boot,esp
  1. /dev/nvme0n1p2  swap  8192mb
  1. /dev/nvme0n1p3  ext4  rest of disk

### boot arch live

Boot Arch usb. F11.  
Select Arch Linux install medium.  

### Commands

- Check boot mode efi `# ls /sys/firmware/efi/efivars`
- Check net connection `# ip a`
- Check internet `# ping archlinux.org`
- Update clock  `# timedatectl set-ntp true`
- Check partitioning `# fdisk -l`
- Mount disk

```
        # mkswap /dev/nvme0n1p2
        # swapon /dev/nvme0n1p2
        # mount /dev/nvme0n1p3 /mnt
        # mkdir /mnt/efi
        # mount /dev/nvme0n1p1 /mnt/efi
```

### Install essential packages

`# pacstrap /mnt base base-devel git linux linux-firmware networkmanager vim mc vi sudo man-db man-pages texinfo intel-ucode`  
`# genfstab -U /mnt >> /mnt/etc/fstab`  
`# arch-chroot /mnt`


```
# ln -sf /usr/share/zoneinfo/Australia/Brisbane /etc/localtime
# hwclock --systohc
# vim /etc/locale.gen
    uncomment en_AU.UTF-8 and en_US.UTF-8
# locale-gen
# vim /etc/locale.conf
    LANG=en_AU.UTF-8
# vim /etc/hostname
    lnx1
# vim /etc/hosts
    127.0.0.1	localhost
    ::1		localhost
    127.0.1.1	lnx1.localdomain	lnx1
# passwd 
    N...
```

### Install grub

```
# pacman -Syu
# pacman -S grub efibootmgr
# grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
# grub-mkconfig -o /boot/grub/grub.cfg

# systemctl enable NetworkManager
# exit
# poweroff
```

Now remove usb and restart.

----------------------------------

## After reboot

### login as root

login: root  
password: N...

### create staff user

```
# useradd -m -G wheel staff  
# passwd staff
    J...
# visudo
    uncomment line with group wheel NOPASSWD
```  

### Install graphical interface


`# pacman -S xorg xorg-server gdm mate mate-extra bash-completion openssh firefox nm-connection-editor network-manager-applet`  
`# systemctl enable --now gdm`  

### login as staff

Select *staff* hit enter.  Before entering password, select settings wheel in lower right, and pick *mate* then enter password .

### setup static ip etc

open connection editor in upper right tray.  
edit wired connection
pick ipv4 tab 
select manual  
set ip 192.168.75.3 mask 24 gateway 192.168.75.254  

**NOTE**  need to fix DNS entry on NSSBS2011  

### fix local name lookup issues

`$ sudo touch /etc/samba/smb.conf`  
`$ sudo systemctl enable --now nmb`  
`$ sudo systemctl enable --now winbind`  

### fix isssue with gdm going to sleep

`$ sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'`

### install yay

`$ mkdir build`  
`$ cd build`  
`$ git clone https://aur.archlinux.org/yay.git`  
`$ cd yay `  
`$ makepkg -si`  

### configure ssh

`$ ssh-keygen `  
`$ ssh-copy-id staff@gis`  
`$ ssh-copy-id staff@web`  
`$ sudo systemctl enable --now sshd`  


### check for updates 

`$ yay`  

### rsync

`$ yay -S rsync`  

follow instructions [here](https://wiki.archlinux.org/title/rsync#Automated_backup_with_SSH) to allow root rsync  

copy backups from openvpn server  
    rsync -azv 192.168.75.109:/mnt/backups/usb1/sys_save /home/ws0901bkp       


copy backups from web server  
     rsync -azv 192.168.75.209:/mnt/backup/sys_save /home/arch1601bkp


