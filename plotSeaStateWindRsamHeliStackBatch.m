clear;
setup = setupGlobals;

reFetch = false;
nsta = 7;
staRsam1 = 'none';
limRsam1 = 0;
staRsam2 = 'none';
limRsam2 = 0;
plotRain = false;
useExistPlot = false;
overlayRSAM = true;
keepHeliStack = false;
weatherStation = 'auto';
nFiltWeather = 31;
nFiltRsam = 31;
plotGust = false;

dateString = inputd( 'first last date (yyyymmdd)', 's', '20250101');
idayBeg = datenum( dateString, 'yyyymmdd' );
dateString = inputd( 'last last date (yyyymmdd)', 's', 'now');
if strcmp( dateString, 'now' )
    dateString = sprintf( "%8s", datestr( now, 'yyyymmdd' ) );
end
idayEnd = datenum( dateString, 'yyyymmdd' ) + 1;

%ndays = inputd( 'Number of days', 'i', 7 );
%type stations.txt;
%nsta = inputd( 'Number of stations', 'i', 7 );


NDAYS = [7 2 28];
for i = 1:length(NDAYS)
    ndays = NDAYS(i);

    switch ndays
        case 7
            nFiltWeather = 31;
            nFiltRsam = 31;
        case 2
            nFiltWeather = 1;
            nFiltRsam = 1;
        case 28
            nFiltWeather = 101;
            nFiltRsam = 101;
    end

    for iday = idayBeg:ndays:idayEnd
        lastDateString = datestr( iday, 'yyyymmdd' );
        fprintf( "%d  %s\n", iday, lastDateString );
        NSTA = [7 10 2];
        for j = 1:length(NSTA)
            nsta = NSTA(j);
            plotSeaStateWindRsamHeliStack(setup,reFetch,lastDateString,ndays,...
                nsta,staRsam1,limRsam1,staRsam2,limRsam2,plotRain,useExistPlot,overlayRSAM, ...
                keepHeliStack,weatherStation,nFiltWeather,plotGust,nFiltRsam);
        end
    end
end