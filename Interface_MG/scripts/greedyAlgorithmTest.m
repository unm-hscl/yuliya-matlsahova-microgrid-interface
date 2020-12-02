classdef greedyAlgorithmTest < matlab.unittest.TestCase
    %GREEDYALGORITHMTEST Test for GreedyAlgorithm
    %
    % Created by Abraham Vinod and Adam Thorpe
    
    properties (Access = public)

    end
    
    methods (Static)
    end
    
    methods (Test)
        function testGreedyAlgorithmCase1(testCase)
            IEEE118_System = loadSystem('matfiles/IEEE118_1');
            set_of_options = IEEE118_System.s;
            ktrust = size(IEEE118_System.Abar,2);
            gamma = @(z) computeGamma(z, IEEE118_System.Co, IEEE118_System.Abar);
            [Sopt, Gopt]=greedyAlgorithm(set_of_options, ktrust, gamma);
            testCase.verifyEqual(Sopt,1:54);
            testCase.verifyEqual(Gopt,IEEE118_System.N);
        end
    end
end

