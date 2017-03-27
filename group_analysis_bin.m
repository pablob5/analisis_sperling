clear,
close all
clc

grafica = 0;
bins = 0;
if strcmp(computer, 'GLNXA64')
    direc = '/home/pablo/Documentos/trabajo/proyectos/2016-SperlingG';
else
    direc = 'tu path ';
end

cd(fullfile(direc,'analisis_sperling'))
sublist


angs = 0:.05:2*pi;
Paso = 360 / length(angs);
Fold = 6;


%%
X = [];
for s = 1:length(subjects)
    disp(subjects{s})
    if bins
        [angulo(s), pval(s), beta(s), corrected_angles{s}, accuracy{s}] = get_angle_bin(subjects{s},direc,angs,Fold);
    else
        [angulo(s), pval(s), beta(s), corrected_angles{s}, accuracy{s}] = get_angle_nobin(subjects{s},direc,angs,Fold);
    end
    
    if any(isnan(accuracy{s})) | any(isnan(corrected_angles{s}))
        error('nans in the data, make larger bins')
    end
    
    cosine = cos(Fold * corrected_angles{s});
    
    X = [ X; s * ones(length(accuracy{s}),1) cosine' accuracy{s}'];
end

tbl = table(nominal(X(:,1)),X(:,2),X(:,3),'VariableNames',{'subject','cos','accuracy'});

lme = fitlme(tbl,'accuracy~cos + (1|subject)')

pval = lme.anova.pValue(2)




%%
if grafica
    bins = [];
    for s = 1:length(subjects)
        bins(:,s) = get_bins_circle(corrected_angles{s}, accuracy{s});
    end
    
    DD = mean(bins,2);
    ST = std(bins,0,2) / sqrt(size(bins,2));
    
    
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
end


