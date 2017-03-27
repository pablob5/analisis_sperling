function [angulo, pval, beta, ANGtotal_alineado2,Correct22] = get_angle_nobin(subj,direc,angs,Fold)
cd(fullfile(direc,'data',subj))

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

%% odd runs 1, 3, 5
for i = 1:2:6                                                
    file = dir([subj, '_session',num2str(i),'*.mat']);
    
%     disp(file.name)
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


%% even runs 2, 4, 6
for i = 2:2:6                                                
    file = dir([subj, '_session',num2str(i),'*.mat']);
%     disp(file.name)
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


%% bins the angle

    Correct11 = Correct1;
    Angulo11 = ANGtotal1;

    Correct22 = Correct2;
    Angulo22 = ANGtotal2;

    

%% quadrature filter


seno = sin(Fold * Angulo11);               % set 1
coseno = cos(Fold * Angulo11);

stats = regstats(Correct11,[seno',coseno' ]);

beta_seno = stats.beta(2);
beta_coseno = stats.beta(3);
pval1 = stats.tstat.pval(3);
angulo = atan2(beta_seno , beta_coseno)/Fold;

ANGtotal_alineado2 = Angulo22 - angulo;   % 0 degrees now equals subject's 0 degrees (set 2)

coseno_alineado = cos(Fold * ANGtotal_alineado2);
stats2 = regstats(Correct22,[coseno_alineado']);

beta = stats2.beta(2);
pval = stats2.tstat.pval(2);

