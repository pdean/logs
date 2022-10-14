# vim: set sts=4 sw=4 tw=80 et ft=tcl:

#"ROAD_SECTION_ID","CARRIAGEWAY_CODE","TDIST_START","Latitude","Longitude","Description","AADT","AADTInterventionCategory"
#"1000","1","0.000","-27.50228800","153.40210000","1000_1|EAST COAST ROAD",1959,"Cat C"
#"1000","1","0.010","-27.50222000","153.40216600","1000_1|EAST COAST ROAD",1959,"Cat C"
#

namespace path {::tcl::mathop ::tcl::mathfunc}

package require tdbc
package require tdbc::postgres

set conninfo [list -host 192.168.1.59 -port 5432 -db gis -user gis ]
tdbc::postgres::connection create db {*}$conninfo


db allrows { DROP SCHEMA IF EXISTS tmr CASCADE}

db allrows { CREATE SCHEMA tmr }

db allrows {
    CREATE table tmr.roads (id serial primary key, section text, code text)}

db allrows {
    CREATE table tmr.names (id serial primary key, name text)}

db allrows {
    CREATE table tmr.points (
        id serial primary key, road_id integer, name_id integer, 
        tdist float, geog geography(point, 4283))}
    
db allrows {
    CREATE table tmr.segments (
        id serial primary key, road_id integer, name_id integer, 
        pt1_id integer, pt2_id integer, 
        tstart float, tend float,
        geog geography(linestring, 4283))}

db allrows { CREATE INDEX idx_points_geog on tmr.points USING gist(geog) }    
db allrows { CREATE INDEX idx_segments_geog on tmr.segments USING gist(geog) }   

    
db allrows {
    create or replace view tmr.segs as
    select 
        s.id, 
        r.section, r.code, 
        n.name, 
        s.tstart, s.tend, 
        s.geog
    from
        tmr.segments as s 
        join tmr.roads as r on (r.id = s.road_id)
        join tmr.names as n on (n.id = s.name_id)
}
    

db allrows {
    create or replace view tmr.pts as
    select 
        p.id, 
        r.section, r.code, 
        n.name, 
        p.tdist, 
        p.geog
    from
        tmr.points as p 
        join tmr.roads as r on (r.id = p.road_id)
        join tmr.names as n on (n.id = p.name_id)
}
    
    
    
    
proc run {file} {
    global db
    set in [open $file r]
    # discard header line
    puts [gets $in]

    set osection {}
    set ocode {}
    set oname {}
    set odesc {}
    set new 0
    set opt {}
    set olat {}
    set olon {}
    set odist {}

    set max 0

    set n 0
    db transaction {
        while {[gets $in line] >= 0} {
            set line [string map {\" ""} $line]
            set line [split $line ,]
            lassign $line  \
                section code dist lat lon desc aadt aadtic
            lassign [split $desc |] lane name

            if {$n && [abs [- $dist $odist]] > [/ 15.0 1000.0]} {
                set new 1
            }

           if {$section ne $osection || $code ne $ocode } {
                set osection $section
                set ocode $code
                set new 1

                lassign [db allrows -as lists {
                    insert into tmr.roads (section, code)
                    values (:section, :code) returning id }] road_id
                puts "section $road_id $section $code"
            }
            
            

           if {$desc ne $odesc} {
                set odesc $desc

                lassign [db allrows -as lists {
                    insert into tmr.names (name)
                    values (:desc) returning id }] name_id 
                puts "description $name_id $desc"
            
                set len [string length $desc]
                if {$len > $max} {
                    set max $len
                }
            }

            set lat [double $lat]
            set lon [double $lon]
            set dist [double $dist]
            lassign [db allrows -as lists {
                insert into tmr.points
                   (road_id, name_id, tdist, geog)
                values (:road_id, :name_id, cast(:dist as float), 
                   ST_SetSRID(ST_Point(cast(:lon as float), cast(:lat as float)), 4283)::geography )
                returning id }]  pt   
            incr n

            if {!$new} {
                db allrows {
                    insert into tmr.segments
                        (road_id, name_id, pt1_id, pt2_id, 
                            tstart, tend,  geog)
                    values(:road_id, :name_id, :opt, :pt, 
                            cast(:odist as float), cast(:dist as float), 
                       ST_SetSRID(
                           ST_Makeline(
                               ST_Point(cast(:olon as float), cast(:olat as float)),
                               ST_Point(cast(:lon as float), cast(:lat as float))), 4283)::geography )
               } 
            }
            set opt $pt
            set olat $lat
            set olon $lon
            set odist $dist
            set new 0
        }
    }
    close $in
    puts $n
    puts "max desc $max"
}

set dir .
set file "Road location and traffic data_20200129.txt"
set file [file join $dir $file]
puts $file
run $file
puts finished
