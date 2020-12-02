classdef Algorithm3Test < matlab.unittest.TestCase
    %GREEDYALGORITHMTEST Test for GreedyAlgorithm
    %
    % Created by Abraham Vinod and Adam Thorpe
    
    properties (Access = public)

    end
    
    methods (Static)
    end
    
    methods (Test)
        function testAlgorithm3Case1(testCase)
            IEEE118_System = loadSystem('matfiles/IEEE118_1');
            set_of_options = IEEE118_System.s;
            Stask = IEEE118_System.Stask;
            gamma = @(z) computeGamma(z, IEEE118_System.Co, IEEE118_System.Abar);
            [Sopt, Gopt]=Algorithm3(set_of_options, Stask, 0, gamma);
            testCase.verifyEqual(length(Sopt),length(Stask));
            testCase.verifyEqual(Gopt,gamma(Stask));
        end
        
        function testAlgorithm3Case1_highktrust(testCase)
            IEEE118_System = loadSystem('matfiles/IEEE118_1');
            set_of_options = IEEE118_System.s;
            Stask = IEEE118_System.Stask;
            ktrust = 60;
            gamma = @(z) computeGamma(z, IEEE118_System.Co, IEEE118_System.Abar);
            [Sopt, Gopt]=Algorithm3(set_of_options, Stask, ktrust, gamma);
            testCase.verifyEqual(length(Sopt),length(Stask) + 13);
            testCase.verifyGreaterThanOrEqual(Gopt,ktrust);
        end
        
%         function testAlgorithm3Case3(testCase)
%             IEEE118_System = loadSystem('matfiles/IEEE118_3');
%             set_of_options = IEEE118_System.s;
%             Stask = IEEE118_System.Stask;
%             gamma = @(z) computeGamma(z, IEEE118_System.Co, IEEE118_System.Abar);
%             [Sopt, Gopt]=Algorithm3(set_of_options, Stask, 0, gamma);
%             testCase.verifyEqual(length(Sopt),length(Stask));
%             testCase.verifyEqual(Gopt,gamma(Stask));
%         end

    end
end

