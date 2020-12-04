function optimise_CR(model_type, R0, T_I, T_E, x0, extra_str)

tic
if ~exist('T_E', 'var')
    T_E = 0;
end
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

gamma = 1/5.0; 
Gamma = diag(ones(Ng,1)*gamma);  % for SIS, SIR, SEIR
params.Gamma = Gamma;
if strcat(model_type, 'SEIR')
    % inhibition rate: ate at which population leaves Latent (E) compartment
% % %     T_E = 4.6;  % 4.6 according to kissler et al, for SEIR
    sigma = 1/4.6;  
    Sigma = diag(ones(Ng,1)*sigma);  % for SEIR
    params.Sigma = Sigma;
else
    params.Sigma = zeros(Ng);
end

D = params.Gamma + params.Mu;
params.D = D;
%#################################################################
% Optimisation parameters
% target ratio of population in each group
% the following values are calculated from the reports in early outbreak of
% SARS-CoV-2 in China, as reported in:
% https://www.statista.com/statistics/1095024/china-age-distribution-of-wuhan-coronavirus-covid-19-patients/
raw_x_goal = [1.0, 1.43, 8.0, 14.5, 16.4, 19.9, 24.6, 25.0, 25.1];  
%
% ratio_of_symp_to_all = [0.89, 0.89, 0.89, 0.79, 0.70, 0.47, 0.43, 0.41, 0.54];
ratio_of_symp_to_all = [0.8929,0.8929,0.8929,0.7941,0.7037,0.4746,0.4294,0.4060,0.5370];

N_wuhan_confirmed = 44672;
reported_confirmed_ratio = [0.9, 1.2, 8.1, 17.0, 19.2, 22.4, 19.2, 8.8, 3.2];
population_ratio_pc = [11.9, 11.6, 13.5, 15.6, 15.6, 15.0, 10.4, 4.7, 1.7];
%
reported_confrimed_number = reported_confirmed_ratio * N_wuhan_confirmed;
%
corrected_confirmed_number = reported_confrimed_number ./ ratio_of_symp_to_all;
corrected_confirmed_pc = corrected_confirmed_number * 100 / sum(corrected_confirmed_number);
corrected_confirmed_pc_norm_pop = corrected_confirmed_pc./ population_ratio_pc;
corrected_x_goal = corrected_confirmed_pc_norm_pop / min(corrected_confirmed_pc_norm_pop);

params.I_goal = corrected_x_goal;

% according to https://pubmed.ncbi.nlm.nih.gov/32125128/ should be 2.95 in
% an uncontained population
R0_uncontained = R0; 
params.R0_uncontained = R0_uncontained; 

% x0, initial conditions for the model
if ~exist('x0', 'var')
    x0 = ones(Ng,1)*1e-5;
end

params.x0=x0;

% t_f, time to reach x_goal values
T_max = 75;
t = 0:0.1:T_max;
params.t=t;

%#################################################################
% Optimisation
%#################################################################
%% optimisation function
obj_func = @obj_func_CR;
% beta_min, beta_max: upper lower thresholds for matrix B values
beta_min = 0.01;
beta_max = 0.20;

%% Global Optimisation: in two steps
fprintf('----------------------------------------------')
fprintf('\nStarting Global Optimization ...\n')
fprintf('----------------------------------------------\n')
fprintf('\nModel type: %s', model_type);
fprintf('\nbeta min and max: %2.2f, %2.2f', beta_min, beta_max);
fprintf('\nT_I and (possibly) T_E in days: %2.2f, %2.2f', T_I, T_E);
fprintf('\nR0 goal for uncontained poulation: %2.2f', R0_uncontained);
fprintf('\nNumber of age groups: %d', Ng);
fprintf('\n%s', extra_str);

rng default % For reproducibility

opt_func = @(B)obj_func(B, model_type, params);


% global search: step1
gs = GlobalSearch;
fprintf('\n----------------------------------------------\n')
disp('Step1:')
B0 = rand(Ng, Ng) * beta_max;
opts = optimoptions(@fmincon,'UseParallel',true,'Algorithm','sqp');
problem = createOptimProblem('fmincon','x0',B0,...
                            'objective',opt_func,...
                            'lb',ones(Ng,Ng)*beta_min,...
                            'ub',ones(Ng, Ng)*beta_max,...
                            'options',opts);
% global search: step2                        
B_opt_step1 = run(gs,problem);
fprintf('\n----------------------------------------------\n')
disp('Step2:')
B0 = B_opt_step1;
opts = optimoptions(@fmincon,'UseParallel',true,'Algorithm','sqp');
problem = createOptimProblem('fmincon','x0',B0,...
                            'objective',opt_func,...
                            'lb',ones(Ng,Ng)*beta_min,'ub',...
                            ones(Ng, Ng)*beta_max,...
                            'options',opts);
B_opt_step2 = run(gs,problem);

% 
B_opt = B_opt_step2;
%
rho_opt = max(abs(eig(-D\B_opt)));

%% elasped time
elapsed_time_minutes = toc/60;
fprintf('\nElapsed time is %f', elapsed_time_minutes)
fprintf('\n*****************************************************\n')

%% save
% all variables
dir_save_all_vars = fullfile(cd, 'B_opt_all_vars');
if ~exist(dir_save_all_vars, 'dir')
    mkdir(dir_save_all_vars);
end
time_now = datestr(now, 30);
filesave1 = strcat('B_opt_', model_type, '_Ti_', num2str(T_I), '_R0_',...
                    num2str(R0_uncontained), '_', ...
                    time_now(5:end), extra_str, '.mat');
filesave = fullfile(dir_save_all_vars, filesave1);
save(filesave,  'model_type', 'B_opt', 'D', 'R0_uncontained',...
                'B_opt_step1', 'B_opt_step1', 'B0', 'x0', ...
                'beta_min', 'beta_max', 'Gamma', 'Mu', 'Sigma', 't', ...
                'elapsed_time_minutes', 'opt_func', 'hostname');

% only variables relevant to mitepid_sim
dir_save_MiTepid_sim = fullfile(cd, 'B_opt_MiTepid_sim');
if ~exist(dir_save_MiTepid_sim, 'dir')
    mkdir(dir_save_MiTepid_sim);
end
filesave2 = strcat('B_opt_', model_type, '_Ti_', num2str(T_I), ...
                    '_R0_', num2str(R0_uncontained), extra_str, '.mat');
filesave = fullfile(dir_save_MiTepid_sim, filesave2);
save(filesave,  'model_type', 'B_opt', 'R0_uncontained', ...
                'x0', 'beta_min', 'beta_max', ...
                'D', 'Gamma', 'Mu', 'Sigma', 't');
    

