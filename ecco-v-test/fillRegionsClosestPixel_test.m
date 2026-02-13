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

        function fillRegionsClosestPixel_two_components(testCase)

            % bigr=10, bigc=10, c1center=4, c1r=3, c1c=3, c2center=8, c2r=2, c2c=3, mean=3, std=1;
	    % m = genData(bigr, bigc, c1center, c1r, c1c, c2center, c2r, c2c, mean, std)

            VEL = [ 0         0         0         0         0         0         0         0         0         0;
                    0    5.9080    1.9418    4.0984         0         0         0         0         0         0;
                    0    3.8252    2.5314    2.7221         0         0         0         0         0         0;
                    0    4.3790    2.7275    3.7015         0         0         0         0         0         0;
                    0         0         0         0         0         0         0         0         0         0;
                    0         0         0         0         0         0         0         0         0         0;
                    0         0         0         0         0    0.9482    2.1764    3.5080         0         0;
                    0         0         0         0         0    2.6462    1.4229    3.2820         0         0;
                    0         0         0         0         0         0         0         0         0         0;
                    0         0         0         0         0         0         0         0         0         0];

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
