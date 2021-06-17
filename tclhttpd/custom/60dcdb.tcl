# vim: sts=4 sw=4 tw=80 et ft=tcl:

proc dcdb {sock lon1 lat1 lon2 lat2} {
    global trans 

    set conninfo [list -host web -db gis -user gis]
    tdbc::postgres::connection create db {*}$conninfo


    set schema qspatial
    set tab qld_cadastre_dcdb
    set table "$schema.$tab"
    set geom o_shape
    set idx  objectid

    set query {select column_name,data_type from information_schema.columns 
                  where table_name=:tab and table_schema=:schema order by ordinal_position}
    set columns [list]
    db foreach row $query {
	set column [dict get $row column_name]
	if {$column eq $idx } continue
	if {$column eq $geom } continue
	lappend columns $column
	set types($column) [dict get $row data_type]
    }

    dom createDocument kml doc
    $doc documentElement root
    $root setAttribute xmlns http://www.opengis.net/kml/2.2
    $root appendFromScript {
	set document [Document] 
    }
    $document appendFromScript {
	name {text "DCDB2020"}
    }
    set ptable [string map {# _ { } _} $table]

    $document appendFromScript {
	Style id "NORMAL" {
            IconStyle {
		scale {text 1}
		Icon {
		    href { text http://maps.google.com/mapfiles/kml/pal4/icon57.png}
		}
	    }
	    LineStyle {
		color { text ffffffff}
		width { text 1}
	    }
	    PolyStyle {
		fill {text 0}
		outline {text 1}
	    }
	}
    }

    $document appendFromScript {
	Schema name $ptable id $ptable {
	    foreach column $columns {
		set type $types($column)
                #Stderr $type
		SimpleField name $column type string {text "" }
	    }    
	}
    }


    $document appendFromScript { 
        set folder [Folder] 
    }

    $folder appendFromScript {
        name {text $ptable}
    }

    set cols "st_askml($geom) as kml, [join $columns ,]"
    set box "st_setsrid(st_makebox2d(st_point(:lon1,:lat1),st_point(:lon2,:lat2)),7844)"
    set clause "$geom && $box"
    set query "select $cols  from $table where $clause limit 5000"

    db foreach row $query {

	$folder  appendFromScript {
	    set placemark [Placemark]
	} 

	$placemark appendFromScript {
            if {[dict exists $row lot]} {
                set lot [dict get $row lot]
                set plan [dict get $row plan]
                name {text "lot $lot on $plan"}
            } else {
                set segpar [dict get $row segpar]
                name {text "segpar $segpar"}
            }
        }
	$placemark appendFromScript {styleUrl {text "#NORMAL"}}

	$placemark appendFromScript {    
	    ExtendedData {
		SchemaData schemaUrl #$ptable {
		    foreach column $columns {
                        set data null
                        if {[dict exists $row $column]} {
                            set data [dict get $row $column]
                        }
			SimpleData name $column {text $data }
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

