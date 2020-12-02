disp('Updating problem parameters');
disp('===========================');
cd cases
%if exist('../matfiles/IEEE118_dyn_matrices.mat','file')
%    disp('Reusing existing IEEE118_dyn_matrices.mat!');
%else
%    generate_dyn_matrices
%end

if ~exist('computeGamma.m','file')
    addpath('../scripts');
    addpath('../matfiles');
    addpath('../cases');
    addpath('../psIterator');
end
IEEE118_1
%IEEE118_2a
%IEEE118_2b
%IEEE118_3
disp('Created all the necessary matfiles containing the problem parameters');
cd ..
