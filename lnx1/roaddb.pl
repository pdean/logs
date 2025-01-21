#!/usr/bin/perl

# edit these
my $file   = 'sort.txt';
my $schema = 'tmr';

# no more edits

use v5.36;
use DBI;

my $host     = 'localhost';
my $dbname   = 'gis';
my $username = 'gis';
my $password = 'junk';

my $dbh = DBI->connect( "dbi:Pg:dbname=$dbname;host=$host", $username,
    $password );
my $sql;

$sql = "DROP SCHEMA IF EXISTS $schema CASCADE";
say $sql;
$dbh->do($sql) or die $dbh->errstr;

$sql = "CREATE SCHEMA $schema";
say $sql;
$dbh->do($sql) or die $dbh->errstr;

$sql = "CREATE table $schema.roads (
        id serial primary key, section text, code text, description text)";
say $sql;
$dbh->do($sql) or die $dbh->errstr;

$sql = "CREATE table $schema.points (
            id serial primary key, road_id integer, 
            tdist float, geog geography(point, 7844))";
say $sql;
$dbh->do($sql) or die $dbh->errstr;

$sql = "CREATE table $schema.segments (
            id serial primary key,  
            p1_id integer, p2_id integer, 
            geog geography(linestring, 7844))";
say $sql;
$dbh->do($sql) or die $dbh->errstr;

$sql = "insert into $schema.roads (section, code, description)
        values (?, ?, ?) 
        returning id ";
my $dbroad = $dbh->prepare($sql) or die $dbh->errstr;

$sql = "insert into $schema.points (road_id, tdist, geog)
        values (?, ?, ST_SetSRID( ST_Point(?, ?), 7844)::geography )
        returning id";
my $dbpoint = $dbh->prepare($sql) or die $dbh->errstr;

$sql = "insert into $schema.segments (p1_id, p2_id, geog)
        values(?, ?, 
        ST_SetSRID( ST_Makeline( ST_Point(?, ?), ST_Point(?, ?)), 7844)::geography)";
my $dbseg = $dbh->prepare($sql) or die $dbh->errstr;

my ( $n, $road_id, $pt_id, $new ) = ( 0, 0, 0, 0 );
my ( $osection, $ocode, $odesc, $opt_id, $olat, $olon, $odist );

use Try::Tiny;
$dbh->{AutoCommit} = 0;    # enable transactions, if possible
$dbh->{RaiseError} = 1;
try {

    open( my $fh, "<", $file )
        or die "Can't open < $file: $!";

    while (<$fh>) {
        chomp;
        my ( $section, $code, $dist, $lat, $lon, $desc, $aadt, $aadtic )
            = split /,/;
        $new = 0;

        if ( $section ne $osection || $code ne $ocode || $desc ne $odesc ) {

            $dbroad->execute( $section, $code, $desc );
            $road_id = $dbroad->fetch()->[0];
            say "section $road_id $section $code $desc";
            $osection = $section;
            $ocode    = $code;
            $odesc    = $desc;
            $new      = 1;
        }

        $dbpoint->execute( $road_id, $dist, $lon, $lat );
        $pt_id = $dbpoint->fetch()->[0];

        if ( !$new && abs( $dist - $odist ) > 15.0 / 1000.0 ) {
            $new = 1;
            printf "    skip %s - %s\n", $odist, $dist;
        }

        if ( !$new ) {
            $dbseg->execute( $opt_id, $pt_id, $olon, $olat, $lon, $lat );
        }

        $opt_id = $pt_id;
        $olat   = $lat;
        $olon   = $lon;
        $odist  = $dist;
        $n++;
    }
    close $fh;

    $dbroad->finish();
    $dbpoint->finish();
    $dbseg->finish();

    say "indexing points ...";
    $dbh->do("CREATE INDEX idx_points_geog on $schema.points USING gist(geog)"
    );
    say "indexing segments ...";
    $dbh->do(
        "CREATE INDEX idx_segments_geog on $schema.segments USING gist(geog)"
    );

    say "creating view $schema.pts ...";
    $dbh->do(
        "create or replace view $schema.pts as
        select p.id, r.section, r.code, r.description, p.tdist, p.geog
        from $schema.points as p
        join $schema.roads as r on (r.id = p.road_id)"
    );

    say "creating view $schema.segs ...";
    $dbh->do(
        "create or replace view $schema.segs as
        select s.id, s.geog, p1.tdist as tstart, p2.tdist as tend,
               r.section, r.code, r.description
        from $schema.segments as s
        join $schema.points as p1 on (s.p1_id = p1.id)
        join $schema.points as p2 on (s.p2_id = p2.id)
        join $schema.roads  as r  on (p2.road_id = r.id)"
    );

    $dbh->commit;    # commit the changes if we get this far
    say "committed";
}
catch {
    warn "Transaction aborted because $_";    # Try::Tiny copies $@ into $_
        # now rollback to undo the incomplete changes
        # but do it in an eval{} as it may also fail
    eval { $dbh->rollback };

    # add other application on-error-clean-up code here
};

say "disconnecting";
$dbh->disconnect;
say "$n points inserted";
