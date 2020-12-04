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
% each run of optimise_CR takes ~7 minutes on a cluster
% which have 20 cores of type Intel(R) Xeon(R) CPU E5-2687W v4 @ 3.00GHz


%% SEIR, optimise the usage of vaccination
clear all
pop_pc = [9.2, 9.6, 11.2, 12.8, 12.5, 16.2, 12.4, 9.1, 7.0]/100;
x0R_goal = 0.15;
if_opt = true;
rho = 1.5;
extra_str = '_optimised_30pcVaccine_';
extra_str = strcat(extra_str, 'rho_', num2str(rho), '_');
optimise_HI('SEIR', x0R_goal, pop_pc, if_opt, rho, extra_str)


%% SEIR, worst case scenario on how to distribute vaccines
clear all
pop_pc = [9.2, 9.6, 11.2, 12.8, 12.5, 16.2, 12.4, 9.1, 7.0]/100;
x0R_goal = 0.15;
if_opt = false;
rho = 1.5;

extra_str = '_worst_30pcVaccine_';
extra_str = strcat(extra_str, 'rho_', num2str(rho), '_');

optimise_HI('SEIR', x0R_goal, pop_pc, if_opt, rho, extra_str)
