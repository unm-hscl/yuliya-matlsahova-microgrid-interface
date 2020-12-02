classdef psIteratorTest < matlab.unittest.TestCase
    %PSITERATORTEST Test for psIterator
    
    properties (Access = public)
        N=0;
        number2mask=0;
        maxCard=0;
        feasibleCounterExpected=0;
        missedCounterExpected=0;
        displayFlag = 0;
    end
    
    methods (Static)
        function [Itr,iterCondition,isMasked] = getIterator(s)
            Itr = psIterator(s);
            iterCondition = @(s) s.ridx <=s.maxRows;
            isMasked = @(A,B) any(all(A.*B==A,2));
        end
    end
    
    methods (Test)
        function testIterationWithoutMasking(testCase)
            % Iterator should return the power set.
            s = [1 2 3 4];
            
            si = testCase.getIterator(s);
            
            % -1 since empty set (0000) is not counted
            for k = 1:(2^4-1)
                val = si.next();
                testCase.verifyNotEmpty(val);
            end                        
            testCase.verifyEmpty(si.next());
        end
        
        function testIterationWithCardinalityConstraints(testCase)
            % Iterator should return all the sensor combinations that have at most two elements
            
            s = [1 2 3 4];
            si = testCase.getIterator(s);
            si.maxCard = 2;
            
            % Total number of such combinations are 4choose1+4choose2.
            for k = 1:(nchoosek(4,2)+nchoosek(4,1))
                val = si.next()
                testCase.verifyNotEmpty(val);
            end                        
            testCase.verifyEmpty(si.next());
        end
        
        function testIterationWithMaskingOnlyAndDisplay(testCase)
            % Iterator should return all the sensor combinations that do
            % not have {s_0,s_1} selected | No cardinality constraint |
            % Tests displayFlag
            
            testCase.N = 5;
            testCase.number2mask = 3;
            testCase.maxCard = testCase.N;
            [testCase.feasibleCounterExpected,testCase.missedCounterExpected] = getCount(testCase);
            testCase.displayFlag = 1;
            fprintf('\n>>> Should explore rows 1,2,4,5,6,8,9,10,12,13,14');
            iterateWithMultipleMaskingConstraint(testCase);
        end

        function testIterationWithMaskingCardinalityAndDisplay(testCase)
            % Iterator should return all the sensor combinations of at most two elements 
            % that do not have {s_0,s_1} selected | Tests displayFlag
            
            testCase.N = 5;
            testCase.number2mask = 3;
            testCase.maxCard = 2;
            [testCase.feasibleCounterExpected,testCase.missedCounterExpected] = getCount(testCase);
            testCase.displayFlag = 1;
            fprintf('\n>>> Should explore rows 1,2,4,8');
            iterateWithMultipleMaskingConstraint(testCase);
        end
        
        function testIterationWithTerminalMaskingCardinalityAndDisplay(testCase)
            % Iterator should return all the sensor combinations that do not 
            % have {s_0,s_4} selected | However since the mask involves s_4, 
            % it is not imposed causing 8 additional elements | Tests displayFlag
            
            testCase.N = 5;
            testCase.number2mask = 17;
            testCase.maxCard = testCase.N;
            testCase.missedCounterExpected =  8;
            testCase.feasibleCounterExpected = 2^5 - testCase.missedCounterExpected -1;
            testCase.displayFlag = 1;
            fprintf('\n>>> Should explore all rows');
            iterateWithMultipleMaskingConstraint(testCase);
        end
        
        function testIterationWithMaskingAndCardConstraintHuge1(testCase)
            % Iterator should return all the sensor combinations with atmost 4 elements that do not 
            % have {s_1,s_2} selected
            
            testCase.N = 8;
            testCase.number2mask = 6;
            testCase.maxCard = 4;
            [testCase.feasibleCounterExpected, testCase.missedCounterExpected] =  getCount(testCase);
            iterateWithMultipleMaskingConstraint(testCase);
        end
        
        function testIterationWithMaskingAndCardConstraintHuge2(testCase)
            % Iterator should return all the sensor combinations with atmost 4 elements that do not 
            % have {s_1,s_3} selected
            
            testCase.N = 10;
            testCase.number2mask = 10;
            testCase.maxCard = 4;
            [testCase.feasibleCounterExpected, testCase.missedCounterExpected] =  getCount(testCase);
            iterateWithMultipleMaskingConstraint(testCase);
        end        
                
        function testIterationWithMaskingAndCardConstraintHuge3(testCase)
            % Iterator should return all the sensor combinations with atmost 4 elements that do not 
            % have {s_0,s_1,s_4} selected
            
            testCase.N = 15;
            testCase.number2mask = 19;
            testCase.maxCard = 5;
            [testCase.feasibleCounterExpected, testCase.missedCounterExpected] =  getCount(testCase);
            iterateWithMultipleMaskingConstraint(testCase);
        end
        
        function testIterationWithMultipleMasking(testCase)
            % Iterator should return all the sensor combinations with atmost 4 elements that do not 
            % have s_0 OR s_2 OR s_3 selected | Tests displayFlag            
            
            testCase.N = 5;
            testCase.number2mask = [1,4,8];
            testCase.maxCard = 5;
            % enumerates {s_1,s_4},{s_1},{s_4}
            testCase.feasibleCounterExpected = 3;
            % misses {s_0},{s_2},{s_3},{s_1,s_2},{s_1,s_3}
            testCase.missedCounterExpected = 5;            
            testCase.displayFlag = 1;
            fprintf('\n>>> Should explore only row 2.');
            iterateWithMultipleMaskingConstraint(testCase);
        end
    end
    
    methods                
        function iterateWithMultipleMaskingConstraint(testCase)
            s = 1:testCase.N;
            
            [si, iterCondition, isMasked] = testCase.getIterator(s);
            si.displayFlag = testCase.displayFlag;
            si.maxCard = testCase.maxCard;
            
            mask_to_test_rightMSB = zeros(length(testCase.number2mask),testCase.N);
            for maskNum_idx=1:length(testCase.number2mask)
                maskNum = testCase.number2mask(maskNum_idx);
                si.mask(maskNum);            
                mask_to_test_rightMSB(maskNum_idx,:) = de2bi(maskNum,testCase.N);
            end

            feasible_counter = 0;
            missed_counter = 0;
            while iterCondition(si)
                [~,B,~] = si.next();
                if isMasked(mask_to_test_rightMSB, B)                    
                    missed_counter = missed_counter + 1;
%                     disp([NaN B]);
                else
                    feasible_counter = feasible_counter + 1;
%                     disp(B);
                end                
            end                  
%             [feasible_counter testCase.feasibleCounterExpected;
%              false_counter testCase.missedCounterExpected]
            testCase.verifyEqual(feasible_counter,testCase.feasibleCounterExpected);
            testCase.verifyEqual(missed_counter,testCase.missedCounterExpected);    
            testCase.verifyEmpty(si.next);
        end
        
        function [count_of_feasible_combs, missed] = getCount(testCase)            
            % Compute the total number of elements            
            assert(length(testCase.number2mask)==1,'Requires a single mask');
            
            % Count the maximum number of elements possible satisfying the
            % cardinality constraint
            tot_number_under_Card = 0;
            for num = testCase.maxCard:-1:1
                tot_number_under_Card = tot_number_under_Card + nchoosek(testCase.N,num);
            end

            % Out of these eliminate enumerates that will be caught using
            % our approach --- rows which match this will be eliminated
            % Since we are matching ridx, the mask_pattern allows
            % flexibility only for bits for ridx + 1 (for fixed cidx).
            
            % Also the number of bits
            mask_pattern_MSB_position = floor(log2(testCase.number2mask))+1;
            number_of_ones_spots_outside = testCase.N-mask_pattern_MSB_position;
            no_of_ones_in_mask_pattern = nnz(de2bi(testCase.number2mask));
            number_of_ones_spots_inside = mask_pattern_MSB_position-no_of_ones_in_mask_pattern;
            max_ones_allowed = testCase.maxCard - no_of_ones_in_mask_pattern;
            
            % Will miss the mask itself
            missed = 0;
            elim_count_excluding_missed = 0;                
            % All ones concenrated within pattern
            if number_of_ones_spots_inside >= 0
                % Let pattern be X0X0
                for ones_added_inside = min(max_ones_allowed,number_of_ones_spots_inside):-1:0
                    % How many like X1X0,X1X1 in a cardinality controlled fashion?
                    missed_in_this_config = nchoosek(number_of_ones_spots_inside,ones_added_inside);
                    % Update the missed versions
                    missed = missed + missed_in_this_config;
                    
                    % Now include the outside points
                    ones_available_for_outside = max_ones_allowed - ones_added_inside;
                    if ones_available_for_outside > 0 
                        % Given X0X0 pattern with a fixed number of zero bits going to be filled, 
                        % - exclude ZZZZ00000 by requiring at least one position be filled in RSB
                        % - include X1XX00000 by requiring at internal positions be filled as well
                        for ones_added_outside = min(number_of_ones_spots_outside,ones_available_for_outside):-1:1
                            elim_count_excluding_missed = elim_count_excluding_missed + missed_in_this_config*nchoosek(number_of_ones_spots_outside,ones_added_outside);
                        end
                    end
                end
            end
                        
            % Generate all possibilities and exclude cardinality violators
            count_of_feasible_combs = tot_number_under_Card - elim_count_excluding_missed - missed;
        end       
    end
end

