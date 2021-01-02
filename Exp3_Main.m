%This script is written by Dongyu Gong (gdy17@mails.tsinghua.edu.cn)
%for the research project on saliency-specific distractor suppression.
%Please cite this article as:
% Gong, D., Theeuwes, J. A saliency-specific and dimension-independent mechanism 
%       of distractor suppression. Atten Percept Psychophys (2020). 
%       https://doi.org/10.3758/s13414-020-02142-8
%% Experiment 3
%% Prepare the environment
clear;
close all;
clc;
KbName('UnifyKeyNames');
commandwindow;
rng('Shuffle');
%% Intializing the variables
black = [0 0 0];
background = [5 5 5];
white = [255 255 255]; 
grey = [127 127 127];
green = [0 255 0];
scrlist=Screen('Screens');
myscreen = 0;
[w,h] = Screen('WindowSize',myscreen);
x_center = w/2; y_center = h/2;
[w_physical,h_physical] = Screen('DisplaySize',myscreen);% return physical size of the screen,in millimeter
Screen_Size = sqrt((w_physical/10)^2 + (h_physical/10)^2);% Screen size in centimeter,equals screen size in inch * 2.54
min_fixation = 0.7;
max_fixation = 1;
Fixation_Duration = (max_fixation - min_fixation).*rand(3000,1) + min_fixation;
Response_Window = 1.5;
ITI = 0.5;% intertrial interval
Target_Position = 8;
Size_Condition = [0 0.65 1.0];
Num_Condition = 3;
Distractor_Position = Target_Position - 1;
Rest_Time = 30;
Eccentricity = 4.35;
View_Distance = 72;
Circle_Diameter = 1.8 + Size_Condition;
Diamond_Diameter = 1.8;
Segment_Length = 0.8;
Thickness = 0.08;
Actual_Nprac = 20;
N_OneSession = 240;
Ntrial = N_OneSession * 9;
Actual_Ntrial = Ntrial;
Horz_Key = 's';
Vert_Key = 'k';
FixRect1=[-5 -1 5 1];
FixRect2=[-1 -5 1 5];
%% Converting Visual Angle to Pixel Size
% tan(beta/2)=s/2d
Eccentricity = 2 * View_Distance * tand(Eccentricity/2) * (w/(w_physical/10));
Circle_Diameter = 2 * View_Distance * tand(Circle_Diameter/2) * (w/(w_physical/10));
Diamond_Diameter = 2 * View_Distance * tand(Diamond_Diameter/2) * (w/(w_physical/10));
Segment_Length = 2 * View_Distance * tand(Segment_Length/2) * (w/(w_physical/10));
Half_Segment = Segment_Length/2;
Thickness = 2 * View_Distance * tand(Thickness/2) * (w/(w_physical/10));
%% Obtaining Subject Info
Items = {'Subject Number','Initials[e.g. Michael Jackson=MJ]','Gender[1=female,2=male,3=other]','Age','Handedness[1=right,2=left,3=other]'};
Title = 'Participant Information';
Sub_Info = inputdlg(Items,Title);
Sub_Number = Sub_Info{1};
Sub_Name = Sub_Info{2};
pwd = pwd();
if ~isdir([pwd '/Exp3_Participant_Data/' Sub_Name])
    mkdir([pwd '/Exp3_Participant_Data/' Sub_Name]);
end
Filename = ['Exp3_Result_' Sub_Number '_' Sub_Name];
number = str2double(Sub_Number);
if mod(number,8)==0
    HPL = 8; % HPL= high probability location
else
    HPL = mod(number,8);
end
%% Opening the Screen
Screen('Preference','SkipSyncTests',1);
[window,rect] = Screen('OpenWindow',myscreen,background);
Screen('BlendFunction',window,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
HideCursor();
%% Arranging the Positions
theta = linspace(0,360-360/Target_Position,Target_Position);
x_circle= x_center + cosd(theta)*Eccentricity;
y_circle = y_center + sind(theta)*Eccentricity;
Rect_Circle = [x_circle-Circle_Diameter(1)/2;y_circle-Circle_Diameter(1)/2; x_circle+Circle_Diameter(1)/2; y_circle+Circle_Diameter(1)/2];
Rect_Diamond = [x_circle y_circle-Diamond_Diameter/2; x_circle-Diamond_Diameter/2 y_circle;...
    x_circle y_circle+Diamond_Diameter/2; x_circle+Diamond_Diameter/2 y_circle];

%% Arranging Trial Info
loc = 1:8;
notHPL = loc(loc~=HPL);
distractor_ratio = [ones(1,104)*HPL repmat(notHPL,1,8) ones(1,26)*HPL repmat(notHPL,1,2)];
SESSION = zeros(6,N_OneSession);
SESSION(1,:) = [zeros(1,40)  distractor_ratio]; 
if mod(number,2)==0 % even numbers: LS has High Frequency
    SESSION(4,:) =  [ones(1,40) ones(1,160)*2 ones(1,40)*3];
else % odd numbers : HS has High Frequency
    SESSION(4,:) =  [ones(1,40) ones(1,160)*3 ones(1,40)*2];
end
SESSION(3,1:40) = repmat(1:8,1,5);
for i = 41:N_OneSession
    while 1
        SESSION(3,i) = randi(8);
        if SESSION(3,i) ~= SESSION(1,i)
            break
        end
    end
end
SESSION = SESSION(:,randperm(size(SESSION,2)));
SESSION2 = SESSION(:,randperm(size(SESSION,2)));
SESSION3 = SESSION(:,randperm(size(SESSION,2)));
SESSION4 = SESSION(:,randperm(size(SESSION,2)));
SESSION5 = SESSION(:,randperm(size(SESSION,2)));
SESSION6 = SESSION(:,randperm(size(SESSION,2)));
SESSION7 = SESSION(:,randperm(size(SESSION,2)));
SESSION8 = SESSION(:,randperm(size(SESSION,2)));
SESSION9 = SESSION(:,randperm(size(SESSION,2)));
VERT_HORZ = randi([1,2],8,Ntrial);
RESULTS = [SESSION SESSION2 SESSION3 SESSION4 SESSION5 SESSION6 SESSION7 SESSION8 SESSION9;VERT_HORZ];
Block_Accur = zeros(1,Ntrial/180);
Block_RT = zeros(1,Ntrial/180);
%% Practice Session
Exp3_Prac_Session;
while 1
    if Prac_Accur < 0.85
        DrawFormattedText(window,'Your accuracy is too low. Please Press SPACE BAR to do the practice again.','center','center',white);
        Screen('Flip',window);
        while 1
            [keyIsDown,secs,keyCode]=KbCheck();
            if keyCode(KbName('space'))
                break
            end
        end
        Exp3_Prac_Session;
    else
        break
    end
end
DrawFormattedText(window,'Now you can begin the Testing Session.\n\n Press SPACE BAR to continue','center','center',white);
Screen('Flip',window); 
while 1
    [keyIsDown,secs,keyCode]=KbCheck();
    if keyCode(KbName('space'))
        break
    end
end
WaitSecs(1);
%% Testing Session
%% Start
DrawFormattedText(window,'PLEASE READ THE INSTRUCTIONS AGAIN\n\n Put your middle or index fingers on the S and K keys on the keyboard.\n\n During every trial you will see a circular array.\n\n Your task is to find the DIAMOND and judge the orientation of the line segment contained in the DIAMOND.\n\n Press S if the line segment is Horizontal and K if it is Vertical.\n\n Please be as ACCURATE AND FAST as possible.\n\n Whenever you give a wrong response, you will hear a warning sound in the earphone.\n\n And note that it is VERY IMPORTANT to keep your eyes fixed on the fixation cross during every trial.\n\n Now press SPACE BAR to Start the Practice Session','center','center',white);
Screen('Flip',window);
while 1
    [keyIsDown,secs,keyCode]=KbCheck();
    if keyCode(KbName('space'))
        break
    end
end
Screen('Flip',window);
WaitSecs(ITI);
for ntrial = 1:Actual_Ntrial
    Screen('FillRect',window,  grey,[x_center y_center x_center y_center]+FixRect1); 
    Screen('FillRect',window,  grey,[x_center y_center x_center y_center]+FixRect2);
    Screen('Flip',window);
    WaitSecs(Fixation_Duration(ntrial));
    tmp_position = RESULTS(3,ntrial);
    diamond_position = Rect_Diamond(:,[tmp_position tmp_position+Target_Position]);
    Screen('FramePoly',window,green,diamond_position,Thickness);
    for ite = 1:8
            switch RESULTS(6+ite,ntrial)
                case 1
                    Screen('DrawLine',window,grey,x_circle(ite),y_circle(ite)-Half_Segment,x_circle(ite),y_circle(ite)+Half_Segment,Thickness);
                case 2
                    Screen('DrawLine',window,grey,x_circle(ite)-Half_Segment,y_circle(ite),x_circle(ite)+Half_Segment,y_circle(ite),Thickness);
            end
    end
    distractor = RESULTS(1,ntrial);
    switch RESULTS(4,ntrial)
        case 1

        case 2
            tmp_rect_circle=[x_circle-Circle_Diameter(2)/2;y_circle-Circle_Diameter(2)/2; x_circle+Circle_Diameter(2)/2; y_circle+Circle_Diameter(2)/2];
            Screen('FrameOval',window,green,tmp_rect_circle(:,distractor)',Thickness,Thickness);
        case 3
            tmp_rect_circle=[x_circle-Circle_Diameter(3)/2;y_circle-Circle_Diameter(3)/2; x_circle+Circle_Diameter(3)/2; y_circle+Circle_Diameter(3)/2];
            Screen('FrameOval',window,green,tmp_rect_circle(:,distractor)',Thickness,Thickness);
    end
    for ite = 1:8
        if tmp_position~=ite && distractor~=ite
            Screen('FrameOval',window,green,Rect_Circle(:,ite)',Thickness,Thickness);
        end
    end

    Screen('FillRect',window,  grey,[x_center y_center x_center y_center]+FixRect1); 
    Screen('FillRect',window,  grey,[x_center y_center x_center y_center]+FixRect2);
    Screen('Flip',window);
    start_time = GetSecs;
    while GetSecs < start_time + Response_Window
        [keyIsDown,secs,keyCode] = KbCheck();
        if keyCode(KbName(Horz_Key))
            RESULTS(6,ntrial) = GetSecs-start_time;
            RESULTS(2,ntrial) = 2; % response
            if RESULTS(6+tmp_position,ntrial)==2
                RESULTS(5,ntrial)=1;
            else
                beep;
            end
            break
        elseif keyCode(KbName(Vert_Key))
            RESULTS(6,ntrial) = GetSecs-start_time;
            RESULTS(2,ntrial) = 1; % response
            if RESULTS(6+tmp_position,ntrial)==1
                RESULTS(5,ntrial) = 1;
            else
                beep;
            end
            break
        end
    end
    Screen('Flip',window);
    WaitSecs(ITI);
    cd([pwd '/Exp3_Participant_Data/' Sub_Name]);
    save(Filename);
    cd ..
    if mod(ntrial,180)==0 && ntrial~=Actual_Ntrial
        block = ntrial/180;
        Block_Accur(block) = sum(RESULTS(5,(block-1)*180+1:block*180))/180;
        Block_RT(block) = sum(RESULTS(6,(block-1)*180+1:block*180))/180;
        start_time=GetSecs;
        while GetSecs < start_time+Rest_Time
            time_left = ceil(Rest_Time-(GetSecs - start_time));
            DrawFormattedText(window,['You have finished ' num2str(block) ' out of 12 blocks.\n\n Your average response time in this block is ' num2str(Block_RT(block)) '\n\nYour accuracy in this block is' num2str(Block_Accur(block)) '\n\nTime for a break!\n\n Time left:',...
                num2str(time_left),' secs'],'center','center',white);
            Screen('Flip',window);
        end
        DrawFormattedText(window,'Press any key to continue','center','center',white);
        Screen('Flip',window);
        KbWait;
    elseif ntrial==Actual_Ntrial
        block = ntrial/180;
        Block_RT(block) = sum(RESULTS(6,(block-1)*180+1:block*180))/180;
        Block_Accur(block) = sum(RESULTS(5,(block-1)*180+1:block*180))/180;
        DrawFormattedText(window,['Your average response time in this block is ' num2str(Block_RT(block)) '\n\nYour accuracy in this block is' num2str(Block_Accur(block)) '\n\n You have finished the experiment.Press any key to exit.'],'center','center',white);
        Screen('Flip',window);
        KbWait;
    end
end
sca;
ShowCursor();