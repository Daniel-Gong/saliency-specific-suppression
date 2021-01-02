% Don't run this script directly. Run from the Main script.
%%  Arranging Practice Session Trial Info
PRAC = RESULTS(:,randi([1,Ntrial],1,Actual_Nprac));
accuracy = zeros(1,Actual_Nprac);
rt_prac = zeros(1,Actual_Nprac);
%% Start
WaitSecs(1);
DrawFormattedText(window,'Put your middle or index fingers on the S and K keys on the keyboard.\n\n During every trial you will see a circular array.\n\n Your task is to find the DIAMOND and judge the orientation of the line segment contained in the DIAMOND.\n\n Press S if the line segment is Horizontal and K if it is Vertical.\n\n Please be as ACCURATE AND FAST as possible.\n\n Whenever you give a wrong response, you will hear a warning sound in the earphone.\n\n And note that it is VERY IMPORTANT to keep your eyes fixed on the fixation cross during every trial.\n\n Now press SPACE BAR to Start the Practice Session','center','center',white);
Screen('Flip',window);
while 1
    [keyIsDown,secs,keyCode]=KbCheck();
    if keyCode(KbName('space'))
        break
    end
end
Screen('Flip',window);
WaitSecs(ITI);
for nprac = 1:Actual_Nprac
    Screen('FillRect',window,  grey,[x_center y_center x_center y_center]+FixRect1); 
    Screen('FillRect',window,  grey,[x_center y_center x_center y_center]+FixRect2);
    Screen('Flip',window);
    WaitSecs(Fixation_Duration(nprac));
    position = PRAC(3,nprac);
    diamond_position = Rect_Diamond(:,[position position+Target_Position]);
    Screen('FramePoly',window,green,diamond_position,Thickness);
    for ite = 1:8
            switch PRAC(6+ite,nprac)
                case 1
                    Screen('DrawLine',window,grey,x_circle(ite),y_circle(ite)-Half_Segment,x_circle(ite),y_circle(ite)+Half_Segment,Thickness);
                case 2
                    Screen('DrawLine',window,grey,x_circle(ite)-Half_Segment,y_circle(ite),x_circle(ite)+Half_Segment,y_circle(ite),Thickness);
            end
    end
    distractor = PRAC(1,nprac);
    switch PRAC(4,nprac)
        case 1
            %Screen('FrameOval',window,green,Rect_Circle(:,distractor)',Thickness,Thickness);
        case 2
            tmp_rect_circle=[x_circle-Circle_Diameter(2)/2;y_circle-Circle_Diameter(2)/2; x_circle+Circle_Diameter(2)/2; y_circle+Circle_Diameter(2)/2];
            Screen('FrameOval',window,green,tmp_rect_circle(:,distractor)',Thickness,Thickness);
        case 3
            color=Color_Condition;
            Screen('FrameOval',window,color,Rect_Circle(:,distractor)',Thickness,Thickness);            
    end
    for ite = 1:8
        if position~=ite && distractor~=ite
            Screen('FrameOval',window,green,Rect_Circle(:,ite)',Thickness,Thickness);
        end
    end
    %Screen('FillOval', window,grey,[x_center-4 y_center-4 x_center+4 y_center+4]);
    Screen('FillRect',window,  grey,[x_center y_center x_center y_center]+FixRect1); 
    Screen('FillRect',window,  grey,[x_center y_center x_center y_center]+FixRect2);
    Screen('Flip',window);
    start_time = GetSecs;
    while GetSecs < start_time + Response_Window
        [keyIsDown,secs,keyCode] = KbCheck();
        if keyCode(KbName(Horz_Key))
            if PRAC(6+position,nprac)==2
                accuracy(nprac) = 1;
                rt_prac(nprac) = GetSecs-start_time;
            else
                beep;
                rt_prac(nprac) = GetSecs-start_time;
            end
            break
        elseif keyCode(KbName(Vert_Key))
            if PRAC(6+position,nprac)==1
                accuracy(nprac) = 1;
                rt_prac(nprac) = GetSecs-start_time;
            else
                beep;
                rt_prac(nprac) = GetSecs-start_time;
            end
            break
        end
    end
    Screen('Flip',window);
    WaitSecs(ITI);
end
Prac_Accur = sum(accuracy)/Actual_Nprac;
Prac_Avgrt = sum(rt_prac)/Actual_Nprac;
DrawFormattedText(window,['Practice Session finished.\n\n Your average response time is ' num2str(Prac_Avgrt) '\n\n Your accuracy is ' num2str(Prac_Accur) '\n\n Press SPACE BAR to continue'],'center','center',white);
Screen('Flip',window);
while 1
    [keyIsDown,secs,keyCode]=KbCheck();
    if keyCode(KbName('space'))
        break
    end
end
Screen('Flip',window);
WaitSecs(1);