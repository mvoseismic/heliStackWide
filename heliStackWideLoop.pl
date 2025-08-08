#!/usr/bin/env perl
use strict;
use warnings;
use DateTime;

my $start = DateTime->new(
    day   => 1,
    month => 1,
    year  => 2025,
);
$start->subtract(days=>1);

my $stop = DateTime->now;
$stop->add(days => 14);


while ( $start->add(days => 14) < $stop ) {
    my $cmd = sprintf( "./heliStackWide.pl %s . 14 1", $start->strftime('%Y%m%d') );
    print $cmd, "\n";
    system( $cmd );
}

