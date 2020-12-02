clear
clc

addpath('./MG_Model');

update_problem_params

set_of_cases{1} = 'matfiles/IEEE118_1';
%set_of_cases{2} = 'matfiles/IEEE118_2a';
%set_of_cases{3} = 'matfiles/IEEE118_2b';
%set_of_cases{4} = 'matfiles/IEEE118_3';

S_P = cell(length(set_of_cases),3);
S_PQ = cell(length(set_of_cases),3);

Sopt_algorithm2 = cell(length(set_of_cases),4);
Gopt_algorithm2 = zeros(length(set_of_cases),4);
elapsedTime_algorithm2 = zeros(length(set_of_cases),4);
ub_ratio_algorithm2 = zeros(length(set_of_cases),4);

Sopt_greedyAlgorithm = cell(length(set_of_cases),1);
Gopt_greedyAlgorithm = zeros(length(set_of_cases),1);
elapsedTime_greedyAlgorithm = zeros(length(set_of_cases),1);
ub_ratio_greedy = zeros(length(set_of_cases),1);

Sopt_CPonly = cell(length(set_of_cases),2);
Gopt_CPonly = zeros(length(set_of_cases),2);
elapsedTime_CPonly = zeros(length(set_of_cases),2);

for case_indx = 1:length(set_of_cases)
    % Get the problem parameters
    case_str = set_of_cases{case_indx};
    fprintf('\n\n>> Analyzing %s\n=================================\n',case_str);
    IEEE118_System = loadSystem(case_str);
    set_of_options = IEEE118_System.s;
    Stask = IEEE118_System.Stask;
    ktrust_vec = IEEE118_System.Ktrust;
    gamma = @(z) computeGammaSparse(z, IEEE118_System.Co, IEEE118_System.Abar);
    
    for kindx = 1:length(ktrust_vec)
        % Get ktrust
        ktrust = ktrust_vec(kindx);

        %% Run CP approach
        if ktrust <= gamma(Stask)
            fprintf('\n>> Solve for optimal solution using CP when k_{trust}<=\\Gamma(S_{task}) | ktrust = %d, case = %s \n',  ktrust, case_str);
            timerVal=tic;
            Srelv=sRelvAndIrrelv(set_of_options, Stask, gamma);        
            list_of_Popt=sAvail('list', Srelv, Stask, gamma);
            S_P(case_indx,kindx) = {list_of_Popt};
            min_length = Inf;
            for i=1:length(list_of_Popt)
                sensor_comb = cell2mat(list_of_Popt(i));
                if min_length > length(sensor_comb) && gamma(sensor_comb) >= ktrust
                    soln = sensor_comb;
                    min_length = length(sensor_comb);
                end
            end
            Gopt_CPonly(case_indx,kindx) = gamma(soln);
            Sopt_CPonly(case_indx,kindx) = {soln};
            elapsedTime_CPonly(case_indx,kindx) = toc(timerVal);
        elseif ktrust == 38
            %% Run greedy algorithm
            fprintf('\n>> Run greedy algorithm for ktrust=\\Gamma(All sensors) | ktrust = %d, case = %s \n',  ktrust, case_str);
            timerVal=tic;
            [soln, Gopt_greedyAlgorithm(case_indx,1),soln_minus]=greedyAlgorithm(set_of_options, ktrust, gamma);
            ub_ratio_greedy(case_indx) = 1+log(ktrust/(ktrust-gamma(soln_minus)));                
            Sopt_greedyAlgorithm(case_indx,1) = {soln};
            elapsedTime_greedyAlgorithm(case_indx,1) = toc(timerVal);
        else
            %% Run Algorithm 2
            fprintf('\n>> Run algorithm 2 | ktrust = %d, case = %s \n',  ktrust, case_str);
            timerVal=tic;
            if false %strcmpi(case_str,'matfiles/IEEE118_3')
                % Skip the huge computational wait by reusing list_of_Popt
                [soln, Gopt_algorithm2(case_indx,kindx), list_of_Popt, list_of_PQopt, ub_ratio_algorithm2(case_indx,kindx)]=Algorithm2(set_of_options, Stask, ktrust, gamma, list_of_Popt);
                elapsedTime_algorithm2(case_indx,kindx) = toc(timerVal)+elapsedTime_CPonly(case_indx,kindx);
            else
                [soln, Gopt_algorithm2(case_indx,kindx), list_of_Popt, list_of_PQopt, ub_ratio_algorithm2(case_indx,kindx)]=Algorithm2(set_of_options, Stask, ktrust, gamma);
                elapsedTime_algorithm2(case_indx,kindx) = toc(timerVal);
            end
            S_P(case_indx,kindx) = {list_of_Popt};
            S_PQ(case_indx,kindx) = {list_of_PQopt};
            Sopt_algorithm2(case_indx,kindx) = {soln{:}};            
        end                
    end
    clear list_of_Popt
end

% fprintf('\n\n>> Comparing results\n====================\n');
% disp('For undesired behaviour, the messages will be prepended with ###');
% if isequal(Sopt_algorithm2(:,1:2),Sopt_CPonly)
%     disp('Algorithm 2 result is optimal for k_{trust}<=\Gamma(S_{task})');
% else
%     disp('### Algorithm 2 result is NOT optimal for k_{trust}<=\Gamma(S_{task})');
% end
% if isequal(Sopt_algorithm2(:,4),Sopt_greedyAlgorithm)
%    disp('Algorithm 2 result matched with greedy algorithm solution.');
% else
%    disp('### Algorithm 2 result did NOT match with greedy algorithm solution.');
% end 
