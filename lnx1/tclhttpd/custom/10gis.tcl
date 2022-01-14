#package require Memchan

package require tcl::chan::events
package require tcl::chan::memchan

package require TclOO
package require tdbc 
package require tdbc::postgres

#package require Pgtcl
package require base64
package require tdom
package require zipper

dom createNodeCmd -returnNodeCmd elementNode Document
dom createNodeCmd -returnNodeCmd elementNode Folder
dom createNodeCmd -returnNodeCmd elementNode Placemark
dom createNodeCmd cdataNode cdata
dom createNodeCmd elementNode ExtendedData
dom createNodeCmd elementNode Icon
dom createNodeCmd elementNode IconStyle
dom createNodeCmd elementNode LineStyle
dom createNodeCmd elementNode LinearRing
dom createNodeCmd elementNode Point
dom createNodeCmd elementNode PolyStyle
dom createNodeCmd elementNode Polygon
dom createNodeCmd elementNode Schema
dom createNodeCmd elementNode SchemaData
dom createNodeCmd elementNode SimpleData
dom createNodeCmd elementNode SimpleField
dom createNodeCmd elementNode Style
dom createNodeCmd elementNode color
dom createNodeCmd elementNode coordinates
dom createNodeCmd elementNode description
dom createNodeCmd elementNode fill
dom createNodeCmd elementNode href
dom createNodeCmd elementNode innerBoundaryIs
dom createNodeCmd elementNode name
dom createNodeCmd elementNode outerBoundaryIs
dom createNodeCmd elementNode outline
dom createNodeCmd elementNode scale
dom createNodeCmd elementNode styleUrl
dom createNodeCmd elementNode width
dom createNodeCmd textNode text

Url_PrefixInstall /gis gis

proc gis {sock suffix} {
    upvar #0 Httpd$sock data
    ::ncgi::reset $data(query)
    ::ncgi::parse
    lassign [split [::ncgi::value BBOX] ,] lon1 lat1 lon2 lat2
    set table [string trim $suffix "/"]

#    Stderr " $table $sock $lon1 $lat1 $lon2 $lat2"
    $table $sock $lon1 $lat1 $lon2 $lat2
}

set psm {
    iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAA8ElEQVR4nO1WQQ7DMAizp/3/y95l
    qRBLaAKdskpD6oHSYmMSEkrCTntsRf8TuIIAydIiurcCrfqKCmkCJCWJACCJWRJpAg185H+dwFXG
    7CTsSZ5RIUWAZPcvJkgst8CC0zwAIKzviCUFGrgFPGKWBOaVCBWIqvGBqIwoz5CA3eeHj3d1AakW
    t6DRnPhowVnVEQFYAsE3trDnKNhTIMh5CuTzNRu2wMsmiWfV2fgMeEjAV9ADi/zpPKuDyM+BA8S8
    WxlG2yfhPc8CTyR7FAM/cByXbkSRP52n0gI/JzI5Si2wd8Jsju1roLwLqrZdge0EXvUroxxX5/oY
    AAAAAElFTkSuQmCC
}

proc testing {sock west south east north} {
    global psm site
    Stderr "$sock $west $south $east $north"
    set x [expr {($east+$west)/2}]
    set y [expr {($north+$south)/2}]

    upvar #0 Httpd$sock data
    ::ncgi::reset $data(query)
    ::ncgi::parse

    dom createDocument kml doc
    $doc documentElement root
    $root setAttribute xmlns http://www.opengis.net/kml/2.2
    $root appendFromScript { 
        Document {
            Style id default {
                IconStyle {
                    scale { text 2.0}
                    Icon {
                       href {text psm.png}
#                       href {text "$site/pmsymbols/PMCode126.png"}                    
		   }
                }
            }
            Placemark {
		description { text "[::ncgi::query]\n[::ncgi::value QUERY]"}
                name {text "View-Centred Placemark"}
                styleUrl { text #default }
                Point {
                    coordinates {text $x,$y}
                }
            }
        }
    }

    set fd [tcl::chan::memchan]
    zipper::initialize $fd
    zipper::addentry doc.kml \
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n[$doc asXML]"
    zipper::addentry psm.png [::base64::decode $::psm]
    zipper::finalize
    seek $fd 0
    Httpd_ReturnData $sock application/vnd.google-earth.kmz [read $fd]
    close $fd
}
