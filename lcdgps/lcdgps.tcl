# tmrchainage

namespace path {::tcl::mathop ::tcl::mathfunc}

package require tdbc
package require tdbc::postgres

set conninfo [list -host localhost -db gis -user gis]
tdbc::postgres::connection create db {*}$conninfo

set query [db prepare {

          select (d1 * cos(b1-b0) + tstart * 1000) as ch,
                 (d1 * sin(b1-b0)) as os,
                 section,
                 code,
                 description
          from
            (select section,
                    code,
                    description,
                    tstart,
                    tend,
                    st_distance(st_startpoint(s.geog::geometry)::geography,
                                st_endpoint(s.geog::geometry)::geography) as d0,
                    st_azimuth(st_startpoint(s.geog::geometry)::geography,
                               st_endpoint(s.geog::geometry)::geography) as b0,
                    st_distance(st_startpoint(s.geog::geometry)::geography, p.geog) as d1,
                    st_azimuth(st_startpoint(s.geog::geometry)::geography, p.geog) as b1
                from tmr2.segs as s,
                  (select st_setsrid(
                      st_point(CAST(:x as float),CAST(:y as float)),4283)::geography as geog) as p
                where left(code,1) = any(string_to_array('123AKQ', NULL))
                order by s.geog <-> p.geog limit 1) as foo

}]

proc roadloc {x y} {
    global query
    set x [double $x]
    set y [double $y]
    lassign [$query allrows] result
    dict with result {}
    return [list $ch $os $section $code $description]
}

# lcd

proc lcdread {} {
    global lcd wid hgt
    set res [gets $lcd]
    set cmd [lindex $res 0]
    if {$cmd eq "connect"} {
        set wid [lindex $res 7]
        set hgt [lindex $res 9]
    }
    if {$cmd eq "success"} { return }
    if {$cmd eq "listen"} { return }
    if {$cmd eq "ignore"} { return }

    puts $res
}

proc lcdputs {str} {
    global lcd
    puts $lcd $str
    flush $lcd
}

proc tmrinit {} {
    lcdputs "screen_add tmr"
    lcdputs "screen_set tmr -heartbeat off"
    lcdputs "widget_add tmr tmr1 string"
    lcdputs "widget_add tmr tmr2 string"
    lcdputs "widget_add tmr tmr3 string"
    lcdputs "widget_add tmr tmr4 string"
}

proc tmrupdate {tpv} {
    dict with tpv {
        if {[info exists mode]} {
            if {$mode >= 2} {
                lassign [roadloc $lon $lat ] ch os section code description
                lassign [split $time T] date time
                lassign [split $description |] sec desc
                set chos [format "%.3f km  %.0f m" [/ $ch 1000] $os]
                lcdputs "widget_set tmr tmr1 1 1 {$time}"
                lcdputs "widget_set tmr tmr2 1 2 {$desc}"
                lcdputs "widget_set tmr tmr3 1 3 {$sec}"
                lcdputs "widget_set tmr tmr4 1 4 {$chos}"
            } else {
                lcdputs "widget_set tmr tmr1 1 1 NA"
                lcdputs "widget_set tmr tmr2 1 2 NA"
                lcdputs "widget_set tmr tmr3 1 3 NA"
                lcdputs "widget_set tmr tmr4 1 4 NA"
            }
        }
    }
}

proc lcdinit {} {
    global lcd
    set lcd [socket localhost 13666]
    chan event $lcd readable [list lcdread]
    lcdputs "hello"
    vwait wid
    lcdputs "client_set name {Road Nav}"
    tmrinit
}

proc lcdupdate {tpv} {
    tmrupdate $tpv
}

# gps

package require json  

proc gpsread {} {
    global gps
    set data [::json::json2dict [gets $gps]]
    dict with data {
        if {$class eq "POLL"} {
            if {[info exists tpv]} {
                set last [lindex $tpv end]
                lcdupdate $last
            }
        } else {
            puts $data
        }
    }
}

proc gpsputs {cmd} {
    global gps
    puts $gps $cmd
    flush $gps
}

proc gpspoll {} {
    gpsputs {?POLL;}
    after 100 [list gpspoll]
}

proc gpsinit {} {
    global gps
    set gps [socket localhost 2947]
    chan event $gps readable [list gpsread]
    gpsputs {?WATCH={"enable":true}}
    gpspoll
}

lcdinit
gpsinit
vwait forever