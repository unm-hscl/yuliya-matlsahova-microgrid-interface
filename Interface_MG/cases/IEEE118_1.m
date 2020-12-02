%load('../matfiles/IEEE118_dyn_matrices.mat');

load('A_0')
load('B_0')

%% System parameters
Abar = sparse(A_0);                 % Case 1 state matrix
Bbar = sparse(B_0);                 % Case 1 input matrix
Stask = sparse([13]);               % Case 1 task sensors
%Co = ctrbf(Abar, Bbar, eye(4,4));          
Co = sparse(ctrb(Abar,Bbar));       % Controllability matrix defined for computing the Markov parameters

%% Sensor set creation
% All states are candidate sensors
%N = size(Abar, 1);              
%s = 1:N;                        
s = [1 2 9 10 11 12 13 14 15 22 23 24 25 26 27 28 35 36 37 38];                        
N = size(s,2);

%% Problem parameters: ktrust creation
%G_Stask = computeGammaOishi(Stask, Abar, Bbar); % Oishi's Gamma
%G_Stask = computeGammaOriginal(Stask, Co, Abar); % Vinod's Gamma
G_Stask = computeGammaSparse(Stask, Co, Abar); % Sparse Gamma

%Ktrust = [G_Stask + [-10:20:10],47]; 
Ktrust = 20; %1-20

%% Save System Workspace
saveSystem('../matfiles/IEEE118_1', Abar, Bbar, Co, N, s, Stask, Ktrust);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%