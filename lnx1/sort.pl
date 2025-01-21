#!/usr/bin/perl

my $infile = '../road-location-and-traffic-data_feb2022-copy.txt';
my $outfile = 'sort.txt';

use v5.36;

my @points;
my $n;
open(my $fh, "<", $infile);
my $header = <$fh>;
say "reading points ...";
while (<$fh>) {
    push @points, [split /,/];
    $n++;
}
close $fh;
say "$n points read";
say "sorting points";
my @sorted_points = sort {
  $a->[0] cmp $b->[0] || $a->[1] cmp $b->[1] || $a->[2] <=> $b->[2]
} @points;
say "writing points";
open ($fh, ">", $outfile);
foreach (@sorted_points) {
    print {$fh} join(',', @{$_});
}
close $fh

