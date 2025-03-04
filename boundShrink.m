function [paramb, status, outDistVec, parambVec] = boundShrink(matE, matf, matC, matd, paramA)

% using the given template to implement the bound shrinkage of a polytope
% so that the resulting polytope is inner-approximated in the real polytope (accelerated version)
% 
% Article: S. Wang and W. Wu, “Aggregate Flexibility of Virtual Power Plants with Temporal Coupling Constraints,” IEEE Transactions on Smart Grid, vol. 12, no. 6, pp. 5043–5051, Nov. 2021, doi: 10.1109/TSG.2021.3106646.
%
% author: Siyuan Wang 
% date: 2021-10-27
%
% INPUT:
%       matrices in constraints of inner variables: matE * varXint <= matf
%       matrices in equalities between boundary variables and inner variables: varXbd == matC * varXint + matd
%       matrices in constraints of boundary variables: paramA * varXbd <= paramb
% OUTPUT:
%       paramb: the final parameter result
%       status: the status of the solver, 0 means success
%       outDistVec: the change of the distance between the external point and the boundary points of the projection polytope during the iteration
%       parambVec: the change of the parameter during the iteration


    % Inner variables
    varXint = sdpvar(size(matC, 2), 1, 'full');
    % Boundary variables
    varXbd = sdpvar(size(matC, 1), 1, 'full');

    % constraints of inner variables
    consInt = [matE * varXint <= matf];
    % equalities between boundary variables and inner variables
    consBdInt = [varXbd == matC * varXint + matd];

    dimXbd = size(matC, 1);

    % calculate the initial value of paramb in the iteration
    paramObj = sdpvar(dimXbd, 1, 'full');
    obj = paramObj' * varXbd;
    solvePclusOpt = optimizer([consInt; consBdInt], -obj, sdpsettings('solver', 'gurobi'), paramObj, obj);

    paramObjVal = paramA';
    paramb = solvePclusOpt(paramObjVal)';

    const_r = size(paramb, 1);
    bigM = 1e6;

    varLambda = sdpvar(size(matf, 1), 1, 'full');
    varPi = sdpvar(dimXbd, 1, 'full');
    varOmega = sdpvar(const_r, 1, 'full');
    % binvars = binvar(const_r, 1, 'full');
    varparamb = sdpvar(const_r, 1, 'full');

    figure(1);
    subplot(2, 1, 1); hold on
    subplot(2, 1, 2); hold on

    outDistVec = [];
    parambVec = [paramb];

    while true

        % view paramb in the iteration process
        maxPclus = paramb(1:dimXbd, :);
        minPclus = -paramb(dimXbd + 1:2 * dimXbd, :);
        maxRclus = paramb(2 * dimXbd + 1:3 * dimXbd - 1, :);
        minRclus = -paramb(3 * dimXbd:end, :);

        figure(1);
        subplot(2, 1, 1); hold on
        title('Pclus output power')
        plot(maxPclus, 'r')
        plot(minPclus, 'b')
        xlabel('Time')
        ylabel('Power')

        subplot(2, 1, 2); hold on
        title('Pclus ramp rate')
        plot(maxRclus, 'r')
        plot(minRclus, 'b')
        xlabel('Time')
        ylabel('Ramp rate')

        pause(0.1)

        % search for the outlier point
        % objMinMax = varLambda' * matf - varPi' * matd - varOmega' * paramb;
        % consMinMax = [
        %               varOmega' * paramA + varPi' == 0
        %               varLambda' * matE + varPi' * matC == 0
        %               varLambda >= 0
        %               0 <= paramb - paramA * varXbd <= bigM * (ones(const_r, 1) - binvars)
        %               0 <= varOmega <= bigM * binvars
        %               ones(const_r, 1)' * binvars >= dimXbd
        %               ];

        % search for the outlier point (accelerated version)
        varz1 = binvar(dimXbd, 1, 'full');
        varz2 = binvar(dimXbd, 1, 'full');
        objMinMax = varLambda' * matf - (varz1 - varz2)' * matd * bigM + (varz1 - varz2)' * varXbd * bigM;
        consMinMax = [
                        paramA * varXbd <= paramb
                        varLambda' * matE + (varz1 - varz2)' * matC * bigM == 0
                        varLambda >= 0
                        varz1 + varz2 <= ones(dimXbd, 1)
                       ];

        solMinMax = optimize(consMinMax, objMinMax, sdpsettings('verbose', 0, 'solver', 'gurobi'));

        if solMinMax.problem ~= 0
            warning(['Minmax problem optimize Failed: ', solMinMax.info])
            status = 1;
            break
        end

        % valObj = value(objMinMax);
        valXbd = value(varXbd);
        % valPi = value(varPi);
        % valOmega = value(varOmega);
        
        % locate the extreme point
        valbinvar = (abs(paramA * valXbd - paramb) < 1e-6);

        % locate the boundary point
        objDist = norm(valXbd - varXbd, 2);
        consDist = [
                    varXbd == matC * varXint + matd
                    matE * varXint <= matf
                    ];
        solDist = optimize(consDist, objDist, sdpsettings('verbose', 0, 'solver', 'gurobi'));

        if solDist.problem ~= 0
            warning(['Minimize distance Failed: ', solDist.info])
            status = 1;
            break
        end

        valPbd = value(varXbd);
        valDist = value(objDist);
        outDistVec = [outDistVec, valDist];

        if abs(value(objDist)) < 1e-6
            disp('Bound shrinkage Finshed !')
            status = 0;
            break
        end

        % shrink the boundaries
        numJ = round(sum(valbinvar));
        binvarz = binvar(numJ, 1);
        bdsel = (valbinvar > 0.5);
        % numJ = round(sum(value(binvars)));
        % binvarz = binvar(numJ, 1);
        % bdsel = value(binvars) > 0.5;

        objShrink = sum(varparamb);
        consShrink = [
                      varparamb <= paramb
                      paramA(bdsel, :) * valPbd >= varparamb(bdsel) - bigM * (ones(numJ, 1) - binvarz)
                      sum(binvarz) >= min(dimXbd, numJ)
                      ];
        solShrink = optimize(consShrink, -objShrink, sdpsettings('verbose', 0, 'solver', 'gurobi'));

        if solShrink.problem ~= 0
            warning(['Shrink problem optimize Failed: ', solShrink.info])
            status = 1;
            break
        end

        paramb = value(varparamb);
        parambVec = [parambVec, paramb];
    end
end