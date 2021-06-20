[modeline]: # ( vim: set ft=markdown sts=4 sw=4 et : )

# GIS databases and tcl server install


## Postgresql


[Overview](https://wiki.archlinux.org/title/PostgreSQL)

    # pacman -S postgresql postgis zip unzip
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

    host    all             all             192.168.0.0/16            trust
    host    all             all             10.8.0.0/16            trust

    
    # vim /var/lib/postgresql/data/postgresql.conf

change listen_addresses to

    listen_addresses = '*'
    
    
    # systemctl restart postgresql

## create databases

### dcdb

Log in to [qspatial](https://qldspatial.information.qld.gov.au/catalogue/custom/index.page)
 and search for 'cadastre', select whole of queensland GDA2020. 
Get download link from email, download and unzip.

    $ ogr2ogr -progress -overwrite -skipfailures  -f "PostgreSQL" PG:"host=localhost user=gis dbname=gis active_schema=qspatial" DP_QLD_DCDB_WOS_CUR_GDA2020.gdb --config PG_USE_COPY YES

### scdb

Log in to [qspatial](https://qldspatial.information.qld.gov.au/catalogue/custom/index.page) 
and search for 'control'.  Download and unzip.

    $ ogr2ogr -progress -overwrite -skipfailures  -f "PostgreSQL" PG:"host=localhost user=gis dbname=gis active_schema=qspatial " data.gdb --config PG_USE_COPY YES 

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

### tmr 1km marks


Log in to [qspatial](https://qldspatial.information.qld.gov.au/catalogue/custom/index.page)
 and search for '1km'. Should be first in list.  Download and unzip.

    $ ogr2ogr -progress -overwrite -skipfailures  -f "PostgreSQL" PG:"host=localhost user=gis dbname=gis active_schema=qspatial" data.gdb --config PG_USE_COPY YES


### tmr road location database

Download from [here](https://www.data.qld.gov.au/dataset/road-location-and-traffic-data/resource/daab3617-077f-450a-a1c0-57c26d8ba47c) and unzip

Need to resort the file

    $ file="Road location and traffic data.txt"
    $ tail -n +2 "$file" |sort -o sort.txt -t ',' -k 1,1 -k 2,2 -k 3,3n

Now it get complex.  The program to load the data to postgres is written in scheme. [roaddb.scm](https://github.com/pdean/logs/blob/main/roaddb.scm)

    # pacman -S chicken
    $ chicken-install -s postgresql
    $ chicken-csc roaddb.scm
    $ ./roaddb

#### create views

get [view.sql](https://github.com/pdean/logs/blob/main/view.sql)

    psql -U gis <view.sql

    

## Install tclhttpd

install instructions [here](https://github.com/pdean/logs/tree/main/tclhttpd)

We're just gonna copy the whole /usr/local from the gis machine!

    # rsync -azv gis:/usr/local /usr

Now we need to install tcl, tdom and tcllib.  Use pacman to install tcl

    # pacman -S tcl

and yay to install tdom from the AUR

    $ yay tdom

then select the number and default all the prompts.

and yay to install tcllib from the AUR

    $ yay tcllib

then select the number and default all the prompts.

copy [zipper](https://github.com/pdean/logs/tree/main/zipper) folder to /usr/local/lib  

get the [tclhttpd.service](https://github.com/pdean/logs/blob/main/tclhttpd.service)

    $ sudo cp tclhttpd.service /etc/systemd/system
    $ sudo systemctl enable --now tclhttpd.service

check it's running

    $ firefox localhost:8015

need to edit all scripts to use new database   
they live in `/usr/local/tclhttpd/custom`  
then `# systemctl restart tclhttpd`  
