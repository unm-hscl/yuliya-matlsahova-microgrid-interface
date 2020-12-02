function [Srelv, Sirrelv]=sRelvAndIrrelv(set_of_options, Stask, gamma)
    % SRELVANDIRRELV Computes S_{relv} and S_{irrelv} given a task
    
    Srelv = [];    
    
    % Compute gamma(Stask)
    G_Stask = gamma(Stask);

    for si = set_of_options
        % Compute gamma(S U Stask) and gamma(s_i)
        G_si_U_Stask = gamma(union(si, Stask));
        G_si = gamma(si);

        % Reject sensor combinations that either violate G(s_i U Stask) > t OR
        % G(s_i U Stask) = G(s_i) + G(Stask) (no overlap) OR G(s_i) > kparam
        % TODO: 54 is a problem specific limit
        if G_si_U_Stask < G_Stask + G_si && si <= 54
            Srelv = [Srelv, si];
        end
    end    
    Sirrelv = setdiff(set_of_options,Srelv);
end