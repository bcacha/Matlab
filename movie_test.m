%movie frames test

Z = peaks;
surf(Z)
axis tight manual
ax = gca;
ax.NextPlot = 'replaceChildren';

loops = 40;
F(loops) = struct('cdata',[],'colormap',[]);
for j = 1:loops
    X = sin(j*pi/10)*Z;
    surf(X,Z)
    drawnow
    F(j) = getframe(gcf);
    im{j} = frame2im(F(j));
end

% fig = figure;
% movie(fig,F,5)

filename = 'testAnimated.gif'; % Specify the output file name
for idx = 1:loops
    [A,map] = rgb2ind(im{idx},256);
    if idx == 1
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',.05);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',.05);
    end
end