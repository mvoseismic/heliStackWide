# heliStackWide

## ~/src/heliStackWide

Creates a multi-day plot combining helicorder plots with weather and RSAM data. 

## createBlanks.pl

* Creates *blank\*.png* files when station groupings in *stations.txt* are changed.
* Uses *imagemagick*.

## heliStackWide.pl

* Standalone script to create a multi-day montage of helicorder plots.
* Uses *imagemagick*.

### Usage

*heliStackWide.pl \<date\> \<dirSave\> \<ndays\> \<nsta\> \<helitype\>*

* date: Last day of plot (default today).
* dirSave: Directory to save plot (default */mnt/mvofls2/Seismic_Data/monitoring_data/helicorder_plots_stack_week*).
* ndays: Number of days to plot (default 7)
* nsta: Number of stations to plot as defined in *stations.txt* (default 10).
* helitype: Type of helicorder plots used in montage (default wide). The only  other option is orig.

## heliStackWideLoop.pl

* Calls *heliStackWide.pl* for a loop of dates.
* Edit script to make changes.

## heliStackWideYear.pl

* Calls *heliStackWide.pl* for a loop of years and creates a montage for each year.
* Edit script to make changes.

## plotSeaStateWindRsamHeliStack.m

* MATLAB script to generate plot
* Calls *heliStackWide.pl*.
* Uses *imagemagick*.
* Cab be called as a function or used interactively.

### Interactive input
```
Refetch weather data (Y/N) [N]: 
Last date in plot (yyyymmdd) [now]: 
Number of days [7]: 

1  MSS1
2  MSS1 MBGH
3  MSS1 MBLG MBGH
4  MSS1 MBRY MBBY MBGH
5  MSS1 MBLY MBRY MBBY MBGH
6  MSS1 MBFR MBLY MBRY MBBY MBGH
7  MSS1 MBLY MBLG MBRY MBFR MBBY MBGH
8  MSS1 MBLY MBLG MBRY MBFR MBBY MBGB MBGH
9  MSS1 MBHA MBLG MBRY MBFR MBBY MBGB MBGH MBWH
10 MSS1 MBFR MBLY MBLG MBRY MBBY MBGH MBWH MBFL MBRV
11 MSS1 MBFR MBLY MBLG MBRY MBBY MBHA MBGH MBWH MBFL MBRV
12 MSS1 MBFR MBLY MBLG MBRY MBBY MBHA MBGH MBWH MBFL MBGB MBRV
Number of stations [7]: 
Station for RSAM [none]: 
Upper limits for RSAM [0]: 
2nd station for RSAM [none]: 
Upper limits for RSAM [0]: 
Filter length for RSAM (running median) [31]: 
Use existing helistack (Y/N) [N]: 
Overlay RSAM on helis (Y/N) [Y]: 
Keep helistack (Y/N) [N]: 
Weather station [auto]: 
Plot rainfall (Y/N) [N]: 
Plot wind gust data (Y/N) [N]: 
Filter length for weather station data (running mean filter) [31]: 
```

## plotSeaStateWindRsamHeliStackBatch.m

* MATLAB script to run *plotSeaStateWindRsamHeliStack.m* in a date loop.

## stations.txt

* Configuration file with station groupings that can be used in making the helicorder montage.
* Used by both *heliStackWide.pl* and *plotSeaStateWindRsamHeliStack.m*.
* You must run *createBlanks.pl* after changing *stations.txt*.

## Author

Roderick Stewart, Dormant Services Ltd

rod@dormant.org

https://services.dormant.org/

## Version History

* 1.0-dev
    * Working version

## License

This project is the property of Montserrat Volcano Observatory.
