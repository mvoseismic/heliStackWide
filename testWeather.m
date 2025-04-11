clear;
setup = setupGlobals();
wLimits = [0 30];
tLimits = [datenum(2024,8,13,0,0,0) datenum(2024,8,13,18,0,0) ];

dirWeather = fullfile( setup.DirHome, 'data/weather/MVO' );
fileWeather = fullfile(dirWeather, 'SGHWxAll.mat');
load( fileWeather );

figure;
figure_size('s');
plot(windSpeedSGHWx,windSpeedGustSGHWx,'ro');
%xlim(wLimits);
%ylim(wLimits);
xlabel( 'Average wind speed (m/s' );
ylabel( 'Gust wind speed (m/s' );
title( 'SGHWx Average vs Gust Wind Speeds');
axis square;
grid on;

figure;
figure_size( 'l' );
tiledlayout('vertical');
datimSGHWx = datimSGHWx - 4/24;

nexttile;
plot( datimSGHWx,windSpeedSGHWx,'ro', 'MarkerSize', 4);
xlim( tLimits );
datetick('x', 'keeplimits');
title( 'SGHWx Average Speed (m/s)' );
grid on;

nexttile;
plot( datimSGHWx,windSpeedGustSGHWx,'ro', 'MarkerSize', 4);
xlim( tLimits );
datetick('x', 'keeplimits');
title( 'SGHWx Gust Speed (m/s)' );
grid on;

nexttile;
plot( datimSGHWx,windDirSGHWx,'ro', 'MarkerSize', 4 );
xlim( tLimits );
datetick('x', 'keeplimits');
title( 'SGHWx Wind Direction (degrees)' );
xlabel( 'Time (local)' );
grid on;
