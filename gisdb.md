[modeline]: # ( vim: set ft=markdown sts=4 sw=4 et : )

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

## create databases

### dcdb

Log in to qspatial and search for 'cadastre', select whole of queensland GDA2020. Get download link from email, download and unzip.

    $ ogr2ogr -progress -overwrite -skipfailures  -f "PostgreSQL" PG:"host=localhost user=gis dbname=gis active_schema=qspatial" DP_QLD_DCDB_WOS_CUR_GDA2020.gdb --config PG_USE_COPY YES

### scdb

Log in to qspatial and search for 'control'.  Download and unzip.

    $ ogr2ogr -progress -overwrite -skipfailures  -f "PostgreSQL" PG:"host=gis user=gis dbname=gis active_schema=qspatial " data.gdb --config PG_USE_COPY YES 

    $ vim code.sql

insert following

    alter table qspatial.survey_control_data_qld add column if not exists code integer;

    update qspatial.survey_control_data_qld
        set code = 2 |
	      (((ahdacc_de is not null) or (ahdcls_de is not null) or (ahdfix_de is not null))::int << 2) |
              (((gda2020fix_de is not null) and (gda2020fix_de like 'CADASTRAL%'))::int << 3) |
	      (((gda2020fix_de is not null) and (gda2020fix_de not like 'SCALED%'))::int << 4) |
	      (((ahdacc_de is not null) and (ahdacc_de ~ '^[1-3]'))::int << 5) |
              (((gda2020lineage_de is not null) and (gda2020lineage_de ~ 'Datum%'))::int << 6) |
	      (((mrkcnd_de is not null) and (mrkcnd_de not like 'GOOD%'))::int << 7);

then

    $ psql -U gis <code.sql
