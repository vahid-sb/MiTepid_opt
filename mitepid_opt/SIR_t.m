function dsdt = SIR_t(t, states, B, Gamma, Mu)

Ng = size(B, 1);

x = states(1:Ng);
y = states(Ng+1:2*Ng);

dxdt = zeros(Ng, 1);
dydt = zeros(Ng, 1);

for i = 1:Ng
    Sum_j_x = 0;
    for j = 1:Ng
        Sum_j_x = Sum_j_x + B(i, j) * x(i);
    end
    %I
    dxdt(i) = (1-x(i) - y(i)) * Sum_j_x - (Mu(i, i) + Gamma(i, i)) * x(i);
    %R
    dydt(i) = Gamma(i, i) * x(i) - Mu(i, i) * y(i);
end
dsdt = [dxdt; dydt];
