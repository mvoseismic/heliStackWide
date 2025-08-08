#!/usr/bin/env perl
use strict;
use warnings;
use DateTime;

for my $year (2014..2025){

    print "========= $year =========\n";
    my $start = DateTime->new(
        day   => 1,
        month => 1,
        year  => $year,
    );
    $start->subtract(days=>1);
    my $stop = DateTime->new(
        day   => 1,
        month => 1,
        year  => $year+1,
    );
    print $start->strftime('%Y%m%d'), "\n";
    print $stop->strftime('%Y%m%d'), "\n";

    while ( $start->add(days=>14) < $stop ) {
        my $cmd = sprintf( "./heliStackWide.pl %s . 14 1", $start->strftime('%Y%m%d') );
        print $cmd, "\n";
        system( $cmd );
    }

    `rm *shrunk.png`;
    `mogrify -resize 25% heliStackWide*.png`;
    `mogrify -rotate 90 heliStackWide*.png`;
    my $fileMontage = join( '', 'fig--heliStacks-MSS1-', $year, '.png' );
    my $cmd = join( ' ', 'montage heliStackWide*.png -tile 13x -geometry +5+5', $fileMontage );
    print $cmd, "\n";
    system( $cmd );
    `rm heliStackWide*.png`;
}
