%% Have the following in your startup
% addpath('D:\git\Matlab\Library\matpower6.0b1');
% addpath('D:\git\Matlab\Library\matpower6.0b1\t');
% addpath('D:\git\Matlab\Library\matpower6.0b1\most');
% addpath('D:\git\Matlab\Library\matpower6.0b1\most\t');
% addpath(genpath('D:\git\Matlab\Library\matpower6.0b1\extras'));

clear
clc

% Inertia as well as damping coefficients
M=eye(54)*2.656;
D=eye(54)*2;

%% IEEE 118 bus network normal operation
bus_of_interest = 28;
% load data from Matpower
GridData = case118;
Buses = GridData.bus(:,1);
Nb = length(Buses);
GeneratorBuses = GridData.gen(:,1);
for i=1:length(GeneratorBuses)
    GeneratorBuses(i) = find(GeneratorBuses(i) == Buses);
end
Ng = length(GeneratorBuses);
LoadBuses = setdiff(1:Nb,GeneratorBuses);
Nload = length(LoadBuses);
% extract susceptance-weighted network incidence matrix
Susceptances = 1./abs(GridData.branch(:,4));
Edges = GridData.branch(:,1:2);
for i=1:size(Edges,1)
    Edges(i,1) = find(Edges(i,1) == Buses);
    Edges(i,2) = find(Edges(i,2) == Buses);
end
Nline = size(Edges,1);
Incidence = zeros(Nb, Nline);
for i=1:Nline
    Incidence(Edges(i,1),i) = 1;
    Incidence(Edges(i,2),i) = -1;
end
% form Laplacian
L = Incidence*diag(Susceptances)*Incidence';
Lgg = L(GeneratorBuses,GeneratorBuses);
Lgl = L(GeneratorBuses,LoadBuses);
Lll = L(LoadBuses,LoadBuses);
% reduced Laplacian
Lred = Lgg - Lgl*inv(Lll)*Lgl';
% Construct the dynamics
A_case1 = [zeros(Ng) eye(Ng);
      -M\Lred -M\D];
B_case1 = [zeros(Ng); M\eye(Ng)];
Stask_case1 =find(abs(A_case1(54 + bus_of_interest,1:54))>0);
disp('Completed case 1');

%% IEEE 118 bus network --- Remove load bus 38
load_bus_to_remove = 38;
flag_vec_case2a = or(abs(Edges(:,1)-load_bus_to_remove)<eps,abs(Edges(:,2)-load_bus_to_remove)<eps);
edge_indx_2a = find(abs(flag_vec_case2a - 1)<eps);
fprintf('Case 2a: Removed %d edges\n',length(edge_indx_2a));
valid_edges_2a = setdiff(1:Nline, edge_indx_2a);
% New matrices
Incidence_case2a = Incidence(:,valid_edges_2a);
Susceptances_case2a = 1./abs(GridData.branch(valid_edges_2a,4));
% form Laplacian
L_case2a = Incidence_case2a*diag(Susceptances_case2a)*Incidence_case2a';
Lgg_case2a = L_case2a(GeneratorBuses,GeneratorBuses);
LoadBuses_case2a = LoadBuses(setdiff(1:length(LoadBuses),find(LoadBuses==load_bus_to_remove)));
Lgl_case2a = L_case2a(GeneratorBuses,LoadBuses_case2a);
Lll_case2a = L_case2a(LoadBuses_case2a,LoadBuses_case2a);
% reduced Laplacian
Lred_case2a = Lgg_case2a - Lgl_case2a*inv(Lll_case2a)*Lgl_case2a';
% Construct the dynamics
A_case2a = [zeros(Ng) eye(Ng);
            -M\Lred_case2a -M\D];
B_case2a = [zeros(Ng); 
            M\eye(Ng)];
Stask_case2a =find(abs(A_case2a(54 + bus_of_interest,1:54))>0);
disp('Completed case 2a');

%% IEEE 118 bus network --- Remove line 64--65
line_end_a = 64;
line_end_b = 65;
flag_vec_case2b = [and(abs(Edges(:,1)-line_end_a)<eps,abs(Edges(:,2)-line_end_b)<eps);
                   and(abs(Edges(:,1)-line_end_b)<eps,abs(Edges(:,2)-line_end_a)<eps)];
edge_indx_2b = find(abs(flag_vec_case2b - 1)<eps);
fprintf('Case 2b: Removed %d edges\n',length(edge_indx_2b));
valid_edges_2b = setdiff(1:Nline, edge_indx_2b);
% New matrices
Incidence_case2b = Incidence(:,valid_edges_2b);
Susceptances_case2b = 1./abs(GridData.branch(valid_edges_2b,4));
% form Laplacian
L_case2b = Incidence_case2b*diag(Susceptances_case2b)*Incidence_case2b';
Lgg_case2b = L_case2b(GeneratorBuses,GeneratorBuses);
Lgl_case2b = L_case2b(GeneratorBuses,LoadBuses);
Lll_case2b = L_case2b(LoadBuses,LoadBuses);
% reduced Laplacian
Lred_case2b = Lgg_case2b - Lgl_case2b*inv(Lll_case2b)*Lgl_case2b';
% Construct the dynamics
A_case2b = [zeros(Ng) eye(Ng);
            -M\Lred_case2b -M\D];
B_case2b = [zeros(Ng); 
            M\eye(Ng)];
Stask_case2b =find(abs(A_case2b(54 + bus_of_interest,1:54))>0);
disp('Completed case 2b');

%% IEEE118 bus network with fewer generators
A_case3 = A_case1;
B_case3 = B_case1(:,1:2:end);
Stask_case3 = Stask_case1;
disp('Completed case 3');

save('../matfiles/IEEE118_dyn_matrices.mat','A_case1','B_case1','Stask_case1','A_case2a','B_case2a','Stask_case2a','A_case2b','B_case2b','Stask_case2b','A_case3','B_case3','Stask_case3');
