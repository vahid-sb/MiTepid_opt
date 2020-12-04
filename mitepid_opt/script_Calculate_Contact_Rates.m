%% Part of MiTepid_opt package
% author: Vahid Bokharaie
% created: Mar. 2020 
%
% This is a script to run the optimisation scheme detailed in Section A.3 of:
% https://www.medrxiv.org/content/10.1101/2020.10.16.20213835v1
% Its aim is to find the oprimum distribution of a limited supply of
% vaccines in a population with a given age-distribution, such that it will
% maximise the immunity of the population. 
% More details in Section 3.4 of the above-mentioned manuscript. 


%% NOTE:
% each run of optimise_CR takes 15-20 minutes on a cluster
% which have 20 cores of type Intel(R) Xeon(R) CPU E5-2687W v4 @ 3.00GHz

%% SEIR, assuming different R0 in uncontained population
clear all
for R0 = 2.05:0.1:3.95
    disp(R0)
    optimise_CR('SEIR',R0, 5.0, 4.6)
end


%% SEIR, different Infectious Time-period
clear all
for T_I = 6.0:1.0:15.0
    disp(T_I)
    optimise_CR('SEIR',2.95, T_I, 4.6)
end

%% SIS and SIR
clear all
disp('SIR, with R0=2.95, T_Infectious = 9.6 days')
optimise_CR('SIR',2.95, 9.6)
disp('SIS, with R0=2.95, T_Infectious = 9.6 days')
optimise_CR('SIS',2.95, 9.6)

%% SEIR, different initial condition (same values for all age-groups)
clear all
Ng = 9;
extra_str_list = {'_x0_all_1e-6', '_x0_all_5e-6', '_x0_all_1e-5',  '_x0_all_2e-5', '_x0_all_5e-5', '_x0_all_1e-4'};
x0s = {1e-6; 5*1e-6; 1e-5; 2*1e-5; 5*1e-5; 1e-4};
for idx  = 1:length(x0s)
    x0 = ones(Ng,1)*x0s{idx};
    extra_str = extra_str_list{idx};
    optimise_CR('SEIR',2.95, 5.0, 4.6, x0, extra_str)
end

%% SEIR, different initial conditions, one age-group non-zero only
clear all
Ng = 9;
for age_group = 1:9
    x0 = ones(Ng,1)*1e-8;
    x0(age_group) = 1e-5;
    extra_str = strcat('x0_1e-5_only_age_group_', num2str(age_group));
    optimise_CR('SEIR',2.95, 5.0, 4.6, x0, extra_str)
end
