function sperlingG()
%------------------------ parametros -----------------------
debug          = 0;
data_directory = '/home/pablo/Documentos/trabajo/proyectos/2016-SperlingG/data_cba';
SOA            = 2;  % number of frames beween letter array and target
Frames_time1   = 48; % number of frames between fixation dot and letter array
Frames_time2   = 6;  % number of frames the letter array is on screen
POS            = 1:12;
ANG            = 2 * pi / 12;
N_Repetitions  = 25;
radsize        = 180;
ITI            = 1; % second
N_TRIALS       = length(POS) * N_Repetitions * length(SOA);
colorborde     = [153, 153, 255];
LETLIST        = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
spotDiameter   = 10; % size of fixation dot
Lettersize     = 28; % size of letters in the array
%----------------------------------------------------------

PsychDefaultSetup(2);
KbName('UnifyKeyNames');
prompt = {'Tu nombre: ','Nro de sesion: '};
dlg_title = '...';
num_lines = 1;
default = {'XX','0'};
nombre = inputdlg(prompt,dlg_title,num_lines,default);
outfile = fullfile(data_directory,strcat(nombre{1},'_session',nombre{2},'_',num2str(round(rand * 10000000000)),'.mat'));

%----------------------------------------------------------
screens = Screen('Screens');
screenNumber = max(screens);
black = BlackIndex(screenNumber);

if debug
    W = 800;
    H = 600;
else
    Pix = get(0,'screensize'); % screen resolution
    W = Pix(3);
    H = Pix(4);
end
CX = W / 2;
CY = H / 2;

Trials = generate_trials_struct(SOA, POS, N_Repetitions, LETLIST);

DataToSave      = struct();
DataToSave.date = datestr(now);
DataToSave.name_session = strcat(nombre{1},'_session_',nombre{2});
DataToSave.AllTrials    = Trials;

try
    HideCursor;
    whichScreen = 0;
    
    if debug
        [w,Rect] = Screen('OpenWindow',whichScreen,black,[0, 0, 800, 600]);
    else
        [w,Rect] = Screen('OpenWindow',whichScreen,black);
    end
    
    topPriorityLevel = MaxPriority(w);
    Priority(topPriorityLevel);
    ifi = Screen('GetFlipInterval', w)
    DataToSave.FlipInterval = ifi;
    
    texto(w,'Barra espaciadora para comenzar',25,[255, 255, 204],300,350)
    Screen('Flip', w);
    
    FlushEvents('keyDown','autoKey');
    while 1
        [ keyIsDown, secs, keyCode ] = KbCheck;
        if keyIsDown
            keyCode = find(keyCode, 1);
            if strcmp(KbName(keyCode),'ESCAPE'),disp('cancelado');ShowCursor;Screen('CloseAll');return;end
            if strcmp(KbName(keyCode),'space'), break; end
        end
    end
    
    Screen('Flip', w);
    WaitSecs(2);

    for tr = 1:N_TRIALS
        WaitSecs(ITI);

        ANGrand = rand * ANG;
        DataToSave.trial(tr).ANGrand = ANGrand;
        
        show_circulos(w,radsize,CX,CY, colorborde, spotDiameter);                          % show circle positions
        vbl1 = Screen('Flip', w);

        generatescreen(Trials(tr).trial,w,POS,radsize,ANG,CX,CY,LETLIST, ANGrand,colorborde, spotDiameter, Lettersize);
        vbl2 = Screen('Flip', w , vbl1 + (Frames_time1- 0.5) * ifi);           % letter array
        
        generatesquare(w,radsize,CX,CY,colorborde);       
        vbl3 = Screen('Flip', w , vbl2 + (Frames_time2- 0.5) * ifi);

        frames = Trials(tr).trial.SOA;
        show_target(Trials(tr).trial,w,POS,radsize,ANG,CX,CY, ANGrand,colorborde, spotDiameter);
        TimeSt = Screen('Flip', w , vbl3 + (frames - 0.5) * ifi);             % target
        
        DataToSave.trial(tr).SOA = Trials(tr).trial.SOA;
        
        vbl2 - vbl1 
        vbl3 - vbl2 
        KbReleaseWait;
        wt = 1;
        while wt
            [ keyIsDown, seconds, keyCode] = KbCheck;
            if keyIsDown
                if strcmp(KbName(keyCode),'ESCAPE')
                    disp('cancelado');
                    ShowCursor;
                    Screen('CloseAll');
                    save(outfile,'DataToSave');
                    clear mex;
                    return;
                else
                    ind = Trials(tr).trial.Stim(Trials(tr).trial.Position);
                    res = lower(KbName(keyCode));
                    if length(res)==1
                        if any(strcmpi(LETLIST,res))
                            wt = 0;
                            DataToSave.trial(tr).Response  = res;
                            DataToSave.trial(tr).Target    = lower(LETLIST{ind});
                            DataToSave.trial(tr).Correct   = res == lower(LETLIST{ind});
                            DataToSave.trial(tr).RT        = seconds - TimeSt;
                        end
                    end
                end
            end
        end
        Screen('Flip', w);
        WaitSecs(.25);
        output =get_intr_resp(w);
        Screen('Flip', w);
        
        DataToSave.trial(tr).Confidence = output.segu;
        DataToSave.trial(tr).RTconf     = output.segutime;
              
        if ~mod(tr,50), pausa(w, outfile);end
    end    
    
    %% termino
    Priority(0);
    ShowCursor;
    Screen('CloseAll');
    save(outfile,'DataToSave');
    
catch
    save(outfile,'DataToSave');
    rethrow(lasterror);
    Priority(0);
    Screen('CloseAll');
    fclose(fid);
    ShowCursor;
end
end

%% funciones
% ---------------------------------------------------------------
function texto(w,text,size,color,xx,yy)
Screen('TextFont',w, 'Arial');
Screen('TextSize',w, size);
Screen('DrawText', w, text,xx,yy, color);
end

% ---------------------------------------------------------------
function show_circulos(w,radsize,CX,CY,colorborde,spotDiameter)

spotRect = [0, 0, spotDiameter, spotDiameter];
centeredspotRect =  CenterRectOnPoint(spotRect, CX,CY);

Screen('FillOval', w, [255, 102, 0],centeredspotRect);
Screen('DrawLine', w, colorborde , CX - radsize* 1.5, CY + radsize * 1.3, CX + radsize * 1.5, CY + radsize * 1.3, 3);
Screen('DrawLine', w, colorborde, CX - radsize* 1.5, CY - radsize * 1.3, CX - radsize * 1.5, CY + radsize * 1.3, 3);
Screen('DrawLine', w, colorborde, CX + radsize* 1.5, CY - radsize * 1.3, CX + radsize * 1.5, CY + radsize * 1.3, 3);
Screen('DrawLine', w, colorborde, CX - radsize* 1.5, CY - radsize * 1.3, CX + radsize * 1.5, CY - radsize * 1.3, 3);
end

% ---------------------------------------------------------------
function generatescreen(tr,w,POS,radsize,ANG,CX,CY,LETLIST, ANGrand,colorborde,spotDiameter,Lettersize)
spotRect = [0, 0, spotDiameter, spotDiameter];
centeredspotRect =  CenterRectOnPoint(spotRect, CX,CY);
Screen('FillOval', w, [255, 102, 0],centeredspotRect);

counter = 0;
for p = POS
    counter = counter+1;
    xx = radsize * cos(p * ANG + ANGrand);
    yy = radsize * sin(p * ANG + ANGrand);
    [normBoundsRect, offsetBoundsRect]= Screen('TextBounds', w, LETLIST{tr.Stim(p)}); 
    texto(w,LETLIST{tr.Stim(p)},Lettersize,255,xx + CX - floor(normBoundsRect(3)/2) ,yy + CY - floor(normBoundsRect(4)/2));
end

Screen('DrawLine', w, colorborde , CX - radsize* 1.5, CY + radsize * 1.3, CX + radsize * 1.5, CY + radsize * 1.3, 3);
Screen('DrawLine', w, colorborde, CX - radsize* 1.5, CY - radsize * 1.3, CX - radsize * 1.5, CY + radsize * 1.3, 3);
Screen('DrawLine', w, colorborde, CX + radsize* 1.5, CY - radsize * 1.3, CX + radsize * 1.5, CY + radsize * 1.3, 3);
Screen('DrawLine', w, colorborde, CX - radsize* 1.5, CY - radsize * 1.3, CX + radsize * 1.5, CY - radsize * 1.3, 3);

end

% ---------------------------------------------------------------
function generatesquare(w,radsize,CX,CY,colorborde)
Screen('DrawLine', w, colorborde ,CX - radsize* 1.5, CY + radsize * 1.3, CX + radsize * 1.5, CY + radsize * 1.3, 3);
Screen('DrawLine', w, colorborde, CX - radsize* 1.5, CY - radsize * 1.3, CX - radsize * 1.5, CY + radsize * 1.3, 3);
Screen('DrawLine', w, colorborde, CX + radsize* 1.5, CY - radsize * 1.3, CX + radsize * 1.5, CY + radsize * 1.3, 3);
Screen('DrawLine', w, colorborde, CX - radsize* 1.5, CY - radsize * 1.3, CX + radsize * 1.5, CY - radsize * 1.3, 3);
end

% ---------------------------------------------------------------
function show_target(tr,w,POS,radsize,ANG,CX,CY, ANGrand,colorborde,spotDiameter)
spotRect = [0, 0, spotDiameter, spotDiameter];
centeredspotRect =  CenterRectOnPoint(spotRect, CX,CY);
counter = 0;
for p = POS
    counter=counter+1;
    xx = radsize * cos(p * ANG + ANGrand);
    yy = radsize * sin(p * ANG + ANGrand);
    offsetCenteredspotRect = OffsetRect(centeredspotRect, xx, yy);
    if p == tr.Position
        Screen('FillOval', w, [255 0 0],offsetCenteredspotRect);
    else
        Screen('FillOval', w, colorborde,offsetCenteredspotRect);
    end
end
Screen('DrawLine', w, colorborde , CX - radsize* 1.5, CY + radsize * 1.3, CX + radsize * 1.5, CY + radsize * 1.3, 3);
Screen('DrawLine', w, colorborde, CX - radsize* 1.5, CY - radsize * 1.3, CX - radsize * 1.5, CY + radsize * 1.3, 3);
Screen('DrawLine', w, colorborde, CX + radsize* 1.5, CY - radsize * 1.3, CX + radsize * 1.5, CY + radsize * 1.3, 3);
Screen('DrawLine', w, colorborde, CX - radsize* 1.5, CY - radsize * 1.3, CX + radsize * 1.5, CY - radsize * 1.3, 3);
end

% ---------------------------------------------------------------
function trials = generate_trials_struct(SOA, POS, N_Repetitions,LETLIST)

trials = struct();
Numero_Trial = 0;

for s = SOA
    poscounter = 0;
    for p = POS
        poscounter = poscounter + 1;
        for n = 1:N_Repetitions
            tr = struct();
            temp = [];
            
            Numero_Trial = Numero_Trial+1;
            IND_ESTIM    = Shuffle(1:length(LETLIST));
            
            temp = IND_ESTIM(1:12);          
           
            tr.SOA = s;
            tr.Position = p;
            tr.Stim = temp;
            
            trials(Numero_Trial).trial = tr;
            
        end
    end
end
trials = Shuffle(trials);
end

% ---------------------------------------------------------------
function [output] = get_intr_resp(w)
HideCursor;
[anchopant,altopant]=WindowSize(w);

[CX, CY]=WindowCenter(w);
lineWidthsMouse = 3;
width  = anchopant;

anchoresp = 2*round(width*.3);
posysegu = CY;
Col = [255, 255, 204];
texto(w,'Ni idea',16,Col,CX-anchoresp/2-60,posysegu-50);
texto(w,'Muy seguro',16,Col,CX+anchoresp/2-60,posysegu-50);

Screen('DrawLine', w, Col, CX, posysegu+10, CX, posysegu-10, lineWidthsMouse);
Screen('DrawLine', w, Col, CX-anchoresp/2, posysegu, CX+anchoresp/2, posysegu, lineWidthsMouse);

%% toma respuesta seguridad
aux=0;start = GetSecs;

while aux==0
    texto(w,'Ni idea',16,   Col, CX - anchoresp/2-60,  posysegu - 50);
    texto(w,'Muy seguro',16,Col, CX + anchoresp/2-60,  posysegu - 50);
    Screen('DrawLine', w,   Col, CX, posysegu+10, CX,  posysegu-10, lineWidthsMouse);
    Screen('DrawLine', w,   Col, CX - anchoresp/2,     posysegu, CX + anchoresp/2, posysegu, lineWidthsMouse);
    
    [x,y,buttons] = GetMouse;
    x = max(CX - anchoresp/2,min(x,CX + anchoresp/2));
    
    dd = [num2str(round(100*(x-CX)/anchoresp)+50) ' %'];
    texto(w,dd ,16,Col,x,posysegu - 30);
    
    Screen('FillOval', w, [255, 102, 0], [x-5 posysegu-5 x+5 posysegu+5 ]);
    Screen('Flip', w);
    
    if any(buttons)
        aux = 1;
        output.segu     = ((x-CX)/anchoresp) + .5;
        output.segutime = GetSecs - start;
    end
end

end

% ---------------------------------------------------------------
function pausa(w, outfile)
texto(w,'Pausa. Barra espaciadora para continuar',25,[255, 255, 204],300,350)
Screen('Flip', w);

FlushEvents('keyDown','autoKey');
    while 1
        [ keyIsDown, secs, keyCode ] = KbCheck;
        if keyIsDown
            keyCode = find(keyCode, 1);
            if strcmp(KbName(keyCode),'ESCAPE'),disp('cancelado');ShowCursor;Screen('CloseAll');save(outfile,'DataToSave');return;end
            if strcmp(KbName(keyCode),'space'), break; end
        end
    end
Screen('Flip', w);
WaitSecs(2);
end


