classdef psIterator < handle
    %PSITERATOR Implementation of a 'Generator' programming pattern.
    %   The iterator does not store the possible sensor combinations in a
    %   variable. That is computationally expensive and memory intensive.
    %   Instead, it returns the next sensor combination in a power set
    %   from a tabular representation. Note that masking a number before 
    %   the enumeration starts still enumerates the number but skips all
    %   its supersets. This behaviour is consistent with masking during
    %   enumeration but can be counter-intuitive when sensor combinations
    %   are eliminated before enumeration begins. See psIteratorTest for
    %   how to account for this behaviour in the form of 'missedCounter'.
    
    properties (Access = public)
        % An array of all sensors.
        s
        % Number of sensors (same as the number of bits)
        N
        % Maximum number of rows in the table
        maxRows
        
        % The current column index.
        cidx
        % The current row index.
        ridx
        
        % An array of masks for the row numbers.
        mask_ridx
        % Binary representation of the masks for the row numbers (MSB on the right hand side) 
        binmask_ridx_rightMSB
        
        % max cardinality to generate
        maxCard        
        
        % display flag --- set to 1 if you want display
        displayFlag
        displayIter
    end
    
    methods
        function obj = psIterator(s)
            %PSITERATOR Construct an instance of this class.
            %
            %   itr = psIterator(s)
            %
            %   's' is an array of all sensors.
            %
            %   Sets inactive cardinality constraints and displayFlag to
            %   'off'
            
            
            obj.s = s;
            obj.N = numel(obj.s);
            
            % Initialize the cardinality constraint --- inactive for now
            obj.maxCard = obj.N;
            
            % (obj.N - 1) because MSB becomes cidx and outer -1 because
            % we count from 0 | length(ridx) is the starting cidx position
            obj.maxRows = 2^(obj.N-1)-1;
            
            % Set column index to zero --- first element
            obj.cidx = 0;
            % Set row index to zero --- first element
            obj.ridx = 0;
            
            % Initialize masks
            obj.mask_ridx = [];
            obj.binmask_ridx_rightMSB = [];
            
            % Initialize display flag --- set to zero by default
            obj.displayFlag = 0;
            obj.displayIter = ceil(obj.maxRows/1e3);
        end
        
        function Value = element(obj, n)
            %ELEMENT Gets a specific element from the power set.
            %   Uses binary encoding to get the element at index 'n'.
            Value = obj.s(logical(n));
        end
        
        function [S, B_rightMSB, D] = next(obj)
            %NEXT Returns the next element of the power set subject to
            %constraints.
            %
            %   [S, B_rightMSB, D] = next(obj)
            %
            %   - 'S' is a cell array containing the next sensor
            %   combination.
            %   - 'B_rightMSB' is the binary number representing the sensor
            %   combination with MSB at the right hand side
            %   - 'D' is the decimal number representing the sensor
            %   combination
            %   
            %   - 'obj' is the iterator object itself.

            if obj.N == 0 || obj.ridx > obj.maxRows
                % Nothing OR nothing left to enumerate
                
                % Return empty combination, set D=B_rightMSB=0;
                S = cell.empty();
                D = 0;B_rightMSB = bi2de(D);
            else
                % Non-empty generator
                
                % Convert the current position to n-bit binary vector
                D = 2^(obj.cidx) + obj.ridx;
                % de2bi is by default right msb
                B_rightMSB = de2bi(D,obj.N);
                % select the elements
                S = obj.element(B_rightMSB);
                
                % cidx will go up to N-1 (maximum) since counting starts
                % from zero
                if obj.cidx < obj.N - 1
                    % Incrementing columns we do not increase in cardinality
                    obj.cidx = obj.cidx + 1;
                else
                    % cidx reached the limit | Time to go to the next row
                    newridx = obj.ridx+1;                    
                    % Make sure the row we are going to enumerate is not
                    % elimiated [obj.bad_ridx(newridx) should be 1 if eliminated]
                    while newridx <= obj.maxRows && obj.bad_ridx(newridx)
                        newridx = obj.jumpToUnMaskedAndCardinalitySatisfyingRidx(newridx);
                    end
                    if newridx <= obj.maxRows && ~obj.isRidxMasked(newridx)
                        % Reset the MSB to be closest to the non-zero ridx
                        % element | It is length (and not +1) because cidx
                        % counts from zero
                        obj.cidx = length(de2bi(newridx));
                        obj.ridx = newridx;
                        if obj.displayFlag == 1 && mod(obj.ridx, obj.displayIter)==0
                            % Next iterations will probably explore the columns
                            fprintf('\nExploring row: %10d,%10d | No. of masks: %10d', obj.ridx,obj.maxRows, length(obj.mask_ridx));
                        end
                    else
                        % Nothing more to enumerate --- obj.ridx = obj.maxRows + 1
                        obj.ridx = obj.maxRows+1;
                        if obj.displayFlag == 1
                            fprintf('\n');
                        end
                    end
                end
            end                            
        end
    end
    
    methods (Access = public)
        
        function tf = chk_ridx_card(obj,current_ridx)
            % CHK_RIDX_CARD Checks if cardinality condition is violated
            %
            %   - tf takes a binary value with 0 means false and 1 means true
            % 
            %   - 'obj' is the iterator object itself
            %   - 'current_ridx' is the row index that needs to be checked
            tf = (nnz(de2bi(current_ridx)) + 1) > obj.maxCard;                    
        end
        
        function tf = bad_ridx(obj,current_ridx)
            % BAD_RIDX Checks if cardinality OR mask constraints are violated
            % 
            %   - tf takes a binary value with 0 means false and 1 means true
            % 
            %   - 'obj' is the iterator object itself
            %   - 'current_ridx' is the row index that needs to be checked
            
            tf = (obj.chk_ridx_card(current_ridx) || obj.isRidxMasked(current_ridx));                    
        end
        
        function mask(obj, decval_of_ridx_to_mask)
            %MASK Set a mask for the iterator.
            % 
            %   - 'obj' is the iterator object itself
            %   - 'decval_of_ridx_to_mask' is the decimal rep. of the pattern in 
            %     the binary representation of the row index that needs to
            %     be excluded
            
            if floor(log2(decval_of_ridx_to_mask))<obj.N-1
                % If s_{obj.N-1} is selected, then no row number that has its supersets
                % This is because the rows arrange with pattern matching
                % uptill s_{obj.N-2}
                obj.mask_ridx = [obj.mask_ridx, decval_of_ridx_to_mask];
                obj.binmask_ridx_rightMSB = [obj.binmask_ridx_rightMSB; 
                                             de2bi(decval_of_ridx_to_mask,obj.N-1)];
            elseif obj.displayFlag == 1
                fprintf('\nSkipping the mask! The sensor combination %d has no supersets in the rows!',decval_of_ridx_to_mask);
            end
        end        
                
        function tf = isRidxMasked(obj,current_ridx)
            %isMasked Compares current row to the iterator masks.
            % 
            %   - tf takes a binary value with 0 means false and 1 means true
            % 
            %   - 'obj' is the iterator object itself
            %   - 'current_ridx' is the row index that needs to be checked
            
            if isempty(obj.mask_ridx)
                % No masks imply isRidxMasked will always be false
                tf = 0;
            elseif current_ridx >= obj.maxRows
                % Non-zero number of masks imply last row will always be
                % masked
                tf = 1;
            else
                % Compute the binary representation of the row index
                % provided
                B_ridx_rightMSB = de2bi(current_ridx,obj.N-1);
                % A row is masked if B_ridx_rightMSB has ones at all the
                % places the binary representation of the masks has ones.
                tf = any(all(obj.binmask_ridx_rightMSB.*B_ridx_rightMSB==obj.binmask_ridx_rightMSB,2));
            end
        end
        
        function newridx = jumpToUnMaskedAndCardinalitySatisfyingRidx(obj,newridx)
            %jumpToUnMaskedAndCardinalitySatisfyingRidx Finds the next row to check
            % based on the masks and the cardinality constraints
            %
            %   - 'newridx' is the next row index that is unmasked
            % 
            %   - 'obj' is the iterator object itself
            %   - 'current_ridx' is the current row index
            newridx = obj.jumpToCardinalitySatisfyingRidx(newridx);
            if isempty(obj.mask_ridx)  
                % If no mask, increment by 1
            else
                % Enumerate the jump values
                while newridx <= obj.maxRows
                    if ~obj.isRidxMasked(newridx)
                        % Found an unmasked row
                        break;
                    end
                    newridx = obj.jumpToCardinalitySatisfyingRidx(newridx);
                end
            end            
        end
        
        function newridx = jumpToCardinalitySatisfyingRidx(obj, current_ridx)
            %jumpToCardinalitySatisfyingRidx Finds the next row
            %that satisfies cardinality constraints
            if obj.chk_ridx_card(current_ridx+1)
                % Go to next largest number that has the same or less
                % cardinality | Strategy --- compute the LSB first
                % and then add 1 to it to skip enumerating over
                % other LSB bits that will have surely have higher
                % cardinality
                % 1. Compute the binary representations [+ 2 for
                % enough space (left-msb for visualization)]
                msb_pos = floor(log2(current_ridx));
                x=de2bi(current_ridx,msb_pos+2,'left-msb');
                y=de2bi(current_ridx-1,msb_pos+2,'left-msb');
                % 2. Compute the LSB
                % http://www.goldsborough.me/bits/c++/low-level/problems/2015/10/11/23-52-02-bit_manipulation/
                LSB_number = bi2de(xor(or(x,y),y),'left-msb');
                % 3. Compute the newridx by newridx + LSB
                newridx = current_ridx + LSB_number;
            else
                newridx = current_ridx + 1;
            end
        end
    end
end