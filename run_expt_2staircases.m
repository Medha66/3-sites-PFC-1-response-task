%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Before running the experiment:
% (1) Set Train in MagPro to 3 pulses with inter-pulse interval of 150 ms
% (2) Run the following code in MATLAB:
% s = TMS('Open'); TMS('Amplitude',s, 20)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    Screen('Preference','SkipSyncTests',1);
    % Clear the workspace
    clear p   
    
    %% Get subject and session info
    subjNum = input('Subject number: ');
    resultsFile = [pwd, filesep, 'results_s' num2str(subjNum) '.mat'];
    
    %%
    
    % Check if data for this subjects already exists
    if exist(resultsFile, 'file') == 0 %data don't exist -> do training/thresholding
        infoCorrect = input('This is a new subject, correct? 1=y, 0=n ');
        if infoCorrect ~= 1
            Error('Wrong information input');
        end
        
        % Define the parameters of the experiment
        p = defineParameters;
        p.tms = 0;
        
        % Give training
        %p = training(p);
        p = training_2staircases(p);
        
        %One block with TMS 
       
        % Decide on TMS site for each block
        p.tmsSiteOrder = [randperm(3) randperm(3), randperm(3), randperm(3), randperm(3), randperm(3)]; %1 block of training with TMS (including all three regions) and 5 runs of 3 blocks each
        
        % Save results
        p.subjNum = subjNum;
        p.blockCompleted = 0;
        p.current_block_num = 1;
        p.feedback = 0;
        save(resultsFile, 'p');
        
        % Give end-of-training message
        DrawFormattedText(p.window, 'You have completed the training.', 'center', 'center', 255);
        Screen('Flip', p.window);
        WaitSecs(2);
        KbWait;
        
        % Close all windows
        Screen('CloseAll');
        
        
    else %data exists -> continue with expt
        
        % Load data and display number of completed runs
        load(resultsFile);
        infoCorrect = input(['Subject has completed ' num2str(p.blockCompleted) ...
            ' blocks. Is this correct? 1=y, 0=n ']);
        if infoCorrect ~= 1
            Error('Wrong information input');
        end
        
        
        % Input TMS parameters before the first session
        if p.blockCompleted == 0
            p.tms = input('TMS session? 1:y, 0:n ');
            if p.tms == 1
                p.tmsIntensity = input('TMS intensity = ');
                
                infoCorrect = input(['TMS intensity will be ' num2str(p.tmsIntensity) ...
                    ' . Is this correct? 1=y, 0=n ']);
                if infoCorrect ~= 1
                    Error('Wrong information input');
                end
                
                % Enable TMS machine and set amplitude
                TMS('Enable', s)
                TMS('Amplitude', s, p.tmsIntensity)
                p.s = s;
            end
        end
                
     p.total_num_blocks = 18;        
     % Open window and do useful stuff
        [p.window,p.width,p.height] = openScreen();
        Screen('TextFont',p.window, 'Arial');
        Screen('TextSize',p.window, 30);
        Screen('FillRect', p.window, 127);
        
  for i = 1:p.total_num_blocks
        
        
        % Update current block
        p.currentBlock = p.blockCompleted+1;
        run = floor((p.currentBlock-1)/3)+1;  %To calculate which run is being done. (1-3 - run 1 (tms training), 4-6 - run 2, etc)
        blockInRun = p.currentBlock - 3*(run-1);
        
        % Instructions
        text = ['Run: ' num2str(run) ', Block: ' num2str(blockInRun) '.     Site number: ' num2str(p.tmsSiteOrder(p.currentBlock)) ...
            '\n\nRemember to:'...
            '\n- Always fixate on the small fixation circle and not move your eyes around. '...
            '\n- Do your best!'...
            '\n\n\nWhen instructed, press the space key to start.'];
        DrawFormattedText(p.window, text, 300, 'center', 255, p.wrapat);
        Screen('Flip',p.window);
        WaitSecs(3);
        KbWait;
        
        % Perform next block of experiment
        
        if run == 1
            data = one_block(p, p.trials_per_tms_training_block);
        else
            data = one_block(p, p.trials_per_block);
        end
        
        % Save results from block
        p.data{p.currentBlock} = data;
        p.blockCompleted = p.blockCompleted + 1;
        save(resultsFile, 'p');
        
        % Disable TMS and give end-of-block message
        if p.tms
            TMS('Disable', s);
        end
        
        Beeper('med',1,1)
        
        DrawFormattedText(p.window, 'You have completed the block.', 'center', 'center', 255);
        Screen('Flip', p.window);
        WaitSecs(2);
        KbWait;
        
        
   
   end
        
        % Close all windows
        Screen('CloseAll');
    end
    
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end