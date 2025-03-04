ccc

% simulation setup
begT = 6*4 + 1;  % start time 6:00
endT = 21*4 + 1;  % end time 21:00
deltaT = 4; % time interval 4 * 15min
Tarray = begT : deltaT : endT;
numT = length(Tarray);

% curves data
load('STD_curves.mat');
pv_curve = PV_curves(3, Tarray);
wt_curve = WT_curves(2, Tarray);

% load devices parameters
mpc = caseGenCluster();

ngen = size(mpc.gen, 1);
nchp = size(mpc.chp, 1);
npv = size(mpc.pv, 1);
nwt = size(mpc.wt, 1);

% define index
IDX  = 1;
PMAX = 2;
PMIN = 3;
RMAX = 4;
RMIN = 5;

% define variables
varPgen = sdpvar(ngen, numT,'full');
varPchp = sdpvar(nchp, numT,'full');
varPpv  = sdpvar(npv, numT,'full');
varPwt  = sdpvar(nwt, numT,'full');
varPclus = sdpvar(numT, 1,'full');

rampMat = [-eye(numT-1); zeros(1, numT-1)] + [zeros(1, numT-1); eye(numT-1)];
rampMat = rampMat * 4 / deltaT;

% define constraints
consUnits = [
    repmat(mpc.gen(:, PMIN), 1, numT) <= varPgen <= repmat(mpc.gen(:, PMAX), 1, numT)
    repmat(mpc.chp(:, PMIN), 1, numT) <= varPchp <= repmat(mpc.chp(:, PMAX), 1, numT)
    zeros(npv, numT) <= varPpv <= mpc.pv(:, PMAX) * pv_curve
    zeros(nwt, numT) <= varPwt <= mpc.wt(:, PMAX) * wt_curve

    repmat(mpc.gen(:, RMIN), 1, numT-1) <= varPgen * rampMat <= repmat(mpc.gen(:, RMAX), 1, numT-1)
    repmat(mpc.chp(:, RMIN), 1, numT-1) <= varPchp * rampMat <= repmat(mpc.chp(:, RMAX), 1, numT-1)
];

[~, recoverymodel, ~, internalmodel] = export(consUnits,[]);

% extract constraint matrix: matE * varPunit <= matF
matE = -internalmodel.F_struc(:, 2:end);
matf = internalmodel.F_struc(:, 1);
varPunit = recover(recoverymodel.used_variables);

% extract constraint matrix: varPclus = matC * varPunit
consEqu = [
    sum([varPgen; varPchp; varPpv; varPwt], 1)' - varPclus == 0
];

[~, recoverymodel, ~, internalmodel] = export(consEqu,[]);
modelMatA = -internalmodel.F_struc(:, 2:end);
matC = modelMatA(:, getvariables(varPunit));

% apply bound shrink algorithm
% results：paramA * varPclus <= paramb
paramA = [eye(numT), -eye(numT), rampMat, -rampMat]';
[paramb, status, outDistVec, parambVec] = boundShrink(matE, matf, matC, zeros(numT, 1), paramA);

% plot result
plotAggResults





