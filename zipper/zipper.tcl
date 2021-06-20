# ZIP file constructor

package provide zipper 0.11

namespace eval zipper {
  namespace export initialize addentry finalize

  namespace eval v {
    variable fd
    variable base
    variable toc
  }

  proc initialize {fd} {
    set v::fd $fd
    set v::base [tell $fd]
    set v::toc {}
    fconfigure $fd -translation binary -encoding binary
  }

  proc emit {s} {
    puts -nonewline $v::fd $s
  }

  proc dostime {sec} {
    set f [clock format $sec -format {%Y %m %d %H %M %S} -gmt 1]
    regsub -all { 0(\d)} $f { \1} f
    foreach {Y M D h m s} $f break
    set date [expr {(($Y-1980)<<9) | ($M<<5) | $D}]
    set time [expr {($h<<11) | ($m<<5) | ($s>>1)}]
    return [list $date $time]
  }

  proc addentry {name contents {date ""} {force 0}} {
    if {$date == ""} { set date [clock seconds] }
    foreach {date time} [dostime $date] break
    set flag 0
    set type 0 ;# stored
    set fsize [string length $contents]
    set csize $fsize
    set fnlen [string length $name]

    if {$force > 0 && $force != [string length $contents]} {
      set csize $fsize
      set fsize $force
      set type 8 ;# if we're passing in compressed data, it's deflated
    }

    if {[catch { zlib crc32 $contents } crc]} {
      set crc 0
    } elseif {$type == 0} {
      set cdata [zlib deflate $contents]
      if {[string length $cdata] < [string length $contents]} {
	set contents $cdata
	set csize [string length $cdata]
	set type 8 ;# deflate
      }
    }

    lappend v::toc "[binary format a2c6ssssiiiss4ii PK {1 2 20 0 20 0} \
    			$flag $type $time $date $crc $csize $fsize $fnlen \
			{0 0 0 0} 128 [tell $v::fd]]$name"

    emit [binary format a2c4ssssiiiss PK {3 4 20 0} \
    		$flag $type $time $date $crc $csize $fsize $fnlen 0]
    emit $name
    emit $contents
  }

  proc finalize {} {
    set pos [tell $v::fd]

    set ntoc [llength $v::toc]
    foreach x $v::toc { emit $x }
    set v::toc {}

    set len [expr {[tell $v::fd] - $pos}]
    incr pos -$v::base

    emit [binary format a2c2ssssiis PK {5 6} 0 0 $ntoc $ntoc $len $pos 0]

    return $v::fd
  }
}

if {[info exists pkgtest] && $pkgtest} {
  puts "no test code"
}

# test code below runs when this is launched as the main script
if {[info exists argv0] && [string match zipper-* [file tail $argv0]]} {

  catch { package require zlib }

  zipper::initialize [open try.zip w]

  set dirs [list .]
  while {[llength $dirs] > 0} {
    set d [lindex $dirs 0]
    set dirs [lrange $dirs 1 end]
    foreach f [lsort [glob -nocomplain [file join $d *]]] {
      if {[file isfile $f]} {
	regsub {^\./} $f {} f
        set fd [open $f]
	fconfigure $fd -translation binary -encoding binary
	zipper::addentry $f [read $fd] [file mtime $f]
	close $fd
      } elseif {[file isdir $f]} {
        lappend dirs $f
      }
    }
  }

  close [zipper::finalize]

  puts "size = [file size try.zip]"
  puts [exec unzip -v try.zip]

  file delete try.zip
}
