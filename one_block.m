function data = one_block(p, number_trials)

% Define keyboard input keys 
one_l = KbName('v'); %Confidence scale for left tilted gratings
two_l = KbName('c');
three_l = KbName('x');
four_l = KbName('z');

one_r = KbName('n'); %Confidence scale for right tilted gratings
two_r = KbName('m');
three_r = KbName(',<');
four_r = KbName('.>');

nine = KbName('9(');

% Display 1 second of fixation in the beginning of the block
Screen('FillOval', p.window, 255, [p.width/2-2,p.height/2-2,p.width/2+2,p.height/2+2]);
Screen('Flip', p.window);
time = GetSecs + 1;

% Randomize the order of the trials (only works if number_trials is
% divisible by 4)
order = randperm(number_trials);
stim_type = mod(order,2) + 1; %1: left tilt, 2: right tilt


% Start the sequence of trials
for trial=1:number_trials
    
    %% Present fixation
    Screen('FillOval', p.window, 255, [p.width/2-2,p.height/2-2,p.width/2+2,p.height/2+2]);
    presentation_time(trial,1) = Screen('Flip', p.window, time);
    time = time + p.fixation_duration; % Update p.time to make sure the duration of the fixation is as specified
    
   
    %% Present stimulus
    % Figure out the stimulus orientation
    rotation_angle = 45 + 90*(stim_type(trial)-1); %45 degrees for left tilt, 135 degrees for right tilt
    
    % Make the stimulus
    stimulus_matrix = makeGaborPatch(p.stimSize, [], p.contrast, p.noiseContrast);
    ready_stimulus = Screen('MakeTexture', p.window, stimulus_matrix);
    
    % Draw the stimulus and present it
    Screen('DrawTexture', p.window, ready_stimulus, [], ...
        [p.width/2-p.stimSize/2,p.height/2-p.stimSize/2,p.width/2+p.stimSize/2,p.height/2+p.stimSize/2], rotation_angle);
    presentation_time(trial,2) = Screen('Flip', p.window, time);
    time = time + p.stim_duration; % Update p.time to make sure the duration of the stimulus is as specified
    
    
    %% Collect participant responses
    % Display first question
    Screen('DrawLine', p.window, 255, p.width/2-70, p.height/2+110, ...
        p.width/2-50, p.height/2+130, 4);
    Screen('DrawLine', p.window, 255, p.width/2+70, p.height/2+110, ...
        p.width/2+50, p.height/2+130, 4);
    DrawFormattedText(p.window, 'OR', 'center', p.height/2+100, 255);
    DrawFormattedText(p.window, '1              2', 'center', p.height/2+150, 255);
    Screen('FillOval', p.window, 255, [p.width/2-2,p.height/2-2,p.width/2+2,p.height/2+2]);
    presentation_time(trial,3) = Screen('Flip', p.window, time);
    
    %Check for the response - Both confidence and decision are encoded in
    %the same single response. 
    while 1
        [keyIsDown,secs,keyCode]=KbCheck;
        if keyIsDown
            
                if p.tms
                    TMS('Train', p.s, 0);  %Deliver the TMS pulse immediately after the first response
                end
                
            if keyCode(one_l)
                answer = 1;
                conf = 1;
                break;
            elseif keyCode(two_l)
                answer = 1;
                conf = 2;
                break;
            elseif keyCode(three_l)
                answer = 1;
                conf = 3;
                break;
            elseif keyCode(four_l)
                answer = 1;
                conf = 4;
                break;
            elseif keyCode(one_r)
                answer = 2;
                conf = 1;
                break;
            elseif keyCode(two_r)
                answer = 2;
                conf = 2;
                break;
            elseif keyCode(three_r)
                answer = 2;
                conf = 3;
                break;
            elseif keyCode(four_r)
                answer = 2;
                conf = 4;
                break;
            elseif keyCode(nine)
                answer = bbb; %forcefully break out
            end
        end
    end
    
    rt(trial,1) = secs - presentation_time(trial,2); % RT for the response 
    
%     % Confidence question
%     DrawFormattedText(p.window, 'CONFIDENCE', 'center', p.height/2+50, 255);
%     DrawFormattedText(p.window, '1     2     3     4', 'center', p.height/2+150, 255);
%     DrawFormattedText(p.window, 'low              high', 'center', p.height/2+200, 255);
%     Screen('FillOval', p.window, 255, [p.width/2-2,p.height/2-2,p.width/2+2,p.height/2+2]);
%     presentation_time(trial,4) = Screen('Flip', p.window); % Display immediately after first response
%     
   
    KbReleaseWait;
    
%     % Collect confidence response
%     while 1
%         [keyIsDown,secs,keyCode]=KbCheck;
%         if keyIsDown
%             if keyCode(one)
%                 conf = 1;
%                 break;
%             elseif keyCode(two)
%                 conf = 2;
%                 break;
%             elseif keyCode(three)
%                 conf = 3;
%                 break;
%             elseif keyCode(four)
%                 conf = 4;
%                 break;
%             elseif keyCode(nine)
%                 conf = bbb; %forcefully break out
%             end
%         end
%     end
%     rt(trial,2) = secs - presentation_time(trial,2); % RT for the second response 
    
    
    %% Give feedback and save data
    % Compute if answer is correct
    if stim_type(trial) == answer
        correct = 1;
    else
        correct = 0;
    end
    
    % Give feedback, if needed
    if p.feedback == 1
        if correct
            DrawFormattedText (p.window, 'CORRECT', 'center', 'center', [0 255 0]);
        else
            DrawFormattedText (p.window, 'WRONG', 'center', 'center', [255 0 0]);
        end
        Screen('Flip', p.window);
        WaitSecs(.5); %Present feedback for 500 ms
    end
    Screen('FillOval', p.window, 255, [p.width/2-2,p.height/2-2,p.width/2+2,p.height/2+2]);
    Screen('Flip', p.window);
    
    % Save data from current trial
    data.response(trial) = answer;
    data.confidence(trial) = conf; 
    data.correct(trial) = correct;

    % Give 1 second before next trial
    time = secs + 1;
end

% Save global block parameters
data.stimulus = stim_type;
data.rt = rt;
data.presentation_time = presentation_time;