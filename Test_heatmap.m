% Test script for pulling sm4 data

if exist('lastfolder') == 0 || isnumeric(lastfolder)
    lastfolder = cd;
end

[file,path,indx] = uigetfile('*.*','Select One or More Files','MultiSelect', 'on', lastfolder);
lastfolder = path;
filepath = char(strcat(path,file));
[data,metadata] = read_sm4_fixed_10_a(filepath);

pagenum = 5;
z = transpose(10*data{1,pagenum}.z(:,1:64));
x = -data{1,pagenum}.v;
y = -data{1,pagenum}.y;
meandata = zeros(size(x,2),1);
for j = 1:size(x,2)
    meandata(j) = min(z(:,j));
end
mincolor = sum(meandata)/size(x,2);
z = z - mincolor;
mincolor = min(z(:));
maxcolor = max(z(:));

% figure(); 
% subplot(1,2,1);
imagesc(x,y,z)
colorbar

% Create pop-up menu
popup = uicontrol('Style', 'popup',...
       'String', {'parula','jet','hsv','hot','cool','gray'},...
       'Position', [20 340 100 50],...
       'Callback', @setmap);          

% Create slider
sld = uicontrol('Style', 'slider',...
    'Min',mincolor,'Max',maxcolor,'Value',(maxcolor-mincolor)/20,...
    'Position', [400 20 120 20],...
    'Callback', @surfzlim); 

figure
plot(x,z)



    
    function setmap(source,event)
        val = source.Value;
        maps = source.String;
        newmap = maps{val};
        colormap(newmap);
    end
    
    function surfzlim(source,event)
        val = source.Min - source.Max/30;
        caxis([val source.Value])
    end
    
%     function setGlobalx1(val)
%         global x1
%         x1 = val;
%     end
%     
%     function r = getGlobalx
%         global x
%         r = x;
%     end
%        % Create pop-up menu
%     popup2 = uicontrol('Style', 'popup',...
%            'String', {'Page 5','page 6'},...
%            'Position', [20 240 100 50],...
%            'Callback', @changemap);    
%     
%     function changemap(source,event)
%         global data


