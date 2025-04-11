#!/usr/bin/perl

my @stations;
$stations[0] = "";
open FILE, "stations.txt" or die $!;
my $key;
while (my $line = <FILE>) {
     chomp($line);
     my ($key,$stas) = split(/\s+/, $line, 2);
     $stations[$key] = $stas;
}
close FILE;

my $xcap = 80;

my @nsta = (0..12);
foreach my $nsta (@nsta){
    my $capt = $stations[$nsta];
    my @caps = split / /, $capt;
    my $ncaps = scalar @caps;
    my $fileOut = sprintf( "blankL%d.png", $nsta );
    if ($ncaps > 0){
        my $cmd = "magick convert -font Ubuntu-Sans-Bold -pointsize 24";
        my $ycapadd = 900/$ncaps;
        my $ycap = $ycapadd/2;
        for my $cap (@caps){
            my $capadd = sprintf( "-annotate +%d+%d '%s'", $xcap, $ycap, $cap );
            $ycap = $ycap + $ycapadd;
            $cmd = join( " ", $cmd, $capadd );
        }
        $cmd = join( " ", $cmd, "blankL0.png", $fileOut );
        print "$cmd\n";
        system( $cmd );
    }
}
