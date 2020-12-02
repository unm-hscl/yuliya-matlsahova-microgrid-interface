function [Sopt, Gopt, ub_subopt_ratio]=Algorithm2(set_of_options, Stask, ktrust, gamma)
    if ktrust > gamma(set_of_options)
        % Impossible to achieve
        error('ktrust provided is too large!');
    else
        %% Computation of Srelv
        Srelv=sRelvAndIrrelv(set_of_options, Stask, gamma);
        
        %% Constraint programming-based minimum cardinality search for user-available sensor combs
        % Construct S_{P}
        list_of_Popt=sAvail('list', Srelv, Stask, gamma);
        % Construct S_{P,trust} and simultaneously search for minimum
        % cardinality element
        minCard = Inf;
%         Sopt_trust_list = [];
        for popt_indx = 1:length(list_of_Popt)
            Popt_cell = list_of_Popt(popt_indx);
            Popt = Popt_cell{:};
            if gamma(Popt) >= ktrust
%                 Sopt_trust_list = [Sopt_trust_list,{Sopt_trust_list}];
                if minCard > length(Popt)
                    minCard_Sopt_among_trust_list = Popt;
                    minCard = length(Popt);
                end
            end
        end
        
        if ~isinf(minCard)%~isempty(Sopt_trust_list)
            Sopt = {minCard_Sopt_among_trust_list};
            Gopt = gamma(Sopt);
            ub_subopt_ratio = 1;
        else        
            S_subopt_list = cell(1,length(list_of_Popt));
            G_subopt_list = zeros(1,length(list_of_Popt));                
            ub_subopt_ratio_list = zeros(1,length(list_of_Popt));                
        
            for popt_indx = 1:length(list_of_Popt)
                P_subopt_cell = list_of_Popt(popt_indx);
                P_subopt = P_subopt_cell{:};            
                gamma_for_Q = @(z) gamma(union(P_subopt,z));
                %% Greedy algorithm on the rest
                fprintf('%5d. Check for greedy solution\n',popt_indx);
                [Q_subopt,~,Q_subopt_minus] = greedyAlgorithm(setdiff(set_of_options,P_subopt), ktrust, gamma_for_Q);
                % Combine the solutions
                S_subopt = reshape(union(P_subopt,Q_subopt),1,[]);
                if minCard > length(S_subopt)
                    min_card_indx = popt_indx;
                    minCard = length(S_subopt);
                end
                S_subopt_list(popt_indx) = {S_subopt};
                G_subopt_list(popt_indx) = gamma(S_subopt);
                ub_subopt_ratio_list(popt_indx) = 1+log(ktrust/(ktrust-gamma_for_Q(Q_subopt_minus)));
            end
            Sopt = S_subopt_list(min_card_indx);
            Gopt = G_subopt_list(min_card_indx);
            ub_subopt_ratio = max(ub_subopt_ratio_list);
        end        
    end        
end

%         load('matfiles/Popt_case3.mat')
