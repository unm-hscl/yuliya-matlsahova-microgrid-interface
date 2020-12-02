% Reorder states in state-space models

clear all
clc

load('NEW_Amg.mat')
load('Bmg_Phase.mat')
Bmg = Bmg_Phase(2:47,1:6);

A = Amg;
B = Bmg;
C = zeros(1,46);
D = zeros(1,6);
epsilon = 0.5;

sys = ss(A,B,C,D);

sys.StateName = {'z10','z11','z12','z13','z14', 'z15', 'z16', 'z17', 'z18', 'z19', 'z20', 'z21','z22', ...
    'z23','z24', 'z25','z26', 'z27', 'z28', 'z29', 'z30', 'z31', 'z32', 'z33','z34','z35','z36', ...
    'z37','z38', 'z39', 'z40', 'z41', 'z42', 'z43', 'z44', 'z45','z46','z47','zz1','zz2','zz3', ...
    'zz4', 'zz5', 'zz6', 'zz7', 'zz8'};

[y,P] = sort(sys.StateName);
sysN = xperm(sys,P);


% A1 is for slow dynamics and A2 for fast dynamics
% A11 is 38*38 A12 is 38*2
% A21 is 2*44 A22 is 2*2

A11 = sysN.A(1:38,1:38); % A1
A12 = sysN.A(1:38,39:46); % A2

A21 = sysN.A(39:46,1:38); % A3
A22 = sysN.A(39:46,39:46); % A4

% Re-ordering the B matrix
% B1 slow, B2 fast

B1 = sysN.B(1:38,1:6);
B21 = sysN.B(39:46,1:6);

A1 = A11;
A2 = A12;
A3 = A21/epsilon;
A4 = A22/epsilon;
B2 = B21/epsilon;


% New matrices
A_0 = A1 - A2*(A4^-1)*A3;
B_0 = B1 - A2*(A4^-1)*B2;



%{'zz','b','c','d','e', 'f', 'g', 'h', 'i', 'j', 'k', 'l','m','zzz','o', ...
%    'p','q', 'r', 's', 't', 'u', 'v', 'w', 'x','y','z','zzzz','bb','cc', ... 
%    'dd', 'ee', 'ff', 'gg', 'hh', 'ii', 'jj','kk','ll','mm','nn','oo', 'pp', 'qq', ...
%    'rr', 'ss', 'tt', 'uu'}

%'z1','2','3','4','5', '6', '7', '8', '9', '10', '11', '12','13', ...
%    'z14','15', '16','17', '18', '19', '20', '21', '22', '23', '24','25','26','z27', ...
%    '28','29', '30', '31', '32', '33', '34', '35', '36','37','38','39','40','41', ...
%    '42', '43', '44', '45', '46', '47'

