clear
clc
load('/datafiles/Dropbox/MatFiles/2018TCST/AllCases.mat')

Stask_cell{1} = Stask_case1;
Stask_cell{2} = Stask_case2a;
Stask_cell{3} = Stask_case2b;
Stask_cell{4} = Stask_case3;
for case_indx = 1:4
    print_output(Stask_cell{case_indx},Sopt_CPonly{case_indx,1},elapsedTime_CPonly(case_indx,1),length(S_P{case_indx,1}),1);
    print_output(Stask_cell{case_indx},Sopt_algorithm2{case_indx,2},elapsedTime_algorithm2(case_indx,2),length(S_P{case_indx,2}),ub_ratio_algorithm2(case_indx,2));
    print_output(Stask_cell{case_indx},Sopt_greedyAlgorithm{case_indx},elapsedTime_greedyAlgorithm(case_indx),0,ub_ratio_greedy(case_indx));
    fprintf('\n');
end

function print_output(Stask,SensorComb,elapsedTime,Soptlength,Delta)
    if isequal(SensorComb,1:54)
        fprintf('%d | %1.3f | %s | %1.3f\n', Soptlength, Delta, 'All sensors', elapsedTime);
    elseif isequal(SensorComb,Stask)
        % S == Stask
        fprintf('%d | %1.3f | %s | %1.3f\n', Soptlength, Delta, '\mathcal{S}_{task}', elapsedTime);
    elseif all(ismember(Stask,SensorComb))
        % Stask is a subset of Sopt
        fprintf('%d | %1.3f | \\mathcal{S}_task \\cup {%s} | %1.3f\n', Soptlength, Delta, num2str(setdiff(SensorComb,Stask)), elapsedTime);
    elseif all(ismember(SensorComb,Stask))
        % Stask is a subset of Sopt
        fprintf('%d | %1.3f | \\mathcal{S}_task \\ {%s} | %1.3f\n', Soptlength, Delta, num2str(setdiff(Stask,SensorComb)), elapsedTime);
    elseif all(ismember(SensorComb,1:54))
        % Stask is a subset of Sopt
        things_to_remove = setdiff(Stask,SensorComb);
        things_to_add = setdiff(SensorComb,Stask);
        fprintf('%d | %1.3f | \\mathcal{S}_task \\ {%s} U {%s} | %1.3f\n', Soptlength, Delta, num2str(things_to_remove), num2str(things_to_add), elapsedTime);
        things_to_remove = setdiff(1:54,SensorComb);
        fprintf('OR All sensors \\ {%s}\n', num2str(things_to_remove));
    else
        disp('No relation');
    end
end