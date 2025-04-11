function plotSeaStateWindRsamHeliStack(setup,reFetch,lastDateString,ndays,...
    nsta,staRsam1,limRsam1,staRsam2,limRsam2,plotRain,useExistPlot,overlayRSAM, ...
    keepHeliStack,weatherStation,nFiltWeather,plotGust,nFiltRsam)

% plotSeaStateWindHeliStack
% 
% Plots Sea state at Buoy 42060 and SGH wind speed and RSAM with helicorder stack for
% 10 stations
%
% R.C. Stewart, 2024-05-30
%               2024-10-08



if nargin < 14
    clear;
    setup = setupGlobals;
    reFetch = inputd( 'Refetch weather data (Y/N)', 'l', 'N' );
    lastDateString = inputd( 'Last date in plot (yyyymmdd)', 's', 'now');
    ndays = inputd( 'Number of days', 'i', 7 );
    type stations.txt;
    nsta = inputd( 'Number of stations', 'i', 7 );
    staRsam1 = inputd( 'Station for RSAM', 's', 'none' );
    limRsam1 = inputd( 'Upper limits for RSAM', 'i', 0 );
    staRsam2 = inputd( '2nd station for RSAM', 's', 'none' );
    limRsam2 = inputd( 'Upper limits for RSAM', 'i', 0 );
    nFiltRsam = inputd( 'Filter length for RSAM (running median)', 'i', 31 );
    useExistPlot = inputd( 'Use existing helistack (Y/N)', 'l', 'N' );
    overlayRSAM = inputd( 'Overlay RSAM on helis (Y/N)', 'l', 'Y' );
    keepHeliStack = inputd( 'Keep helistack (Y/N)', 'l', 'N' );
    weatherStation = inputd( 'Weather station', 's', 'auto' );
    plotRain = inputd( 'Plot rainfall (Y/N)', 'l', 'N' );
    plotGust = inputd( 'Plot wind gust data (Y/N)', 'l', 'N' );
    nFiltWeather = inputd( 'Filter length for weather station data (running mean filter)', 'i', 31 );

end



if reFetch
        fetchAllWeathers( setup );
end



% Y plot limits

windspeedLimits = [0 15];
%windspeedLimits = [0 20];
waveheightLimits = [0 2.4];
rainLimits = [0 3.8];



% Set date limits

if strcmp( lastDateString, 'now' )
    lastDateString = sprintf( "%8s", datestr( now, 'yyyymmdd' ) );
end

datesEnd = double( datenum( lastDateString, 'yyyymmdd' ) + 1 );
datesBeg = double( datesEnd - ndays );
firstDateString = sprintf( "%8s", datestr( datesBeg, 'yyyymmdd' ) ); 

datimBegVec = datevec( datesBeg );
datimBegYear = datimBegVec(1);
datimEndVec = datevec( datesEnd );
datimEndYear = datimEndVec(1);
xLimits = [ datesBeg datesEnd ];
tTicks = datesBeg:datesEnd;



% Load data

% Load buoy 42060 data
data_file = fullfile( setup.DirNDBC, 'NDBC.mat' );
load( data_file );
datim = datimB42060;
waveDir = waveDirB42060;
waveDir( waveDir > 270 ) = ...
waveDir( waveDir > 270 ) - 360;
waveHeight = waveHeightB42060;

% Load MVO weather data
dirWeather = fullfile( setup.DirHome, 'data/weather/MVO' );
fileWeather = fullfile(dirWeather, 'SGHWxAll.mat');
load( fileWeather );
nrmean = nFiltWeather;
if nrmean > 1
    windSpeedSGHWx = nan_rmean( windSpeedSGHWx, nrmean );
    windDirSGHWx = nan_rmean( windDirSGHWx, nrmean );
end

fileWeather = fullfile(dirWeather, 'HermWx_AllWind.mat' );
load( fileWeather );
datimHermWx = datim;
windSpeedHermWx = wspeed;
windDirHermWx = wdir;
if nrmean > 1
    windSpeedHermWx = nan_rmean( windSpeedHermWx, nrmean );
    windDirHermWx = nan_rmean( windDirHermWx, nrmean );
end

fileWeather = fullfile(dirWeather, 'LeesWx_AllRain.mat' );
load( fileWeather );
datimLeesWx = datim;
rainLeesWx = rain;
rainLeesWx = nan_rmean( rainLeesWx, nrmean );

% Load weather data from Geralds
dirWeather = fullfile( setup.DirHome, 'data/weather/Meteostat' );
fileWeather = fullfile(dirWeather, 'meteostat.mat');
load( fileWeather );

% Load RSAM data
nmedfilt = nFiltRsam;
%dirRsam = setup.DirRsam;
dirRsam = '/mnt/earthworm3/monitoring_data/rsam/';
if ~strcmp(staRsam1,'none')
    switch staRsam1
        case {'MSS1','MBRY','MBWH','MBHA','MBRV'}
            stachan1 = strcat( staRsam1, '_SHZ' );
        otherwise
            stachan1 = strcat( staRsam1, '_EHZ' );
    end
    fileRsam = sprintf( '%4d_rsam_%s_60sec.dat', datimBegYear, stachan1 );
    fileRsam = fullfile( dirRsam, fileRsam );
    [dataRsam1,datimRsam1] = readRsamFile( fileRsam );
    if datimBegYear ~= datimEndYear
        fileRsam = sprintf( '%4d_rsam_%s_60sec.dat', datimEndYear, stachan1 );
        fileRsam = fullfile( dirRsam, fileRsam );
        [dataRsam1a,datimRsam1a] = readRsamFile( fileRsam );
        dataRsam1 = [dataRsam1; dataRsam1a];
        datimRsam1 = [datimRsam1; datimRsam1a];
    end
    dataRsam1 = medfilt1(dataRsam1,nmedfilt);
end
if ~strcmp(staRsam2,'none')
    switch staRsam2
        case {'MSS1','MBRY','MBWH','MBHA','MBRV'}
            stachan2 = strcat( staRsam2, '_SHZ' );
        otherwise
            stachan2 = strcat( staRsam2, '_EHZ' );
    end
    fileRsam = sprintf( '%4d_rsam_%s_60sec.dat', datimBegYear, stachan2 );
    fileRsam = fullfile( dirRsam, fileRsam );
    [dataRsam2,datimRsam2] = readRsamFile( fileRsam );
    if datimBegYear ~= datimEndYear
        fileRsam = sprintf( '%4d_rsam_%s_60sec.dat', datimEndYear, stachan2 );
        fileRsam = fullfile( dirRsam, fileRsam );
        [dataRsam2a,datimRsam2a] = readRsamFile( fileRsam );
        dataRsam2 = [dataRsam2; dataRsam2a];
        datimRsam2 = [datimRsam2; datimRsam2a];
    end
    dataRsam2 = medfilt1(dataRsam2,nmedfilt);
end



% Select weather station

if strcmp( weatherStation, 'auto' )
    weatherStation = chooseWeatherStation( datesEnd );
end

switch weatherStation
    case "HermWx"
        datimWind = datimHermWx;
        windSpeed = windSpeedHermWx;
        windDir = windDirHermWx;
    case "Geralds"
        datimWind = datimGeralds;
        windSpeed = windSpeedGeralds;
        windDir = windDirGeralds;
    case "SGHWx"
        datimWind = datimSGHWx;
        windSpeed = windSpeedSGHWx;
        windSpeedGust = windSpeedGustSGHWx;
        windDir = windDirSGHWx;
end



% Figure for weather data

figure;
figure_size( 'l' );

% Tiles

nPanes = 3;
if plotRain
    nPanes = nPanes + 1;
elseif ~overlayRSAM && ~strcmp(staRsam1,'none')
    nPanes = nPanes + 1;
end
tiledlayout(nPanes,1,'TileSpacing','None');



% Plot buoy data

nexttile(1);    

plot( datimB42060, waveDirB42060, 'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'r' );
ylim( [-90 270] );
yticks( [0 90 180 270] );
%ylim( [45 165] );
%yticks( [45 90 135] );
ylabel( {'Buoy 42060','Wave direction','(degrees from N)'} );
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0 );
xlim( xLimits );
grid on;
set(gca,'xaxisLocation','top');
set(gca, 'xtick', tTicks);
datetick( 'x', 19, 'keeplimits' );

nexttile(2);
plot( datimB42060, waveHeightB42060, 'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'r' );
ylabel( {'Buoy 42060','Wave height','(metres)'} );
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0 );
xlim( xLimits );
yLimits = ylim;
if yLimits(2) > waveheightLimits(2)
    waveheightLimits(2) = 1.1*yLimits(2);
end
ylim( waveheightLimits );
set(gca, 'xtick', tTicks);
grid on;
set(gca,'xaxisLocation','top');
datetick( 'x', 19, 'keeplimits' );
set(gca,'Xticklabel',[]);



% Plot wind data

nexttile(3);
yyaxis right;
if plotGust
    windSpeed = windSpeedGust;
    yLab = 'Gust speed';
    windspeedLimits = 1.3 * windspeedLimits;
else
    yLab = 'Wind speed';
end
plot( datimWind, windSpeed, '.' );
ylabel( {weatherStation,yLab,'(m/s)'} );
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0 );
ylim( windspeedLimits );
yyaxis left;
plot( datimWind, windDir, '.' );
ylabel( {weatherStation,'Wind direction'} );
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0 );
%ylim( [0 720] );
ylim( [0 360] );
yticks( [0 180] );
    
xlim( xLimits );
set(gca, 'xtick', tTicks);
set(gca,'TickDir','out');
datetick( 'x', 19, 'keeplimits' );
set(gca,'Xticklabel',[]);



% Plot rain or RSAM

if plotRain
    nexttile(4);
    stem( datimLeesWx, rainLeesWx, 'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'r' );
    ylim( rainLimits );
    ylabel( {'Lees','Rainfall','(mm)'} );
    hYLabel = get(gca,'YLabel');
    set(hYLabel,'rotation',0 );
    xlim( xLimits );
    set(gca, 'xtick', tTicks);
    set(gca,'TickDir','out');
    datetick( 'x', 19, 'keeplimits' );
    set(gca,'Xticklabel',[]);   
%    set(gca,'Xgrid','on')
%    set(gca,'Ygrid','on')
elseif ~overlayRSAM && ~strcmp(staRsam1,'none')
    nexttile(4);
    yyaxis right;
    plot( datimRsam1, dataRsam1, '-' );
    ylabel( {strrep(stachan1,'_',' '),'RSAM','(despiked)'} );
    hYLabel = get(gca,'YLabel');
    set(hYLabel,'rotation',0 );
    if limRsam1 > 0
        ylim( [0 limRsam1] );
    else
        yL = ylim;
        ylim([0 2*yL(2)]);
    end

    if ~strcmp(staRsam2,'none')
        yyaxis left;
        plot( datimRsam2, dataRsam2, '-' );
        ylabel( {strrep(stachan2,'_',' '),'RSAM','(despiked)'} );
        hYLabel = get(gca,'YLabel');
        set(hYLabel,'rotation',0 );
        if limRsam2 > 0
            ylim( [0 limRsam2] );
        end
    end

    xlim( xLimits );
    set(gca, 'xtick', tTicks);
    set(gca,'TickDir','out');
    datetick( 'x', 19, 'keeplimits' );
    grid on;

end



% Save file

tit = sprintf( "%s - %s", firstDateString, lastDateString );
plotOverTitle( tit );

fileSave = 'fig-SeaStateWeatherRsam.png';
if plotRain
    figSave(gcf,fileSave,[2400 888]);
    cmd = sprintf( "magick mogrify -crop 2400x823+0+0 %s", fileSave );
elseif overlayRSAM || strcmp(staRsam1,'none')
    figSave(gcf,fileSave,[2400 710]);
    cmd = sprintf( "magick mogrify -crop 2400x645+0+0 %s", fileSave );
else
    figSave(gcf,fileSave,[2400 888]);
    cmd = sprintf( "magick mogrify -crop 2400x645+0+0 %s", fileSave );
end
close( gcf );
system( cmd );



% Generate RSAM overlay if needed

if overlayRSAM

    rawLines = readlines("stations.txt");
    staLine = rawLines(nsta);
    stachans = split( staLine );
    stachans = stachans(2:end);
    nstachans = length( stachans);

    for ista = 1:nstachans
        stc = stachans(ista);
        switch stc
            case {'MSS1','MBRY','MBWH','MBHA','MBRV'}
                stc = strcat( stc, '_SHZ' );
            otherwise
                stc = strcat( stc, '_EHZ' );
        end
        stachans(ista) = stc;
    end

            
    f = figure;
    f.Units = 'pixels';
    f.OuterPosition = [0 0 2400 1000]; % Putting 900 for y size didn't work, so we have to create bigger and trim
    
    tcl = tiledlayout(nsta,1,'units','pixels','position', [166 0 2090 900],'padding','tight','TileSpacing','none'); % Fiddled with 2090 instead of 2100
   
    for ista = 1:nsta

        stachan = string(stachans(ista));
        fileRsam = sprintf( '%4d_rsam_%s_60sec.dat', datimBegYear, stachan );
        fileRsam = fullfile( dirRsam, fileRsam );
        [dataRsam1,datimRsam1] = readRsamFile( fileRsam );
        if datimBegYear ~= datimEndYear
            fileRsam = sprintf( '%4d_rsam_%s_60sec.dat', datimEndYear, stachan );
            fileRsam = fullfile( dirRsam, fileRsam );
            [dataRsam1a,datimRsam1a] = readRsamFile( fileRsam );
            dataRsam1 = [dataRsam1; dataRsam1a];
            datimRsam1 = [datimRsam1; datimRsam1a];
        end
        dataRsam1 = medfilt1(dataRsam1,nmedfilt);

        nexttile(tcl);
        plot( datimRsam1, dataRsam1, 'g-', 'LineWidth', 0.5 );
        xlim( xLimits );
        set(gca, 'xtick', []);
        set(gca, 'ytick', []);
        axis off;

    end

    % Save overlay and trim and resize
    set(gcf, 'color', 'none');    
    set(gca, 'color', 'none');    
    fileSave2 = 'fig-RsamOverlay.png';
    figSave(gcf,fileSave2,[2400 1000]); % Using 900 for the Y side causes problems, so have to save and trim
    close( gcf );
    cmd = sprintf( "magick mogrify -transparent white %s", fileSave2 );
    system( cmd );
    cmd = sprintf( "magick mogrify -crop 2400x966+0+34 %s", fileSave2 );
    system( cmd );
    cmd = sprintf( "magick mogrify -resize 2400x900! %s", fileSave2 );
    system( cmd );
  

end




% Create helistack, unless using pre-existing one

if ~useExistPlot
    if datesEnd > now
        lastDateString2 = 'now';
    else
        lastDateString2 = lastDateString;
    end

    cmd = sprintf( ...
        "./heliStackWide.pl %s . %d %d >/dev/null 2>&1", ...
        lastDateString2, ndays, nsta );
    disp ( "Creating heliStack, may take some time." );
    %disp( cmd );
    system( cmd );
end




% Create montage

fileHeliStack = sprintf( "heliStackWide-%s-%dd-%ds-shrunk.png", lastDateString, ndays, nsta  );
fileMontage = sprintf( "fig-seaStateWindRsamHeliStack-%s-%dd-%ds.png", lastDateString, ndays, nsta );
fprintf( "%s\n", fileMontage );

if overlayRSAM
    cmd = sprintf( "magick composite fig-RsamOverlay.png %s tmp4.png", fileHeliStack);
    system( cmd );
    cmd = sprintf( "mv tmp4.png %s", fileHeliStack );
    system( cmd );
end

cmd = sprintf( "magick montage %s %s blankB.png -tile 1x3 -geometry +0+0 %s >/dev/null 2>&1", ...
        fileSave, fileHeliStack, fileMontage );
system( cmd );

if ~keepHeliStack
    cmd = 'rm heliStackWide*.png';  
    system( cmd );
end

