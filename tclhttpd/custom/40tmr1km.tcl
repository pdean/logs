# tmr1km.tcl


proc tmr1km {sock lon1 lat1 lon2 lat2 } {
    global  icons trans site
    
#    Stderr "$lon1,$lat1,$lon2,$lat2"
        
    set conninfo [list -host gis -db gis -user gis]
#    set conninfo [list -host gis -db gis -user gis]
    tdbc::postgres::connection create db {*}$conninfo 
    
    set schema qspatial
    set tab state_controlled_roads_1km_marks
    set table "$schema.$tab"
#    set geom wkb_geometry
    set geom shape
    set idx  objectid

    set columns [list]    
    set query {select column_name,data_type from information_schema.columns 
                 where table_name=:tab and table_schema=:schema}
    
    db foreach row $query {
	    set column [dict get $row column_name]
		if {$column eq $idx } continue
		if {$column eq $geom } continue
		lappend columns $column
		set types($column) [dict get $row data_type]
    }
    
    set ptable [string map {# _} $table]

    dom createDocument kml doc
    $doc documentElement root
    $root setAttribute xmlns http://www.opengis.net/kml/2.2
    $root appendFromScript {
        set document [Document] 
    }

    $document appendFromScript {
        name {text $ptable}
    }

    $document appendFromScript {
            Style id default {
                IconStyle {
                    scale {text 1.25}
                    Icon {
                        href {text "http://maps.google.com/mapfiles/kml/paddle/ltblu-blank.png"}
                    }
                }
            }
    }

    $document appendFromScript {
        Schema name $ptable id $ptable {
            foreach column $columns {
                set type $types($column)
                lassign [split $column :] junk colname
                SimpleField name $column type string 
            }    
        }
    }

    $document appendFromScript { 
	    set folder [Folder] 
    }

    $folder appendFromScript {
	    name {text "TMR 1km"}
    }

    set cols "st_askml(st_force3dz($geom)) as kml, [join $columns ,]"
    set box "st_setsrid(st_makebox2d(st_point(:lon1,:lat1),st_point(:lon2,:lat2)),4283)"
    set clause "$geom && $box"
    set query "select $cols from $table where $clause limit 1000"
    
    db foreach row  $query {

        $folder  appendFromScript {
            set placemark [Placemark]
        } 

        set tdist [dict get $row tdist]
        
        $placemark appendFromScript {
            name {text $tdist}
        }
       
        $placemark appendFromScript {styleUrl {text default}}
                
        $placemark appendFromScript {    
            ExtendedData {
                SchemaData schemaUrl #$ptable {
                    foreach column $columns {
                       set data null
                        if {[dict exists $row $column]} {
                            set data [dict get $row $column]
                        }
                        lassign [split $column :] junk colname
                        SimpleData name $column {text $data}
                    }
                }
            }
        }
        
        set kml [dict get $row kml]
        
        $placemark appendXML $kml
    }

    set fd [tcl::chan::memchan]
    zipper::initialize $fd
    zipper::addentry doc.kml \
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n[$doc asXML]"
    zipper::finalize
    chan seek $fd 0
    Httpd_ReturnData $sock application/vnd.google-earth.kmz [read $fd]
    close $fd
	
    db close
}

