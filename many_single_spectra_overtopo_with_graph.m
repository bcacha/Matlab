%Script for plotting many single point spectra over a topo.
%Choose as many single point spectra as needed, it will not read through
%line scans or heatmaps.
%-----------------------------------------------------------------------
%You must choose only one topo file otherwise it'll be replaced with the
%last topo file loaded.
%-----------------------------------------------------------------------
%You can adjust voltage range by changing vrange below.

[scalex, scaley] = deal(3.79, 3.79); %Scaling factor

if exist('lastfolder') == 0 || isnumeric(lastfolder) %saves or creates last folder directory
    lastfolder = cd;
end

% [file,path,indx] = uigetfile('*.*','Select One or More Files','MultiSelect', 'on', lastfolder);
% lastfolder = path;
global dv spec txt h
dv = 0.05; %increments in the voltage
vrange = -.5:dv:1; %adjust voltage range
spec = zeros(1,5);
names = {};
nm = 1e9;
ii = 1;
    for i = 1:size(file,2)
        filepath = char(strcat(path,file(1,i)));
        [data,metadata] = read_sm4_fixed_10_a(filepath);
        if metadata{1, 1}.page_header.bias < 0  % inversion factor for voltage
            a = -1;
        else
            a = 1;
        end
        if size(data,2) == 4 %this section will grab the topo information
            page = 3; %select forward or reverse topo data
            topox = nm*data{1,page}.x/scalex;
            topoy = nm*data{1,page}.y/scaley;
            topoz = transpose(data{1,page}.z);
            theta = metadata{1,3}.page_header.angle;
            i = i + 1;
            ii = ii + 1;
        elseif size(data,2) == 2
            page = 1; % selects di/dv curves
            for j = 1:size(vrange,2)
                voltage = round(vrange(1,j),2);
                index = find(round(a*dv*round(data{1,1}.v/dv),2) == voltage); %finds the index of voltage
                if size(index,2) == 1 || isempty(index) %extracts the first index of occurance
                else
                    index = index(1,round(size(index,2)/2));
                end
                if isempty(index)
                    i = i + 1;
                else
                    xyz = [nm*data{1,page}.x/scalex, nm*data{1,page}.y/scaley, data{1,page}.z(index,1), index, voltage]; %index,1 for left scan. index,2 for right scan.
                    spec = [spec;xyz];
                    names{end+1} = filepath(end-6:end);  %gets file names if needed
                    i = i + 1;
                end
                    j = j + 1;
            end
        else
            i = i + 1;
        end
    end

 %deletes the extra 0 first rows. 
spec(1,:) = []; %the spec array columns are as follows {x(nm),y(nm),z,index in array,voltage}

fig = figure;
h1 = pcolor(topox,topoy,topoz);
set(h1,'EdgeColor', 'none');
angle = theta*pi/180;
xx = (max(topox) - min(topox))/2;
yy = (max(topoy) - min(topoy))/2;
dx = abs(xx*(1 - cos(angle)) + yy*sin(angle));
dy = abs(yy*(1 - cos(angle)) - xx*sin(angle));  %stretches limits to fit rotated picture
xlim([min(topox)-dx max(topox)+dx])
ylim([min(topoy)-dy max(topoy)+dy])
direction = [0 0 1];
rotate(h1,direction,theta);
colormap(gray);
set(gca,'XTick',[]) % Remove the ticks in the x axis
set(gca,'YTick',[]) % Remove the ticks in the y axis
set(gca,'Position',[0 0 1 1]) % Make the axes occupy the whole figure
saveas(fig,'topo.png')
close;

f = figure('pos',[250 75 900 650]);
ax = subplot('Position', [0.07 0.15  0.70 0.77]);
xlabel(ax,'nm');
ylabel(ax,'nm');
img = imrotate(flip(imread('topo.png'),2),180);
image(ax,'CData',img,'XData',[min(topox)-dx max(topox)+dx],'YData',[min(topoy)-dy max(topoy)+dy]) %places the image behind the scatterplot

hold on
range = find(spec(:,5) == -.3);
h = scatter(ax,spec(range,1),spec(range,2),50,spec(range,3),'filled');
colormap(jet);
maxval = max(spec(:,3));
xlim([min(topox)-dx max(topox)+dx])
ylim([min(topoy)-dy max(topoy)+dy])
colorbar;


ax2 = subplot('Position', [0.8 0.15  0.1 0.1]);
plot(ax2, topox);
hold off

p = uipanel('Parent',f, 'Position',[.8 .34 .2 .5]); %panel to parent all the ui controls
%voltage text and slider controls
txt = uicontrol('Parent',p,'Style','text','String',strcat("0 V"),...
                 'Units', 'normal','Position',[.15 .73 0.3 0.05]); 
txt2 = uicontrol('Parent',p,'Style','text','String',"Voltage",...
                'FontSize',12,'Units', 'normal','Position',[0.1 .8 .35 .06]);
b = uicontrol('Parent',p,'Style','slider', 'Units', 'normal', 'position',[.2 .1 .2 .63],...%[650,220,40,200],...
              'SliderStep', [1/(size(vrange,2)) , 5/(size(vrange,2)) ],...
              'Value',0, 'min',min(vrange), 'max',max(vrange), 'Callback', @vcontrol);
          
%slider for adjusting heatmap contrast  
txt3 = uicontrol('Parent',p,'Style','text','String',"Contrast",...
                'FontSize',12,'Units', 'normal','Position',[0.58 .8 .35 .06]);
sld = uicontrol('Parent',p,'Style', 'slider',...
                'Min',0,'Max',maxval,'Value',maxval/20,...
                'Units', 'normal','Position', [.65 .1 .2 .63],...
                'Callback', @surfzlim); 

% clearvars -except lastfolder h spec txt dv

    function surfzlim(source,event)
        caxis([0 source.Value])
    end
    
    function vcontrol(source,event)
        global h spec txt dv
        val = round(dv*round(source.Value/dv),2);
        set(h,'Xdata', spec(find(spec(:,5) == val),1),...
             'Ydata', spec(find(spec(:,5) == val),2),...
             'Cdata', spec(find(spec(:,5) == val),3));
        set(txt,'String',strcat(num2str(val)," V"));
    end

















