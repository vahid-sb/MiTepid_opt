function output = obj_func_HI(x0R, model_type, params)
B = params.B;
Ng = size(B,1);
params.x0 = [ones(Ng, 1) * 1e-4; x0R; ones(Ng, 1) * 1e-4]; 
%% solve ode
states = solve_ode(B, model_type, params);

if strcmp(model_type , 'SIS')
    I = states;
elseif strcmp(model_type , 'SIR')
    I = states(:,1 : Ng);
    R = states(:, Ng+1 : 2*Ng);
elseif strcmp(model_type , 'SEIR')
    I = states(:,1:Ng);
    R = states(:, Ng+1 : 2*Ng);
    E = states(:, 2*Ng+1 : 3*Ng);

end
%
x0R_sum_goal = params.x0R_sum_goal;
pop_pc = params.pop_pc; 
%
R_end = R(end, :);
sum_R = sum(R_end .* pop_pc);
sum_x0R = sum(x0R' .* pop_pc);
% calc objective function
if params.if_opt
    output = 100 * sum_R  + 1000*abs(x0R_sum_goal-sum_x0R); 
else
    output = 100 * (1-sum_R)  + 1000*abs(x0R_sum_goal-sum_x0R); 
end
