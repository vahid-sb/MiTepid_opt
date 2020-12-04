function dsdt = SEIR_t(t, states, B, Gamma, Mu, Sigma)

Ng = size(B, 1);

x = states(1:Ng);
y = states(Ng+1:2*Ng);
z = states(2*Ng+1:3*Ng);

dxdt = zeros(Ng, 1); % I
dydt = zeros(Ng, 1); % R
dzdt = zeros(Ng, 1); % E

for i = 1:Ng
    Sum_j_x = 0;
    for j = 1:Ng
        Sum_j_x = Sum_j_x + B(i, i) * x(i);
    end
    %E
    dzdt(i) = (1- x(i) - y(i) - z(i)) * Sum_j_x - (Mu(i, i) + Sigma(i, i)) * z(i);
    %I
    dxdt(i) = Sigma(i, i) * z(i) - (Mu(i, i) + Gamma(i, i)) * x(i);
    %R
    dydt(i) = Gamma(i, i) * x(i) - Mu(i, i) * y(i);
end
dsdt = [dxdt; dydt; dzdt];
