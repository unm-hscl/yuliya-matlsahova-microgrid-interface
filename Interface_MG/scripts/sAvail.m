function feas = sAvail(typeOfSearch, Srelv, Stask, gamma)
    
    % Compute Gamma(Stask)
    G_Stask = gamma(Stask);
    G_Srelv = gamma(Srelv);
    
    % Stask is guaranteed to be a feasible solution
    
    % Cell to store the solutions
    feas_list(1) = {Stask};
        
    % Create cardinality_Sopt if min
    if strcmpi(typeOfSearch,'min')
        cardinality_Sopt = length(Stask);
    elseif strcmpi(typeOfSearch,'list')
    else
        error('Invalid typeOfSearch in sAvail.m');
    end

    % Main constraint loop.
    for t = G_Stask:G_Srelv
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Initial check for propagatable constraints
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        sensors_to_retain = [];    
        for si = Srelv
            % Compute gamma(S U Stask) and gamma(s_i)
            G_si_U_Stask = gamma(union(si, Stask));

            % Reject sensor combinations that either violate G(s_i U Stask) > t
            if G_si_U_Stask <= t
                sensors_to_retain = [sensors_to_retain, si];
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Can we skip checking this iteration ?
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        G_sensors_to_retain = gamma(sensors_to_retain);
        if G_sensors_to_retain < t
            fprintf('Skipping t=%d since G(S_relv) < t\n', t);
            if gamma(Srelv) == gamma(union(Srelv,Stask))
                must_include_sensors = Srelv;
            end
        else
            must_include_sensors = [];
            for si = sensors_to_retain
                gamma_all_but_si = gamma(setdiff(sensors_to_retain,si));
                % Will we able to obtain gamma(Stask) without si?
                if gamma_all_but_si < G_Stask
                    % If not, then it is a must_include_sensor
                    must_include_sensors = [must_include_sensors, si];
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Update the user in the current problem params%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('Current value of t = %d in [%d, %d]\n', t, G_Stask, G_Srelv);
        if strcmpi(typeOfSearch,'min') 
            fprintf('Current |Sopt| = %d\n', cardinality_Sopt);
        else
            fprintf('No. of feasible solutions = %d\n', length(feas_list));
        end
        sensors_to_iterate = setdiff(sensors_to_retain, must_include_sensors);
        % Redefinition for masking
        sensors_to_iterate = [intersect(sensors_to_iterate,Stask),setdiff(sensors_to_iterate,Stask)];
        fprintf('No. of sensors fixed = %d\n', length(must_include_sensors));
        fprintf('No. of sensors to search = %d\n\n', length(sensors_to_iterate));
            
            
        if gamma(must_include_sensors) == gamma(union(must_include_sensors,Stask)) || isempty(sensors_to_iterate)
            % Do we have user-availability with just the
            % must_include_sensors?
            if isequal(must_include_sensors,Stask)
                continue
            else                
                fprintf('A unique base template found | ');
                if strcmpi(typeOfSearch,'min') 
                    if length(must_include_sensors) < cardinality_Sopt
                        % If min then update cardinality constraints
                        cardinality_Sopt = length(must_include_sensors);
                        Itr.maxCard = cardinality_Sopt-1;
                        fprintf(' Updated.\n');
                    else
                        fprintf(' But smaller set available.\n');
                    end
%                 elseif strcmpi(typeOfSearch,'list')
                end
                feas_list(end + 1) = {must_include_sensors};
            end
        else
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Iterate over sensors_to_iterate %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            Itr = psIterator(sensors_to_iterate);
            Itr.displayFlag = 1;
            disp('Masking feasible solutions');
            for feas_indx = 1:length(feas_list)
                % Creating a mask based on existing feas
                feas_study = feas_list(feas_indx);
                masked_in_sensors_to_iterate = intersect(sensors_to_iterate,feas_study{:});
                bin_masked_in_sensors_to_iterate = zeros(1,length(sensors_to_iterate));
                for sidx = 1:length(sensors_to_iterate)
                    if any(masked_in_sensors_to_iterate==sensors_to_iterate(sidx))
                        bin_masked_in_sensors_to_iterate(sidx) = 1;
                    end
                end
                dec_masked_in_sensors_to_iterate = bi2de(bin_masked_in_sensors_to_iterate);
                Itr.mask(dec_masked_in_sensors_to_iterate);
            end
            % Set cardinality constraint (if any) -1 for aggressiveness | Otherwise
            % maxCard is internally set to all number of sensors
            if strcmpi(typeOfSearch,'min')
                fprintf('>>> Given the current |Sopt|, we will search for sensor combinations smaller than %d\n', cardinality_Sopt);
                Itr.maxCard = (cardinality_Sopt-length(must_include_sensors)) -1;
            end
            disp('Begin iteration...');
            while true
                % Get the next sensor combination to check
                [S, ~, D] = Itr.next();
                if isempty(S)
                    break;
                end
                
                % Add must_include_sensors
                S = union(must_include_sensors, S);

                % Compute gamma(S U Stask) and gamma(S)
                G_S = gamma(S);
                G_S_U_Stask = gamma(union(S, Stask));

                if G_S_U_Stask <= t
                    if G_S >= t
                        feas_list(end + 1) = {S};                            
                        if strcmpi(typeOfSearch,'min') && cardinality_Sopt > length(S)
                            % If min then update cardinality constraints
                            cardinality_Sopt = length(S);
                            Itr.maxCard = (cardinality_Sopt-length(must_include_sensors)) -1;
                            % Best feasible solution so far with |S| < minCard
                            fprintf('\n Found a solution of cardinality %d', cardinality_Sopt);                
                        elseif strcmpi(typeOfSearch,'list')
                            % Best feasible solution so far with |S| < minCard
                            fprintf('\n Found a total of %d solution(s)', length(feas_list));                
                        end
                        % All supersets are user-available -> So don't
                        % iterate
                        Itr.mask(D);                        
                    end
                else
                    % Propagate the infeasibility
                    Itr.mask(D);
                end
            end
        end
    end
    
    if strcmpi(typeOfSearch,'min')
        feas_cell = feas_list(end);
        feas = feas_cell{:};
    else
        feas = feas_list;
    end
end
