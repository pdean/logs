# vim: set sts=4 sw=4 tw=80 et ft=tcl:

# file format (header removed by sort.sh)
#1000,1,0.000,-27.50228800,153.40210000,1000_1|EAST COAST ROAD,1684,Cat C
#1000,1,0.010,-27.50222000,153.40216600,1000_1|EAST COAST ROAD,1684,Cat C
#1000,1,0.020,-27.50215600,153.40223700,1000_1|EAST COAST ROAD,1684,Cat C
#
namespace path {::tcl::mathop ::tcl::mathfunc}

package require tdbc
package require tdbc::postgres
   
proc run {file} {

    set n 0
    set osection {}
    set ocode {}
    set odesc {}
    set opt_id {}
    set olat {}
    set olon {}
    set odist {}
    set road_id 0
    set pt_id 0

    set conninfo [list -host localhost -db gis -user gis ]
    tdbc::postgres::connection create db {*}$conninfo

    db allrows { DROP SCHEMA IF EXISTS tmr3 CASCADE}
    db allrows { CREATE SCHEMA tmr3 }
    db allrows {
        CREATE table tmr3.roads (
        id serial primary key, section text, code text, description text)}
    db allrows {
        CREATE table tmr3.points (
            id serial primary key, road_id integer, 
            tdist float, geog geography(point, 4283))}
    db allrows {
        CREATE table tmr3.segments (
            id serial primary key,  
            p1_id integer, p2_id integer, 
            geog geography(linestring, 4283))}


    set dbroad [ db prepare {
        insert into tmr3.roads (section, code, description)
        values (:section, :code, :desc) 
        returning id 
    }]

    set dbpoint [ db prepare {
        insert into tmr3.points (road_id, tdist, geog)
        values (:road_id, cast(:dist as float), 
           ST_SetSRID(
               ST_Point(cast(:lon as float), 
                        cast(:lat as float)), 4283)::geography )
        returning id    
    }]

    set dbseg [ db prepare {
        insert into tmr3.segments (p1_id, p2_id, geog)
        values(:opt_id, :pt_id, 
           ST_SetSRID(
               ST_Makeline(
                   ST_Point(cast(:olon as float), cast(:olat as float)),
                   ST_Point(cast(:lon as float), cast(:lat as float)))
                   , 4283)::geography )
    }]

    set in [open $file r]
    db transaction {
        while {[gets $in line] >= 0} {
            set line [split $line ,]
            lassign $line  \
                section code dist lat lon desc aadt aadtic
            set lat [double $lat]
            set lon [double $lon]
            set dist [double $dist]
            set new 0

           if {$section ne $osection
               || $code ne $ocode
               || $desc ne $odesc } {

                lassign [ $dbroad allrows -as lists ] road_id
                puts "section $road_id $section $code $desc"
                set osection $section
                set ocode $code
                set odesc $desc
                set new 1
            }

            lassign [ $dbpoint allrows -as lists ]  pt_id   

            if {!$new && [abs [- $dist $odist]] > [/ 15.0 1000.0]} {
                set new 1
                puts [format "    skip %s - %s" $odist $dist]
            }

            if {!$new} { $dbseg allrows }
            set opt_id $pt_id
            set olat $lat
            set olon $lon
            set odist $dist
            incr n
        }
    }
    close $in
    puts "indexing points ..."
    db allrows { CREATE INDEX idx_points_geog on tmr3.points USING gist(geog) }    
    puts "indexing segments ..."
    db allrows { CREATE INDEX idx_segments_geog on tmr3.segments USING gist(geog) }   
    db close
    puts $n
}

set dir .
set file "sort.txt"
set file [file join $dir $file]
puts $file
run $file
puts finished
