%server eeg
t_e = tcpip('localhost', 3000, 'NetworkRole', 'Server');
set(t_e , 'InputBufferSize', 3000);
% Open connection to the client.
fopen(t_e);
fprintf('%s \n','Client Connected');
connectionServer = t_e;
set(connectionServer,'Timeout',.1);
% f_d=fread(t_e,1)

escapeKey = KbName('esc');
waitKey=KbName('s');
resetKey=KbName('r');
weight_up=KbName('up');
weight_down=KbName('down');
bias_plus=KbName('right');
bias_minus=KbName('left');

%screen setting (gray)
screenRes = [0 0 640 480];
screens=Screen('Screens');
screenNumber=max(screens);
gray=GrayIndex(screenNumber);
[w, wRect]=Screen('OpenWindow',screenNumber, gray,screenRes);
fixSize = 10;
% ScreenP = Psychtoolbox_Open_Kb(screenNumber,fixSize);
[X,Y] = RectCenter(wRect);
PixofFixationSize = 20;
FixCross = [X-1,Y-PixofFixationSize,X+1,Y+PixofFixationSize;X-PixofFixationSize,Y-1,X+PixofFixationSize,Y+1];
Screen('FillRect', w, [255 0 0], FixCross');
Screen('Flip', w);
Screen('DrawText', w, 'Top-Left aligned, max 40 chars wide: Hit any key to continue.', 0, 0, [255, 0, 0, 255]);
cal_on=true;
weight=1;
bias=0;
while cal_on
    [ keyIsDown, seconds, keyCode ] = KbCheck;
    switch keyIsDown
        case keyCode(escapeKey)
            cal_on=false;
            break;
        case keyCode(waitKey)
        case keyCode(weight_up)
            weight=weight+0.1;
        case keyCode(weight_down)
            if weight<0
                weight=0;
            else
            weight=weight-0.1;
            end
        case keyCode(bias_plus)
            bias=bias+0.1;
        case keyCode(bias_minus) 
            bias=bias-0.1;
        case resetKey
            FixCross = [X-1,Y-PixofFixationSize,X+1,Y+PixofFixationSize;X-PixofFixationSize,Y-1,X+PixofFixationSize,Y+1];
    end
        
    f_eeg=fread(t_e,1);
    if ~isempty(f_eeg)
        str=sprintf('weight=%f, bias=%f',weight, bias);
        DrawFormattedText(w, str, 0, 0, [0, 0, 0, 255]);
        Screen('FillRect', w, [255 0 0], FixCross');
        Screen('Flip', w);
        FixCross(1,1)=FixCross(1,1)+(f_eeg*weight)+bias;
        FixCross(2,1)=FixCross(2,1)+(f_eeg*weight)+bias;
        FixCross(1,3)=FixCross(1,3)+(f_eeg*weight)+bias;
        FixCross(2,3)=FixCross(2,3)+(f_eeg*weight)+bias;
    end
    %     pause(0.1);
end

Screen('CloseAll');