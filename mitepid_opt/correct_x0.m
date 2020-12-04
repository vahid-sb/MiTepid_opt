function x0 = correct_x0(model_type, Ng, x0)

if strcmp(model_type, 'SIS')
    if length(x0) == 1
        x0 = ones(Ng, 1) * x0;
    elseif length(x0) == Ng
        x0 = x0;
    else
        return
    end
elseif strcmp(model_type, 'SIR')
    if length(x0) == 1
        x0 = ones(2*Ng, 1) * x0;
    elseif length(x0) == Ng
        x0 = [x0; zeros(Ng, 1)];
    elseif length(x0) == 2 * Ng
        x0 = x0;
    else
        return
    end

elseif strcmp(model_type, 'SEIR')
    if length(x0) == 1
        x0 = ones(3*Ng, 1) * x0;
    elseif length(x0) == Ng
        x0 = [x0; zeros(2* Ng, 1)];
    elseif length(x0) == 2 * Ng
        x0 = [x0; zeros(Ng, 1)];
    elseif length(x0) == 3 * Ng
        x0 = x0;
    else
        return
    end

end