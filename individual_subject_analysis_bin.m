clear,
close all
clc

if strcmp(computer, 'GLNXA64')
    direc = '/home/pablo/Documentos/trabajo/proyectos/2016-SperlingG';
else
    direc = 'tu path ';
end

subject = 'mg01';

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


angs = 0:.1:2*pi;
Paso = 360 / length(angs)


for p = 1:length(angs)-1
    inds = (ANGtotal1 > angs(p)) & (ANGtotal1 < angs(p+1));
    Correct11(p) = mean(Correct1(inds));
    Angulo11(p) = mean(ANGtotal1(inds));

    inds = (ANGtotal2 > angs(p)) & (ANGtotal2 < angs(p+1));
    Correct22(p) = mean(Correct2(inds));
    Angulo22(p) = mean(ANGtotal2(inds));
end





%% quadrature filter

Fold = 6;
seno = sin(Fold * Angulo11);               % SET 1
coseno = cos(Fold * Angulo11);

stats = regstats(Correct11,[seno',coseno' ]);

beta_seno = stats.beta(2);
beta_coseno = stats.beta(3);
pval1 = stats.tstat.pval(3);
angulo = atan2(beta_seno , beta_coseno)/Fold; 

ANGtotal_alineado2 = Angulo22 - angulo;   % 0 degrees now equals subject's 0 degrees (SET 2)

coseno_alineado = cos(Fold * ANGtotal_alineado2);

stats2 = regstats(Correct22,[coseno_alineado']);

beta = stats2.beta(2);
pval = stats2.tstat.pval(2);

disp('--------')
disp(['angle:     ' num2str(angulo * 180/pi),' grados'])
disp(['beta value: ' num2str(beta)])
disp(['P value:    ' num2str(pval)])
disp('--------')
%% aligned vs nonaligned. 
ANGtotal_alineado2rad = ANGtotal_alineado2;
ANGtotal_alineado2 = ANGtotal_alineado2 * 360 / (2*pi);

angs = 0:15:360;

temp2 = zeros(size(ANGtotal_alineado2));

for p = 1:length(angs)-1
    inds = (ANGtotal_alineado2 > angs(p)) & (ANGtotal_alineado2 < angs(p+1));
    CC{p} = Correct22(inds);
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


figure,
plot(Correct22,cos(Fold * ANGtotal_alineado2rad),'.')
lsline
xlabel('Accuracy')
ylabel('cos( 6 * ang)')


