#!/usr/bin/env perl
use strict;
use warnings;
use DateTime;

my $start = DateTime->new(
    day   => 10,
    month => 10,
    year  => 2020,
);
$start->subtract(days=>1);

my $stop = DateTime->now;
$stop->add(days => 7);


while ( $start->add(days => 7) < $stop ) {
    my $cmd = sprintf( "./heliStackWide.pl %s . 7 1", $start->strftime('%Y%m%d') );
    print $cmd, "\n";
    system( $cmd );
}

