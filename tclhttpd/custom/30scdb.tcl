# scdb.tcl


proc scdb {sock lon1 lat1 lon2 lat2} {

    scdbgen $sock $lon1 $lat1 $lon2 $lat2 qspatial survey_control_data_qld shape ""
}

proc scdbgen {sock lon1 lat1 lon2 lat2 schema tab geom where} {
    global  icons trans site
    
#    Stderr "$lon1,$lat1,$lon2,$lat2"
#    Stderr "$schema.$tab"
        
    set conninfo [list -host gis -db gis -user gis ]
    tdbc::postgres::connection create db {*}$conninfo 
    
#    Stderr [db configure]
#    Stderr [db columns $schema.$tab]
    
    
    #set schema staging
    #set tab survey_control
    set table "$schema.$tab"
 #  set geom wkb_geometry
 #  set geom o_shape
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
    set codes [list 2 6 10 14 18 22 26 30 38 46\
                   54 62 82 86 90 94 118 126 130 \
		   134 138 142 146 150 154 158 166 \
		   174 182 190 210 214 218 222 246 254]

    $document appendFromScript {
        foreach code $codes {
            Style id "PMCode$code" {
                IconStyle {
                    scale {text 1.25}
                    Icon {
                        href {text "icons/PMCode$code.png"}
                    }
                }
            }
        }
    }

    #$document appendFromScript {
    #    Schema name $ptable id $ptable {
    #        foreach column $columns {
    #            set type $types($column)
    #            SimpleField name $column type string {text "" }
    #        }    
    #    }
    #}

    $document appendFromScript { 
	    set folder [Folder] 
    }

    $folder appendFromScript {
	    name {text SCDB}
    }

    set cols "st_askml(st_force3dz($geom)) as kml, [join $columns ,]"
    set box "st_setsrid(st_makebox2d(st_point(:lon1,:lat1),st_point(:lon2,:lat2)),4283)"
    set clause "$geom && $box"
    if {[string length [string trim $where]]} {
        set clause "$clause and $where"
    }
    set query "select $cols from $table where $clause limit 1000"
    
    db foreach row  $query {

        $folder  appendFromScript {
            set placemark [Placemark]
        } 

        set mark [dict get $row mrk_id]
        
        $placemark appendFromScript {
            name {text $mark}
        }
       
        set pdf [format "SCR%06d.pdf" $mark]
        set link \
        "http://qspatial.information.qld.gov.au/SurveyReport/$pdf"

        $placemark appendFromScript {
            description {
                cdata "<a href=\"$link\"> Survey Report </a>"
            }
        }

        set code [dict get $row code]
	
        $placemark appendFromScript {styleUrl {text "#PMCode$code"}}
                
        #$placemark appendFromScript {    
        #    ExtendedData {
        #        SchemaData schemaUrl #$ptable {
        #            foreach column $columns {
        #               set data null
        #                if {[dict exists $row $column]} {
        #                    set data [dict get $row $column]
        #                }
        #                SimpleData name $column {text $data}
        #            }
        #        }
        #    }
        #}
        
        set kml [dict get $row kml]
        
        $placemark appendXML $kml
    }

    set fd [tcl::chan::memchan]
    zipper::initialize $fd
    zipper::addentry doc.kml \
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n[$doc asXML]"
    foreach {name data} $icons {
            zipper::addentry icons/$name [::base64::decode $data]
    }
    zipper::finalize
    chan seek $fd 0
    Httpd_ReturnData $sock application/vnd.google-earth.kmz [read $fd]
    close $fd
	
    db close
}

