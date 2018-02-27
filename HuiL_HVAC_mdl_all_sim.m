%% HuiL_HVAC_mdl_all_sim ( varargin )
% Simulates the human-in-the-loop interactions with the HVAC system
% Any model parameter defined before the section
%   'Overwrite parameters using input arguments' can be overwritten
%   as a name, value pair in varargin.
%
% NOTE Matlab will show 'value assigned...might be unused' warnings
%       
% TODO correct simulink timescale units. (Should say hours, now says sec)
%       This doesn't cause any issues, just not appropriately labeled.
% TODO create structures of parameters for each subsystem and overwrite 
%       with inputs using dynamic structures instead of eval(). 
%       This requires changing all the variable values in the 
%       Simulink model though.
function results = HuiL_HVAC_mdl_all_sim(varargin)

t_step = 0;
sim_dur = 48; % hours

%% SCT Model Parameters

% Time delays
theta = zeros(19,1);

% Noise
zeta_var = 0; % 0.01

% Time constants
tau = 0.1*[...
    1   % Self-mgmt skills
    1   % Outcome expectancy 
    1   % Self-efficacy
    2   % Behavior
    1   % Behavioral outcomes
    3]';% Cue to action

% Input multipliers
beta_21 = 0.3;  % Self-mgmt skills      -> Outcome expectancy 
beta_31 = 0.5;  % Self-mgmt skills      -> Self-efficacy
beta_42 = 0.3;  % Outcome expectancy    -> Behavior
beta_43 = 0.8;  % Self-efficacy         -> Behavior
beta_14 = 0.23; % Behavior              -> Self-mgmt skills
beta_34 = 0.2;  % Behavior              -> Self-efficacy
beta_54 = 0.3;  % Behavior              -> Behavioral outcomes
beta_25 = 0.3;  % Behavioral outcomes   -> Outcome expectancy 
beta_45 = 0.0;  % Behavioral outcomes   -> Behavior
beta_46 = 0.55;  % Cue to action         -> Behavior

% State multipliers
gamma_11 = 0.8;     % Skills training			-> Self-mgmt skills   
gamma_22 = 0.75;    % Observed behavior		 	-> Outcome expectancy 
gamma_32 = 1.6;     % Observed behavior		 	-> Self-efficacy  
gamma_33 = 0.75;    % Perceived social support 	-> Self-efficacy 
gamma_64 = 20;      % Internal cues			 	-> Cue to action  
gamma_35 = 1;       % Perceived barriers		-> Self-efficacy  
gamma_36 = 1;       % Intrapersonal states	 	-> Self-efficacy   
gamma_57 = 2;       % Environmental context		-> Behavioral outcomes
gamma_68 = 5;       % External cues			 	-> Cue to action  

% Inputs %
%%%%%%%%%%

% Skill training
xi_1_0      = 3; 

% Observed behavior
xi_2_0      = 5; 
xi_2_on     = 5; % 50
t_xi_2_on   = 7;
t_xi_2_off  = 14;

% Perceived support
xi_3_0      = 5; 
xi_3_on     = 5; % 50
t_xi_3_on   = 7;
t_xi_3_off  = 14;

% Internal cues
xi_4_case   ='body';
switch xi_4_case
    case 'const'
		disp('Using constant internal cues (xi_4)');
        VSS_xi_4_gen = 1;
        xi_4_0       = 0;
        
    case 'body'
		disp('Using comfort model as internal cue (xi_4)');
        VSS_xi_4_gen = 2;  
    otherwise
        error('HuiL_HVAC_mdl_sim:noXiCase', ...
            'The switch case ''%s'' does not exist', xi_4_case);
end

% Perceived barriers
xi_5_0      = 3; 
xi_5_on     = 3; % 3
t_xi_5_on   = 7;
t_xi_5_off  = 14;

% Intrapersonal states
xi_6_0      = 0; 
xi_6_var    = 0; % 100
xi_6_phi    = 0.6;

% Environmental context
xi_7_0      = 0;
xi_7_var    = 0; % 100
xi_7_phi    = 0.8;

% External cues
xi_8_0 = 0;
xi_8_on = 0;
t_xi_8_on = 0;
t_xi_8_off = 0;  

%% Body physiology model parameters
%   REF: 2013 ASHRAE handbook: fundamentals.

body_weight = 100; % kg
body_height = 2; % m

cp_body     = 4180; % J / (kg K) (heat capacity of water)
m_body      = 100;  % kg (220 lb person)

T_b_0       = 37;	% K (Initial body temperature)

clothing_def = {... % Clothing insulation in clo
    'shorts_t'  	0.36	'Walking shorts, short-sleeved shirt'		
    'office_t'   	0.57	'Trousers, short-sleeved shirt'		
    'pants_T'       0.61	'Trousers, long-sleeved shirt'		
    'pants_jckt'	0.96	'Trousers, long-sleeved shirt, plus suit jacket'		
    'three_pc'  	1.14	'Trousers, long-sleeved shirt, plus suit jacket, plus vest and T-shirt'		
    'sweater'   	1.01	'Trousers, long-sleeved shirt, long-sleeved sweater, T-shirt'		
    'two_layer' 	1.30 	'Trousers, long-sleeved shirt, long-sleeved sweater, T-shirt, plus suit jacket and long underwear bottoms'		
    'sweats'    	0.74	'Sweat pants, sweat shirt'		
    'pjs'       	0.96 	'Long-sleeved pajama top, long pajama trousers, short 3/4 sleeved robe, slippers (no socks)'		
    'skirt_t'   	0.54	'Knee-length skirt, short-sleeved shirt, panty hose, sandals'		
    'skirt_T'   	0.67	'Knee-length skirt, long-sleeved shirt, full slip, panty hose'		
    'skirt_swtr'	1.10	'Knee-length skirt, long-sleeved shirt, half slip, panty hose, long-sleeved sweater'		
    'skirt_jkt' 	1.04	'Knee-length skirt, long-sleeved shirt, half slip, panty hose, suit jacket'		
    'dress_jkt' 	1.10	'Ankle-length skirt, long-sleeved shirt, suit jacket, panty hose'		
    'overalls_1'	0.72	'Long-sleeved coveralls, T-shirt'		
    'overalls_2'	0.89	'Overalls, long-sleeved shirt, T-shirt'		
    'overalls_3'	1.37	'Insulated coveralls, long-sleeved thermal underwear, long underwear bottoms'};

clothing_t = 0;
clothing_0 = 'office_t';
clothing_1 = 'office_t';

activity_def = {... % Metabolic heating in W/m^2
    'sleep'     40	'Sleeping'                  
    'recline'   45	'Reclining'                 
    'sit'       60	'Seated, quiet'             
    'stand'     70	'Standing, relaxed'         
    'wlk_s'     115	'Walking @ 3.2 km/h'        
    'wlk_m'     150	'Walking @ 4.3 km/h'        
    'wlk_f'     220	'Walking @ 6.4 km/h'        
    'read'      55	'Reading in office, seated' 
    'write'     60	'Writing in office'         
    'type'      65	'Typing in office'          
    'sit_file'  70	'Filing, seated'            
    'std_file'  80	'Filing, standing'          
    'walk'      100	'Walking about office'      
    'pack'      120	'Lifting and packing'};

activity_t = 0;
activity_0 = 'sit';
activity_1 = 'sit';

T_b_ref   = 37;
k_comf    = 50;

% Units converted (1/s) to (1/hr) units in the model to match model time

%% Room model parameters
T_out       = 10;
T_r_ref_0   = 16;
T_r_db      = 1; % Thermostat deadband 

%% Behavior model parameters

k_dT = 1.; % Proportional gain on change in thermostat from T_b_error
eta_4_thresh = 50; % Threshold at which behavior becomes discrete action

% Variant subsystem for thermostat control
%  1: Hybrid feedback through SCT model
%  2: Proportional control of \Delta T_r_ref
%     TODO figure out why this doesn't work right.
VSS_thermostat = 1;
switch VSS_thermostat
	case 1
		disp('Thermostat control (\Delta T_r_ref) is hybrid feedback through SCT model');
	case 2
		disp('Thermostat control (\Delta T_r_ref) is proportation to T_b_error');
end

% Model moving from outside to inside
%  1 := outside (disconnect SCT from thermostat)
%  2 := inside
in_out_t = 0;
in_out_0 = 1;
in_out_1 = 2;

%% ICs settings
IC_source_strs = { ...
    'Use SS response as IC'
    'Use default ICs'};

% Select method of calculating ICs
IC_source = 2;

%% Overwrite parameters using input arguments
p = inputParser;
p.KeepUnmatched = true;
parse(p, varargin{:});

args = fieldnames(p.Unmatched);
for k = 1:length(args)
    arg = args{k};
    if exist(arg,'var')
        fprintf('Overwriting %s = ', arg);
        disp(p.Unmatched.(arg));
        eval(sprintf('%s = p.Unmatched.( arg );', arg)); 
    else
        error('Did not find variable %s', arg);
    end
end

%% SCT Model initialization

if any(theta==0)
    %  suppress warnings associated with zero delay
    warning off Simulink:blocks:TDelayDirectThroughAutoSet
    warning off Simulink:modelReference:NormalModeSimulationWarning
    warning off Simulink:Engine:WarnAlgLoopsFound
    % delay_blocks = find_system('SCT_mdl', 'BlockType', 'TransportDelay');
    % Simulink.suppressDiagnostic( delay_blocks, ...
    %     'Simulink:blocks:TDelayDirectThroughAutoSet');
end

% Check input multipliers
if (beta_21 + beta_31 > 1) || ...
        (beta_42 > 1) || ...
        (beta_43 > 1) || ...
        (beta_54 + beta_34 + beta_14 > 1) || ...
        (beta_25 + beta_45 > 1) || ...
        (beta_46 > 1)
    error('Conservation of mass error');
end

%% Body physiology model initialization

args = [clothing_def(:,1), num2cell(struct('val',clothing_def(:,2), 'str',clothing_def(:,3)))]';
clothings = struct(args{:});

args = [activity_def(:,1), num2cell(struct('val',activity_def(:,2), 'str',activity_def(:,3)))]';
activities = struct(args{:});     

A_bdy = 0.202 * body_weight^0.425 * body_height^0.725; % ASHRAE HB:Fund. 2013 eq (4) 


%% Calculate ICs
disp(IC_source_strs{IC_source});
switch IC_source
    case 1

        % Initialize 
        eta_0 = zeros(6,1);
        
        t_xi_2_on_tmp = t_xi_2_on; 
        t_xi_2_on  = 1000;
        t_xi_2_off_tmp = t_xi_2_off;
        t_xi_2_off = 1000;
        t_xi_3_on_tmp = t_xi_3_on;
        t_xi_3_on  = 1000;
        t_xi_3_off_tmp = t_xi_3_off;
        t_xi_3_off = 1000;
        t_xi_5_on_tmp = t_xi_5_on;
        t_xi_5_on  = 1000;
        t_xi_5_off_tmp = t_xi_5_off;
        t_xi_5_off = 1000;
        t_xi_8_on_tmp = t_xi_8_on;
        t_xi_8_on  = 1000;
        t_xi_8_off_tmp = t_xi_8_off;
        t_xi_8_off = 1000;
        in_out_t_tmp = in_out_t;
        in_out_t   = 1001;
        activity_t_tmp = activity_t;
        activity_t = 1001;
        clothing_t_tmp = clothing_t;
        clothing_t = 1001;
            
        % Run simulation
        tmp_ss_out = sim('HuiL_HVAC_all', ...
            'StopTime','1000', ...
            'SrcWorkspace','current');
        
        % eta IC
        tmp_eta_ss = getfield( get( tmp_ss_out.yout, 'eta'), ...
            'Values', 'Data');
        eta_0 = tmp_eta_ss(end,:)';

        tmp_T_r_ref = getfield( get( tmp_ss_out.yout, 'T_r_ref'), ...
            'Values', 'Data');
        T_r_ref_0 = tmp_T_r_ref(end,:)';

        tmp_T_b = getfield( get(tmp_ss_out.yout,'T_b'), ...
            'Values', 'Data');
        T_b_0 = tmp_T_b(end,:);
        disp('Steady-state values computing, using as ICs');
        
        clear ss_out eta_ss tmp_T_r_ref tmp_T_b
        
        t_xi_2_on = t_xi_2_on_tmp; 
        t_xi_2_off = t_xi_2_off_tmp;
        t_xi_3_on = t_xi_3_on_tmp;
        t_xi_3_off = t_xi_3_off_tmp;
        t_xi_5_on = t_xi_5_on_tmp;
        t_xi_5_off = t_xi_5_off_tmp;
        t_xi_8_on = t_xi_8_on_tmp;
        t_xi_8_off = t_xi_8_off_tmp;
        in_out_t = in_out_t_tmp;
        activity_t = activity_t_tmp;
        clothing_t = clothing_t_tmp;
        
    case 2
        
        eta_0 = zeros(6,1);
            
end



%% Simulate
disp('Running simulation')
out = sim('HuiL_HVAC_all', ...
    'StopTime', num2str(sim_dur), ...
    'SrcWorkspace','current');
disp('Simulation done.')
t = out.tout;

T_b = getfield( get(out.yout,'T_b'), ...
    'Values', 'Data');

T_r = getfield( get(out.yout,'T_r'), ...
    'Values', 'Data');

T_r_ref = getfield( get(out.yout,'T_r_ref'), ...
    'Values', 'Data');

Q_h = getfield( get(out.yout,'Q_h'), ...
    'Values', 'Data');

Q_met = getfield( get(out.yout,'Q_met'), ...
    'Values', 'Data');

%% Save workspace and plot
results = ws2struct();

results.hFig = HuiL_HVAC_plot_all(results);
    
end