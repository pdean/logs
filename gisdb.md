[modeline]: # ( vim: set ft=markdown sts=4 sw=4 et: )

# GIS databases and tcl server install


## Postgresql


[Overview](https://wiki.archlinux.org/title/PostgreSQL)

    # pacman -S postgresql postgis
    # sudo -iu postgres
    [postgres]$ initdb -D /var/lib/postgres/data

    # systemctl enable --now postgresql

create users staff and gis as superusers

    # sudo -iu postgres
    [postgres]$ createuser --interactive

    $ createdb staff
    $ createdb gis -O gis

    $ psql -U gis
    # create extension postgis;

    # vim /var/lib/postgresql/data/pg_hba.conf

insert these lines after 127.0.0.1

    host    all             all             192.168.75.0/24            trust
    host    all             all             10.8.0.0/24            trust
    host    all             all             10.8.1.0/24            trust

    
    # vim /var/lib/postgresql/data/postgresql.conf

change listen_addresses to

    listen_addresses = '*'
    
    
    # systemctl restart postgresql
