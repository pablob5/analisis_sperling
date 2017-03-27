clear,
close all
clc

if strcmp(computer, 'GLNXA64')
    direc = '/home/pablo/Documentos/trabajo/proyectos/2016-SperlingG';
else
    direc = 'tu path ';
end

subject = 'fb01';

cd(fullfile(direc,'data',subject))

Correct1    = [];   
ANGrand1    = [];
ANGtotal1   = [];
RT1         = [];
Position1   = [];
Confidence1 = [];
SOA1        = [];

Correct2    = [];
ANGrand2    = [];
ANGtotal2   = [];
RT2         = [];
Position2   = [];
Confidence2 = [];
SOA2        = [];

%% data set 1, odd runs
for i = 1:2:6
    file = dir([subject, '_session',num2str(i),'*.mat']);
    
    disp(file.name)
    d = load(file.name);

    Correct1        = [Correct1     d.DataToSave.trial.Correct];
    ANGrand1        = [ANGrand1     d.DataToSave.trial.ANGrand];
    RT1             = [RT1          d.DataToSave.trial.RT];
    Confidence1     = [Confidence1  d.DataToSave.trial.Confidence];

    for j = 1:size([d.DataToSave.trial.RT],2)
        Position1 = [Position1      d.DataToSave.AllTrials(j).trial.Position];
        SOA1      = [SOA1           d.DataToSave.AllTrials(j).trial.SOA];
    end
end
ANGtotal1 = (Position1 * 2*pi)/12 + ANGrand1;
ANGtotal1 = mod(ANGtotal1 ,2*pi);


%% data set 1, even runs
for i = 2:2:6
    file = dir([subject, '_session',num2str(i),'*.mat']);
    disp(file.name)
    d = load(file.name);

    Correct2        = [Correct2     d.DataToSave.trial.Correct];
    ANGrand2        = [ANGrand2     d.DataToSave.trial.ANGrand];
    RT2             = [RT2          d.DataToSave.trial.RT];
    Confidence2     = [Confidence2  d.DataToSave.trial.Confidence];

    for j = 1:size([d.DataToSave.trial.RT],2)
        Position2 = [Position2      d.DataToSave.AllTrials(j).trial.Position];
        SOA2      = [SOA2           d.DataToSave.AllTrials(j).trial.SOA];
    end
end
ANGtotal2 = (Position2 * 2*pi)/12 + ANGrand2;
ANGtotal2 = mod(ANGtotal2 ,2*pi);


%% quadrature filter

Fold = 6;
seno = sin(Fold * ANGtotal1);               % SET 1
coseno = cos(Fold * ANGtotal1);

stats = regstats(Correct1,[seno',coseno' ]);
beta_seno = stats.beta(2);
beta_coseno = stats.beta(3);
pval1 = stats.tstat.pval(3);
angulo = atan2(beta_seno , beta_coseno)/Fold; 
ANGtotal_alineado2 = ANGtotal2 - angulo;   % 0 degrees now equals subject's 0 degrees (SET 2)

coseno_alineado = cos(Fold * ANGtotal_alineado2);

stats2 = regstats(Correct2,[coseno_alineado']);

beta = stats2.beta(2);
pval = stats2.tstat.pval(2);

disp('--------')
disp(['angle:     ' num2str(angulo * 180/pi),' grados'])
disp(['beta value: ' num2str(beta)])
disp(['P value:    ' num2str(pval)])
disp('--------')
%% aligned vs nonaligned. 
ANGtotal_alineado2 = ANGtotal_alineado2 * 360 / (2*pi);

angs = 0:15:360;

temp2 = zeros(size(ANGtotal_alineado2));

for p = 1:length(angs)-1
    inds = (ANGtotal_alineado2 > angs(p)) & (ANGtotal_alineado2 < angs(p+1));
    CC{p} = Correct2(inds);
    RR{p} = RT2(inds);
end

DD(1) = mean( [CC{1} CC{end}]);
DD(2) = mean( [CC{2} CC{3}]);
DD(3) = mean( [CC{4} CC{5}]);
DD(4) = mean( [CC{6} CC{7}]);
DD(5) = mean( [CC{8} CC{9}]);
DD(6) = mean( [CC{10} CC{11}]);
DD(7) = mean( [CC{12} CC{13}]);
DD(8) = mean( [CC{14} CC{15}]);
DD(9) = mean( [CC{16} CC{17}]);
DD(10) = mean( [CC{18} CC{19}]);
DD(11) = mean( [CC{20} CC{21}]);
DD(12) = mean( [CC{22} CC{23}]);
    
rrtt(1) = mean( [RR{1} RR{end}]);
rrtt(2) = mean( [RR{2} RR{3}]);
rrtt(3) = mean( [RR{4} RR{5}]);
rrtt(4) = mean( [RR{6} RR{7}]);
rrtt(5) = mean( [RR{8} RR{9}]);
rrtt(6) = mean( [RR{10} RR{11}]);
rrtt(7) = mean( [RR{12} RR{13}]);
rrtt(8) = mean( [RR{14} RR{15}]);
rrtt(9) = mean( [RR{16} RR{17}]);
rrtt(10) = mean( [RR{18} RR{19}]);
rrtt(11) = mean( [RR{20} RR{21}]);
rrtt(12) = mean( [RR{22} RR{23}]);
    

angs2 = 0:30:330;

figure, hold on
bar(angs2(1:2:end),DD(1:2:end),'Facecolor','r','Edgecolor','r','Barwidth',.45)
bar(angs2(2:2:end),DD(2:2:end),'Facecolor','b','Edgecolor','b','Barwidth',.45)
set(gca,'Xtick',0:30:330)
set(gcf,'Position',[146   587   869   302])
xlabel('grados')
ylabel('Accuracy')

angs3 = 0:330;angs3 = angs3 * 2*pi  / 360;a=cos(6*angs3);plot(.2*a+.6,'g')
axis tight


C(1) =  mean(DD(1:2:end));
C(2) =  mean(DD(2:2:end));

disp(['mean accuracy aligned trials: ' num2str(C(1))])
disp(['mean accuracy nonaligned trials: ' num2str(C(2))])
D(1) =  std(DD(1:2:end));
D(2) =  std(DD(2:2:end));
           
C
%% gridness
% clear G
% for k = 1:5 
%     rot = circshift(DD,[0,k]);
%     temp = corrcoef(rot,DD);
%     G(k) = temp(2,1);
% 
% end
% Gridness = min(G(2:2:end)) -  max(G(1:2:end))
Gridness = 100 * (mean(DD(1:2:end)) - mean(DD(2:2:end))) / mean(DD(2:2:end)); %(aligned - misaligned) / misaligned
disp(['Gridness: ' num2str(Gridness) ' %'])

%%
AAA = [4 5 6 7 8 ];
cont = 0;
for fold = AAA % 90, 60 y 45 grados
    cont = cont + 1;
    seno = sin(fold * ANGtotal1);
    coseno = cos(fold * ANGtotal1);
    
    stats = regstats(Correct1,[seno',coseno' ]);
    beta_seno = stats.beta(2);
    beta_coseno = stats.beta(3);
    angulo(cont) = atan2(beta_seno , beta_coseno)/fold;
    magnitud(cont) = sqrt(power(beta_seno,2) + power(beta_coseno,2));
    
    coseno_alineado = cos(fold * (ANGtotal2 - angulo(cont)));

    stats2 = regstats(Correct2,[coseno_alineado']);

    betas = stats2.beta;
    pvals = stats2.tstat.pval;


    Betas(cont) = betas(2);
    PP(cont) = pvals(2);
    R(cont) = stats2.rsquare;
end

figure
plot(AAA,PP,'.-'); title('P');
set(gca,'Xtick',AAA)
figure
plot(AAA,Betas,'.-'); title('B');
set(gca,'Xtick',AAA)
figure
plot(AAA,R,'.-'); title('R');
set(gca,'Xtick',AAA)

% %% agregando un regresor seno y coseno *1 
% seno1 = sin(1 * ANGtotal1);
% coseno1 = cos(1 * ANGtotal1);
% 
% seno6 = sin(6 * ANGtotal1);
% coseno6 = cos(6 * ANGtotal1);
% 
% stats = regstats(Correct1,[seno1',coseno1' seno6',coseno6' ]);
% 
% stats.beta
% stats.tstat.pval
% 
% beta_seno1 = stats.beta(2);
% beta_coseno1 = stats.beta(3);
% 
% beta_seno6 = stats.beta(4);
% beta_coseno6 = stats.beta(5);
% 
% 
% angulo1 = atan(beta_seno1 / beta_coseno1)/1
% angulo6 = atan(beta_seno6 / beta_coseno6)/6
% 
% coseno_alineado1 = cos(1 * (ANGtotal2 - angulo1));
% coseno_alineado6 = cos(6 * (ANGtotal2 - angulo6));
% 
% stats33 = regstats(Correct1,[coseno_alineado1' coseno_alineado6']);
% 
% betas = stats33.beta
% pvals = stats33.tstat.pval
% rs = stats33.rsquare
% 

%% 
% ANG = 2 * pi / 12;
% radsize = 10;
% counter = 0;
% figure, hold on;    
% for p = 0:length(DD)-1
%     counter = counter+1;
%     xx = radsize * cos(p * ANG);
%     yy = radsize * sin(p * ANG);
%     scatter(xx,yy,300,DD(p+1),'filled')
% end
% 
cd /home/pablo/Escritorio/
save(subject,'DD')
