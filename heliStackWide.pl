#!/usr/bin/perl
# 
# Creates a long sideways helicorder stack for multiple stations
# 
# R.C. Stewart, 2024-02-22, 2024-05-10, 2024-07-03

use strict;
use warnings;

use Time::Local;
use File::Fetch;

use DateTime::Format::Strptime;
use DateTime;

use File::Path qw(make_path);

my ($date, $dirSave, $days, $nsta, $heliType) = @ARGV;

if( $date eq '-h' ) {
    print "usage: heliStackWide.pl <date> <dirSave> <ndays> <nsta> <helitype>\n";
    exit;
}

if (not defined $date) {
    $date = 'now';
}

if (not defined $days) {
    $days = 7;
}

if (not defined $nsta) {
    $nsta = 10;
}

if (not defined $heliType) {
    $heliType = 'wide';
}

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


# Temporary directory for working
my $dirTmp = 'tmpHeliStackWide';
mkdir($dirTmp) unless(-d $dirTmp);
chdir( $dirTmp );
`rm *`;
if( $heliType eq 'orig' ){
    `cp ../blankBigOrig.gif .`;
    `mv blankBigOrig.gif blankBig.gif`;
} else {
    `cp ../blankBig.* .`;
}

my $rightNow = timegm(gmtime);
if( $date eq "yesterday" ){
    $rightNow = $rightNow - 86400;
}

my ($year, $month, $day, $hour, $minute) = (gmtime($rightNow))[5,4,3,2,1];
$year = 1900 + $year;
$month++;

my $stringDate = sprintf( '%04s%02s%02s', $year, $month, $day );

if( $date eq 'now' ){
    $dirSave = '.';
} elsif( $date eq 'yesterday' ) {
    if( not defined $dirSave ){
        $dirSave = join( '/', '/mnt/mvofls2/Seismic_Data/monitoring_data/helicorder_plots_stack_week', sprintf( "%4d", $year ) );
    }
} else {
    $stringDate = $date;
    if( not defined $dirSave ){
        $dirSave = join( '/', '/mnt/mvofls2/Seismic_Data/monitoring_data/helicorder_plots_stack_week', sprintf( "%4d", $year ) );
    }
}



my @stas = split /\s+/, $stations[$nsta];

my $dirHelis;
if( $date eq 'now' ){
    $dirHelis = "/mnt/earthworm3/monitoring_data/helicorder_plots_wide";
} elsif( $heliType eq 'orig' ) {
    $dirHelis = "/mnt/mvofls2/Seismic_Data/monitoring_data/helicorder_plots";
} elsif( $heliType eq 'raw' ) {
    $dirHelis = "/mnt/mvofls2/Seismic_Data/monitoring_data/helicorder_plots_raw";
} else {
    $dirHelis = "/mnt/mvofls2/Seismic_Data/monitoring_data/helicorder_plots_wide";
}


print "$stringDate  $days\n";
print "--------\n";

my $parser = DateTime::Format::Strptime->new(
  pattern => '%Y%m%d'
);

my $stringDateLess = $parser->parse_datetime($stringDate);
$stringDateLess->subtract(days => $days);


for( my $iday = 0; $iday < $days; $iday++){

    $stringDateLess->add(days => 1);
    $stringDate = sprintf( '%04s%02s%02s', $stringDateLess->year, $stringDateLess->month, $stringDateLess->day);
    print $stringDate, "\n";

    foreach my $sta (@stas) {

        my $stringGlob;
        if( $dirHelis =~ /earthworm3/ ){
            $stringGlob = join( '/', $dirHelis, join( '*', $sta, $stringDate, '.gif' ) );
        } else {
            $stringGlob = join( '/', $dirHelis, substr($stringDate,0,4), join( '*', $sta, $stringDate, '.gif' ) );
        }
        if( $heliType eq 'raw' ) {
            $stringGlob =~ s/gif$/png/;
        }
        my @files = glob( $stringGlob );

        my $nFiles = scalar @files;
        my $cmd;
        if( $nFiles >= 1 ){
            $cmd = join( " ", "cp", $files[0], join( '/', '.', join( ".", $sta, $stringDate, 'gif' ) ) );
        } else {
            $cmd = join( '', "cp blankBig.gif ", $sta, '.', $stringDate, '.gif' ), 
        }
        if( $heliType eq 'raw' ) {
            $cmd =~ s/gif/png/g;
        }
        system( $cmd );
    }

}



# Fix corrupt gif files
my @filesCorrupt = `exiftool -warning *.gif 2>&1 | grep Error`;
foreach my $fileCorrupt( @filesCorrupt ){
    my $fileToFix = (split '\s', $fileCorrupt)[-1];
    print "Corrupt file: $fileToFix\n";
    my $cmd = join( ' ', 'cp blankBig.gif', $fileToFix );
    system( $cmd );
}

`rm blankBig.*`;


my $cmd = 'magick mogrify -colorspace gray M*.gif';
if( $heliType eq 'raw' ) {
    $cmd =~ s/gif$/png/;
}
system( $cmd );

if( $heliType eq 'orig' ){
    $cmd = 'magick mogrify -crop 775x1405+50+50 M*.gif';
} else {
    $cmd = 'magick mogrify -crop 1920x1080+50+50 M*.gif';
}
if( $heliType eq 'raw' ) {
    $cmd =~ s/gif$/png/;
}
system( $cmd );

$cmd = 'magick mogrify -rotate -90 M*.gif';
if( $heliType eq 'raw' ) {
    $cmd =~ s/gif$/png/;
}
system( $cmd );


foreach my $sta (@stas) {

    my $file1 = join( '', $sta, '-montage.png' );
    #    my $file2 = join( '', $sta, '-montage2.png' );

    #$cmd = join( '', 'magick montage ', $sta, '*.gif -tile x1 -geometry +1+1+1+1 ', $file1 );
    $cmd = join( '', 'magick montage ', $sta, '*.gif -tile x1 -background red -geometry +1+0 ', $file1 );
    if( $heliType eq 'raw' ) {
        $cmd =~ s/gif/png/;
    }
    system( $cmd );

    #$cmd = join( '', "convert -font helvetica -fill black -pointsize 100 -gravity northwest -draw \"text 0,0 '", $sta,  "'\" ", $file1, ' ', $file2 );
    #system( $cmd );

}


my $stringFiles = "";
foreach my $sta( @stas ) {
    my $fileMontage = join( '', $sta, '-montage.png' );
    $stringFiles = join( ' ', $stringFiles, $fileMontage );
}

my $fileMontage = join( '', 'heliStackWide-', $stringDate, "-", "$days", 'd-', "$nsta", 's', '.png' );
#$cmd = join( '', 'magick montage ', $stringFiles, ' -tile 1x -geometry +10+10+10+10 ', $fileMontage );
$cmd = join( '', 'magick montage ', $stringFiles, ' -tile 1x -geometry +0+10+0+10 ', $fileMontage );
print "$fileMontage\n";
system( $cmd );

`mv $fileMontage ..`;

$cmd = 'rm *';
system( $cmd );


chdir( '..' );
`rm -r tmpHeliStackWide`;


my $fileMontage2 = $fileMontage;
$fileMontage2 =~ s/.png/-shrunk.png/;

`cp $fileMontage tmp1.png`;
`magick mogrify -resize 2093x900! tmp1.png`;

my $fileBlankL = sprintf( "blankL%d.png", $nsta );

`magick montage $fileBlankL tmp1.png blankR.png -tile 3x1 -geometry +0+0 $fileMontage2`;
`rm tmp*.png`;



if( $date ne 'now' ){
    $cmd = join( ' ', 'mv', $fileMontage2, $dirSave );
    system( $cmd );
}
