function [G, N, g] = computeGammaSparse(S, Co, A)
%COMPUTEGAMMA Computes the dimension of the user-available space
%associated with sensor combination S. The Markov parameters are generated
%using Co and A
%
%   - 'G' - Dimension of the user-available space associated with sensor 
%           combination S | Could be a cell or an array
%   - 'N' - The matrix corresponding to the similarity transform from the state space to the
%           user-available space with each row normalized
%   - 'g' - Array of relative degrees of the associated MISO systems
%
%   - 'S' - Sensor combination under study
%   - 'Co'- Controllability matrix
%   - 'A' - State matrix


    % In case, S is a cell compute its array values
    if iscell(S)
        S = S{:};
    end

    if isempty(S)
        G = 0;
        N = 0;
        g = 0;
        %warning('Empty S provided to the computeGamma function!');
    else
        % State dimension
        n = size(A, 2);

        % Get C matrix.
        no_sensors_in_S = length(S);
        C = zeros(no_sensors_in_S, n);
        for k=1:no_sensors_in_S
            C(k, S(k)) = 1;
        end

        % No. of inputs --- Co has dimension n x mn
        no_of_inputs = size(Co,2)/n;

        %% Index of first nonzero rows in Markov parameters.
        % Is it positive?
        isOne=((C*Co)~=0);%isOne=abs(C*Co)>eps;
        % Is it the first?
        isOneFirst = (isOne & cumsum(isOne,2) == 1);
        % Get the column number
        [row_idx, j] = ind2sub(size(isOneFirst),find(isOneFirst==1));
        % Factor in the fact that it is MISO system to compute the relative
        % degree associated with output C(k,:)
        g(row_idx) = ceil(j/no_of_inputs);

        % Without the normalization steps, N would be the similarity transform
        N = [];
        for k = 1:no_sensors_in_S
            C_temp = C(k, :);
            % Normalize the C matrix for rank computation        
            N_temp = C_temp./norm(C_temp);
            for power_indx = 1:(g(k) - 1)
                % Next term is (s_i A^(power_indx-1)) * A
                row_N_temp = N_temp(end,:) * A;
                N_temp = [N_temp;
                          row_N_temp./norm(row_N_temp)];
            end
            % Augment the normalized version of the similarity transform for
            % the MISO system to MIMO system similarity transform
            N = [N;N_temp];
        end

        % Had we not normalized, this rank function would have suffered from
        % numerical issues
        G = rank(N);
    end    
end

