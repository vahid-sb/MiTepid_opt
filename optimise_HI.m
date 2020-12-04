function optimise_HI(model_type, x0R_goal, pop_pc, if_opt, rho, extra_str)


tic
params.if_opt = if_opt;

if ~exist('extra_str', 'var')
    extra_str = '';
end
%#################################################################
%% choosing pool cluster
% To sepcify detials of your cluster, you can define it in a script called
% 'choose_pool_cluster' or you can just define it here. Or leave it to
% Matlab to set it to defualt values when it reaches the parfor loop. 
if exist('choose_pool_cluster.m', 'file')
    choose_pool_cluster
else
    delete(gcp('nocreate'))
    parpool('local');
end
hostname = char(java.net.InetAddress.getLocalHost.getHostName);
%#################################################################
%% define parameters
% Number of groups
% define the stratification. In this scrips, population is assumed to be
% divided into Ng=9 age-groups in 0-10, 10-20, ..., 70-80 and 80+ ranges.
% dimensions of initial conditions 
params.Ng = 9;

%#################################################################
% model parameters
% model type: current choices: SIS, SIR, SEIR
% % % model_type = 'SEIR';
Ng = params.Ng;
% birth/death rate
mu = 0;  
Mu = diag(ones(Ng,1)*mu);  % for SIS, SIR, SEIR
params.Mu = Mu;
% transmission rate, rate at which population levaes Infectious compartment
if strcat(model_type, 'SEIR')
    T_I = 5.0; % 5 according to Kissler et al, for SEIR
else
    T_I = 9.6;
end

gamma = 1/T_I; 
Gamma = diag(ones(Ng,1)*gamma);  % for SIS, SIR, SEIR
params.Gamma = Gamma;
if strcat(model_type, 'SEIR')
    % inhibition rate: ate at which population leaves Latent (E) compartment
    T_E = 4.6;  % 4.6 according to kissler et al, for SEIR
    sigma = 1/T_E;  
    Sigma = diag(ones(Ng,1)*sigma);  % for SEIR
    params.Sigma = Sigma;
else
    params.Sigma = zeros(Ng);
end

D = params.Gamma + params.Mu;
params.D = D;

% t_f, time to reach I_goal values
T_max = 365;
t = 0:0.1:T_max;
params.t=t;


%#################################################################
% Optimisation
%#################################################################
%% optimisation function
obj_func = @obj_func_HI;
% beta_min, beta_max: upper lower thresholds for matrix B values
beta_min = 0.05;
beta_max = 0.95;
params.x0R_sum_goal = x0R_goal;
params.pop_pc = pop_pc;
params.B = importdata('./B_opt_MiTepid_sim/B_opt_SEIR_main.mat').B_opt;
rho_main = 2.95;
params.B = params.B *(rho/rho_main);

%% Global Optimisation: in two steps
fprintf('----------------------------------------------')
fprintf('\nStarting Global Optimization ...\n')
fprintf('----------------------------------------------\n')
fprintf('\nModel type: %s', model_type);
fprintf('\nbeta min and max: %2.2f, %2.2f', beta_min, beta_max);
fprintf('\nT_I and (possibly) T_E in days: %2.2f, %2.2f', T_I, T_E);
fprintf('\nxoR goal for uncontained poulation: %2.2f', x0R_goal);
fprintf('\nNumber of age groups: %d', Ng);
fprintf('\n%s', extra_str);

% rng default % For reproducibility
rng('shuffle')
opt_func = @(x0R)obj_func(x0R, model_type, params);


% global search: step1
gs = GlobalSearch;
fprintf('\n----------------------------------------------\n')
disp('Step1:')
x0 = rand(Ng, 1) * beta_max;
opts = optimoptions(@fmincon,'UseParallel',true,'Algorithm','sqp');
problem = createOptimProblem('fmincon','x0',x0,...
                            'objective',opt_func,...
                            'lb',ones(Ng,1)*beta_min,'ub',...
                            ones(Ng, 1)*beta_max,...
                            'options',opts);
% global search: step2                        
x0R_opt_step1 = run(gs,problem);
fprintf('\n----------------------------------------------\n')
disp('Step2:')
opts = optimoptions(@fmincon,'UseParallel',true,'Algorithm','sqp');
problem = createOptimProblem('fmincon','x0',x0R_opt_step1,...
                            'objective',opt_func,...
                            'lb',ones(Ng,1)*beta_min,...
                            'ub',ones(Ng, 1)*beta_max,...
                            'options',opts);
x0R_opt_step2 = run(gs,problem);

% 
x0R_opt = x0R_opt_step2;
%
B = params.B;
D = params.D;
rho = max(abs(eig(-D\B)));

%% elasped time
elapsed_time_minutes = toc/60;
fprintf('\nElapsed time is %f', elapsed_time_minutes)
fprintf('\n*****************************************************\n')

sum_x0R = sum(x0R_opt' .* pop_pc);
%% save
% all variables
dir_save_all_vars = fullfile(cd, 'x0R_opt_all_vars');
if ~exist(dir_save_all_vars, 'dir')
    mkdir(dir_save_all_vars);
end
time_now = datestr(now, 30);
filesave1 = strcat('x0R_opt_', model_type, '_Ti_', num2str(T_I),...
                    '_R0_', num2str(rho), '_', ...
                    time_now(5:end), extra_str, '.mat');
filesave = fullfile(dir_save_all_vars, filesave1);
save(filesave,  'model_type', 'x0R_opt', 'B', 'D', 'rho',...
                'x0R_opt_step1', 'x0R_opt_step1', 'x0',...
                'x0', 'beta_min', 'beta_max', 'Gamma', ...
                'Mu', 'Sigma', 't', 'elapsed_time_minutes', ...
                'opt_func', 'hostname', 'pop_pc', 'sum_x0R');

% only variables relevant to mitepid_sim
dir_save_MiTepid_sim = fullfile(cd, 'x0R_opt_MiTepid_sim');
if ~exist(dir_save_MiTepid_sim, 'dir')
    mkdir(dir_save_MiTepid_sim);
end
filesave2 = strcat('x0R_opt_', model_type, '_Ti_', num2str(T_I), ...
                    '_R0_', num2str(rho), extra_str, '.mat');
filesave = fullfile(dir_save_MiTepid_sim, filesave2);
save(filesave,  'model_type', 'x0R_opt', 'rho', ...
                'x0', 'beta_min', 'beta_max', ...
                'D', 'Gamma', 'Mu', 'Sigma', 't', ...
                'pop_pc', 'sum_x0R');
    

