function mpc = caseGenCluster()

%% system MVA base
mpc.baseMVA = 100;
																												
mpc.gen = [ 					
% idx	1	2	3	4	5
% item	idx	pmax	pmin	rmax	rmin
% unit	/	MW	MW	MW/15min	MW/15min
	1	0.4181	0	0.0852	-0.0852
	2	0.7393	0	0.1533	-0.1533
	3	0.6269	0	0.1051	-0.1051
	4	0.3460	0	0.0494	-0.0494
	5	0.6145	0	0.1017	-0.1017
	6	0.4180	0	0.0661	-0.0661
];					
					
mpc.chp = [ 					
% idx	1	2	3	4	5
% item	idx	pmax	pmin	rmax	rmin
% unit	/	MW	MW	MW/15min	MW/15min
	1	0.4878	0	0.3344	-0.3344
	2	0.4909	0	0.9446	-0.9446
	3	0.4939	0	0.8183	-0.8183
	4	0.4026	0	0.3817	-0.3817
	5	0.6498	0	0.7258	-0.7258
	6	0.7228	0	1.3820	-1.3820
];					
					
mpc.pv = [					
% idx	1	2			
% item	idx	capacity			
% unit	/	MW			
	1	0.4489			
	2	0.4107			
	3	0.4253			
	4	0.3225			
	5	0.4442			
	6	0.3253			
	7	0.4592			
	8	0.3534			
];					
					
mpc.wt = [					
% idx	1	2			
% item	idx	capacity			
% unit	/	MW			
	1	0.6463			
	2	0.5795			
	3	0.4496			
	4	0.6598			
	5	0.5082			
	6	0.4254			
	7	0.6735			
	8	0.5754			
];					







