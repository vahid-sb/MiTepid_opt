function states = solve_ode(B, model_type, params)
t = params.t;

Ng = size(B,1);
x0 = params.x0;
x0 = correct_x0(model_type, Ng, x0);


if strcmp(model_type , 'SIS')
    Gamma = params.Gamma;
    Mu = params.Mu;
    [t, states] = ode45(@(t,x) SIS_t(t, x, B, Gamma, Mu), t, x0);
    
elseif strcmp(model_type , 'SIR')
    Gamma = params.Gamma;
    Mu = params.Mu;
    [t,states] = ode45(@(t,states) SIR_t(t, states, B, Gamma, Mu), t, x0);
    
    
elseif strcmp(model_type , 'SEIR')
    Gamma = params.Gamma;
    Mu = params.Mu;
    Sigma = params.Sigma;
    [t,states] = ode45(@(t,states) SEIR_t(t, states, B, Gamma, Mu, Sigma), t, x0);
    
end