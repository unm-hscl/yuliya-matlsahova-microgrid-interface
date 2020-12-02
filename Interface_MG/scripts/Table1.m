clear
clc

%% Dynamics
A = [0,1,0,0;
     0,0,1,0;
     0,0,0,0;
     0,0,0,0];
B = [zeros(2,2);
     eye(2,2)];
 
%% Controllability matrix defined for computing the Markov parameters: Gamma compute
Co = ctrb(A, B);

%% Task definition: Velocity needs to be detected
Stask = [2];
G_Stask = computeGamma(Stask, Co, A);

%% Sensor set creation: All states are candidate sensors
N = size(A, 1);              
sensorSet = 1:N;                        

%% Create set of all possible sensors
powerSet = cell(1,N);
for n_S = 1:N
    % all the combinations taken n_S items at a time in ascending order
    if n_S == 2
        powerSet{n_S} = flip(combnk(sensorSet,n_S));
    else
        powerSet{n_S} = combnk(sensorSet,n_S);
    end
end
disp('PowerSet');
for indx = 1:length(powerSet)
    v=powerSet{indx};
    disp(v-1)
end

%% Compute Gamma(S)
G_S = cell(1,N);
for n_S = 1:N
    temp_G_S = zeros(size(powerSet{n_S},1),1);
    for i=1:size(powerSet{n_S},1)
        sensor_comb_under_test = powerSet{n_S}(i,:);
        temp_G_S(i) = computeGamma(sensor_comb_under_test, Co, A);
    end
    G_S{n_S} = temp_G_S;
end
disp('gamma(S)');
G_S_vector = [G_S{1}' G_S{2}' G_S{3}' G_S{4}'];
disp(G_S_vector);

%% Compute Gamma(S U Stask)
G_SUStask = cell(1,N);
for n_S = 1:N
    temp_G_SUStask = zeros(size(powerSet{n_S},1),1);
    for i=1:size(powerSet{n_S},1)
        sensor_comb_under_test = union(powerSet{n_S}(i,:),Stask);
        temp_G_SUStask(i) = computeGamma(sensor_comb_under_test, Co, A);
    end
    G_SUStask{n_S} = temp_G_SUStask;
end
disp('gamma(S U Stask)');
G_SUStask_vector = [G_SUStask{1}' G_SUStask{2}' G_SUStask{3}' G_SUStask{4}'];
disp(G_SUStask_vector);

%% Srelv and Sirrelv computation
% Srelv is Gamma(s_i) + Gamma(Stask) > Gamma(s_i U Stask)
Srelv = find(G_S{1} + repmat(G_Stask, N, 1) > G_SUStask{1});
% Sirrelv is Gamma(s_i) + Gamma(Stask) == Gamma(s_i U Stask)
Sirrelv = find(G_S{1} + repmat(G_Stask, N, 1) == G_SUStask{1});

%% Savail computation
Savail = {};
for n_S = 1:N
    for i=1:size(powerSet{n_S},1)
        if G_SUStask{n_S}(i) == G_S{n_S}(i)
            Savail{end+1} = powerSet{n_S}(i,:);
        end
    end
end
disp('Savail (1 means \cmark)');
% for indx = 1:length(Savail)
%     v=Savail{indx};
%     disp(v-1)
% end
Savail_vector = (G_S_vector == G_SUStask_vector);
disp(Savail_vector);
fprintf('Count of Savail_vector nnz: %d\n\n',nnz(Savail_vector));

%% 2^Srelv computation
powerSetSrelv = ones(length(G_SUStask_vector),1);
indx_counter = 1;
for n_S = 1:N
    for i=1:size(powerSet{n_S},1)
        if any(powerSet{n_S}(i,:)==4)
            powerSetSrelv(indx_counter) = 0;
        end
        indx_counter = indx_counter + 1;
    end
end
disp('powerSet of Srelv');
disp(powerSetSrelv'==1)
disp(' ');

%% Savail,reduced computation
Savail_reduced_vector = and((G_SUStask_vector == G_S_vector), powerSetSrelv');
disp('Savail_reduced_vector = 2^\Srelv \cap Savail');
disp(Savail_reduced_vector);
fprintf('Count of Savail_reduced_vector nnz: %d\n\n',nnz(Savail_reduced_vector));

%% Strust ktrust = 1 computation
Strust1_vector = (G_S_vector >= 1);
disp('Strust_vector with ktrust = 1');
disp(Strust1_vector);

%% Strust ktrust = 2 computation
Strust2_vector = (G_S_vector >= 2);
disp('Strust_vector with ktrust = 2');
disp(Strust2_vector);

%% Strust ktrust = 3 computation
Strust3_vector = (G_S_vector >= 3);
disp('Strust_vector with ktrust = 3');
disp(Strust3_vector);

%% Strust ktrust = 4 computation
Strust4_vector = (G_S_vector >= 4);
disp('Strust_vector with ktrust = 4');
disp(Strust4_vector);

