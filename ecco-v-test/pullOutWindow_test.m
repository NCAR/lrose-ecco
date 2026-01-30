% addpath('/h/eol/brenda/git/lrose-ecco/ecco-v/ecco-v_functions');

classdef pullOutWindow_test < matlab.unittest.TestCase
    methods(Test)

        function pullOutWindow_5x5_ones(testCase)
            VEL = ones(5,5);
            pixRad = 3;
	    velText=nan(size(VEL));
            velPadded=padarray(VEL,[0 pixRad],nan);

            actSolution = pullOutWindow(velPadded,pixRad,velText);
            actSolution;
            velExpect = [ 0.7034    0.7014         0    0.7014       NaN;
                          0.7034    0.7014         0    0.7014       NaN;
                          0.7034    0.7014         0    0.7014       NaN;
                          0.7034    0.7014         0    0.7014       NaN;
                          0.7034    0.7014         0    0.7014       NaN];
 
            decimal = 1e-5;
            testCase.verifyEqual(actSolution,velExpect,"AbsTol",1e-4)
        end
    end
end
