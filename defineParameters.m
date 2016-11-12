function p = defineParameters()

%% Open window and do useful stuff
[p.window,p.width,p.height] = openScreen();
Screen('TextFont',p.window, 'Arial');
Screen('TextSize',p.window, 30);
Screen('FillRect', p.window, 127); 
p.wrapat = 80;


%% Define the parameters for the experiment
p.trials_per_block = 40;
p.trials_per_tms_training_block = 16;


%% Set the stimulus details
p.fixation_duration = .5;
p.stim_duration = .1;
p.noiseContrast = .8;
p.initialContrastForStaircase = .1;

% Determine the size and locations of the gratings
p.stimSize_degrees = 3; %in degrees
p.stimSize = degrees2pixels(p.stimSize_degrees); %in pixels