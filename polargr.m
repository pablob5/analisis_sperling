clear,close all
% plots the polar plot


step = 2*pi/24;  % 15 degrees  


angs = -step:step*2:2*pi-step;

radio = 10;

h = 0;
k = 0;
figure, hold on
for p = 1:length(angs)-1
    t = linspace(angs(p),angs(p + 1),1000);

    x = radio * cos(t) + h;
    y = radio * sin(t) + k;
    x = [x h x(1)];
    y = [y k y(1)];
    
    if mod(p,2), Color = [255, 179, 128]/255; else Color = [.7 .7 .7];end

    han = fill(x,y,Color);
%     alpha(han, 0.4)
end
axis off
line([-10 10],[0 0],'Color','w','LineWidth',2)

t = 60*2*pi/360; % 60 grados
x = radio * cos(t) + h;
y = radio * sin(t) + k;
line([-x x],[-y y],'Color','w','LineWidth',2)

t = 120*2*pi/360; % 120 grados
x = radio * cos(t) + h;
y = radio * sin(t) + k;
line([-x x],[-y y],'Color','w','LineWidth',2)
    
%%
Color = [255, 179, 128]/255;

figure, hold on
han = fill([45 45 75 75],[2 5 5 2],Color);
% alpha(han, 0.3)


angs3 = 0:001:360;
angs3 = angs3 * 2*pi  / 360;
a=cos(6*angs3);


plot(a+4,'b','linewidth',3)
ylim([0 6])

an = [60 120 180 240 300];
for i = 1:length(an)
    line([an(i) an(i)],[2 5],'Color','k');
end


line([0 0 ],[2 5],'Color','k');
line([360 360 ],[2 5],'Color','k');
line([0 360 ],[5 5],'Color','k');
line([0 360 ],[2 2],'Color','k');
    
set(gcf,'Position',[   520   593   839   205])
% axis tight
box off
axis off


