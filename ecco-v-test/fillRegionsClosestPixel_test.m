% addpath('/h/eol/brenda/git/lrose-ecco/ecco-v/ecco-v_functions');

classdef fillRegionsClosestPixel_test < matlab.unittest.TestCase
    methods(Test)

        function fillRegionsClosestPixel_one_component(testCase)

            VEL = [  0         0         0         0         0;
                3.5377    3.8622    2.5664         0         0;
                4.8339    3.3188    3.3426         0         0;
                0.7412    1.6923    6.5784         0         0;
                     0         0         0         0         0];

            pixRad = 2;
            velBase = 0;
            [VELmask, VELsmall, velText] = f_velTexturePre(VEL,pixRad,velBase)

            actSolution = f_fillRegionsClosestPixel(VELmask, VELsmall, velText, VEL)
            actSolution;
            velExpect = [          0         0         0         0       NaN;
                              1.7075    2.2744    1.6882    1.1839       NaN;
                              1.8901    2.4344    1.8827    1.4173       NaN;
                              2.5992    4.0022    4.3371    3.6357       NaN;
                                   0         0         0         0       NaN];

            decimal = 1e-5;
            testCase.verifyEqual(actSolution,velExpect,"AbsTol",1e-4)
        end
    end
end
