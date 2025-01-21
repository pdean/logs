#!/usr/bin/perl
# vim:ft=perl:sts=4:sw=4:et

use v5.36;
use DBI;

my $lat  = -27.4494;
my $lon  = 153.021;
my @pos  = ( $lon, $lat );
my $chos = roadloc(@pos);
printf "%.1f %.1f %s %s %s\n", @$chos;

# subs

sub roadloc {

    # db connection parameters
    state $dbname   = 'gis';
    state $host     = 'localhost';
    state $username = 'gis';
    state $password = 'gis';

    # database handle
    state $dbh = DBI->connect( "dbi:Pg:dbname=$dbname;host=$host",
        $username, $password,
        { AutoCommit => 0, RaiseError => 1, PrintError => 0 } );

    # query string
    state $query = "
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
                from tmr.segs as s,
                  (select st_setsrid(st_point(?,?),4283)::geography as geog) as p
                where left(code,1) = any(string_to_array('123AKQ', NULL))
                order by s.geog <-> p.geog limit 1) as foo
        ";

    # handle to prepared statement
    state $sth = $dbh->prepare($query);

    # execute query
    $sth->execute(@_);
    return $sth->fetchrow_arrayref;
}

