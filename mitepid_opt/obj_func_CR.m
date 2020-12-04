function output = obj_func_CR(B, model_type, params)
Ng = size(B,1);

%% solve ode
states = solve_ode(B, model_type, params);

if strcmp(model_type , 'SIS')
    I = states;
elseif strcmp(model_type , 'SIR')
    I = states(:,1:Ng);
    R = states(:, Ng+1:2*Ng);
elseif strcmp(model_type , 'SEIR')
    I = states(:,1:Ng);
    R = states(:, Ng+1:2:Ng);
    E = states(:, 2*Ng+1:3*Ng);

end

%% set opt variables
I_goal = params.I_goal;
rho_goal = params.R0_uncontained;
D = params.D;
rho = max(abs(eig(-D\B)));
I_end = I(end, :);
I_end_normalised = I_end/I_end(1);

%% calc objective function
output = norm(abs(I_end_normalised - I_goal))  + 100*abs(rho-rho_goal); 
