function [Sopt, Gopt, Soptminus]=greedyAlgorithm(set_of_options, ktrust, gamma)

    %% Initialization 
    Sopt = [];
    Soptminus = Sopt;
    Gopt = gamma(Sopt);
    
    if ktrust > gamma(set_of_options)
        % Impossible to achieve
        error('ktrust provided is too large!');
    else
        %% Greedy algorithm
        while Gopt < ktrust
            %% Update the 'prior to termination step' solution
            Soptminus = Sopt;
            
            %% Remove the chosen element
            set_of_options = setdiff(set_of_options, Sopt);
            
            %% If no more elements to iterate, then quit
            if isempty(set_of_options)
                % No more elements left
                break
            end
            
            %% Compute the increment in gamma given the current choice of Sopt
            increment_in_G = zeros(1, length(set_of_options));
            for k_indx = 1:length(set_of_options)
                % Compute S U s_i
                S_U_si = union(Sopt, set_of_options(k_indx));
                % Compute gamma(S U s_i)
                increment_in_G(k_indx) = gamma(S_U_si)-Gopt;
            end
            
            %% Compute the element that brought in the maximum increment
            [max_increment, max_indx] = max(increment_in_G);
            if max_increment == 0
                disp('No improvement found')
                break
            end
            
            %% Update the Gopt and Sopt
            Gopt = max_increment + Gopt;
            Sopt = union(Sopt, set_of_options(max_indx));
            % Display the current status
%             fprintf('G: %3d; |S|: %3d\n', Gopt, length(Sopt));
            
%             %% Ensuring that the computeGamma is working as expected
%             if any(increment_in_G < 0)
%                 % Something wrong with the gamma computation --- Getting 
%                 % G(S U s_i) < G(S)
%                 keyboard
%                 % error('computeGamma did not display the expected monotone increasing behaviour.')
%             end       
        end
    end        
end

