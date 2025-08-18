#!/usr/bin/env perl
use strict;
use warnings;
use DateTime;

my $start = DateTime->new(
    day   => 28,
    month => 7,
    year  => 2024,
);
$start->subtract(days=>1);

my $stop = DateTime->now;
$stop->add(days => 7);


while ( $start->add(days => 7) < $stop ) {
    my $cmd = sprintf( "./heliStackWide.pl %s . 7 12", $start->strftime('%Y%m%d') );
    print $cmd, "\n";
    system( $cmd );
}

