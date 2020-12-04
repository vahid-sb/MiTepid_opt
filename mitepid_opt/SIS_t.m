function dxdt = SIS_t(t, x, B, Gamma, Mu)

Ng = size(B, 1);

dxdt = zeros(Ng, 1);

for i = 1:Ng
    Sum_j = 0;
    for j = 1:Ng
        Sum_j = Sum_j + B(i, j) * x(j);
    end
    dxdt(i) = (1 - x(i)) * Sum_j - (Mu(i, i) + Gamma(i, i)) * x(i);
end
