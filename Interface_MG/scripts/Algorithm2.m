function [S_subopt, Gopt, list_of_Popt, S_subopt_list, ub_subopt_ratio]=Algorithm2(set_of_options, Stask, ktrust, gamma, varargin)
    if ktrust > gamma(set_of_options)
        % Impossible to achieve
        error('ktrust provided is too large!');
    else
        %% Computation of Srelv
        Srelv=sRelvAndIrrelv(set_of_options, Stask, gamma);
        
        min_card = Inf;
        
        %% Constraint programming-based minimum cardinality search for user-available sensor combs
        if nargin == 4
            list_of_Popt = sAvail('list', Srelv, Stask, gamma);
        else
            list_of_Popt = varargin{1};
        end
        S_subopt_list = cell(1,length(list_of_Popt));
        Gopt_list = zeros(1,length(list_of_Popt));
        ub_subopt_ratio_list = zeros(1,length(list_of_Popt));                
        
        for popt_indx = 1:length(list_of_Popt)
            P_subopt_cell = list_of_Popt(popt_indx);
            P_subopt = P_subopt_cell{:};
            gamma_for_Q = @(z) gamma(union(P_subopt,z));
            if gamma(P_subopt) < ktrust
                %% Greedy algorithm on the rest | We search over Sirrelv U (Srelv\P_subopt) to account for supersets
                fprintf('%5d. Check for greedy solution\n',popt_indx);
                [Q_subopt,~,Q_subopt_minus] = greedyAlgorithm(setdiff(set_of_options,P_subopt), ktrust, gamma_for_Q);
                % Combine the solutions
                S_subopt = reshape(union(P_subopt,Q_subopt),1,[]);
                ub_subopt_ratio_list(popt_indx) = 1+log(ktrust/(ktrust-gamma_for_Q(Q_subopt_minus)));                
            else
                S_subopt = P_subopt;
            end 
            if min_card > length(S_subopt)
                min_card_indx = popt_indx;
                min_card = length(S_subopt);
            end
            S_subopt_list(popt_indx) = {S_subopt};
            Gopt_list(popt_indx) = gamma(S_subopt);
            
        end
        S_subopt = S_subopt_list(min_card_indx);
        Gopt = Gopt_list(min_card_indx);
        ub_subopt_ratio = max(ub_subopt_ratio_list);
    end        
end

