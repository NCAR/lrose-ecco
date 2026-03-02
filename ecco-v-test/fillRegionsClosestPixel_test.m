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
            velExpect = [      0         0         0         0         0         0         0         0         0       NaN;
                          3.1898    3.8120    3.7372    2.5388    2.0744    1.4811         0         0         0       NaN;
                          1.8173    2.3941    2.3161    1.5529    1.1164    0.8541         0         0         0       NaN;
                          2.1356    2.7278    2.8059    2.2085    1.7154    1.3059         0         0         0       NaN;
                               0         0         0         0         0         0         0         0         0       NaN;
                               0         0         0         0         0         0         0         0         0       NaN;
                               0         0         0         0    0.3318    1.0404    2.0304    2.2148    1.6660       NaN;
                               0         0         0    0.8177    1.2243    1.5679    2.0662    2.0540    1.6406       NaN;
                               0         0         0         0         0         0         0         0         0       NaN;
                               0         0         0         0         0         0         0         0         0       NaN] ;

            decimal = 1e-5;
            testCase.verifyEqual(actSolution,velExpect,"AbsTol",1e-4)
        end	 

        function fillRegionsClosestPixel_two_components_nan(testCase)

            % bigr=10, bigc=10, c1center=4, c1r=3, c1c=3, c2center=8, c2r=2, c2c=3, mean=3, std=1;
	    % m = genData(bigr, bigc, c1center, c1r, c1c, c2center, c2r, c2c, mean, std)

            VEL = [ 0         0         0         0         0         0         0         0         0         0;
                    0    5.9080    1.9418       NaN         0         0         0         0         0         0;
                    0    3.8252    2.5314    2.7221         0         0         0         0         0         0;
                    0    4.3790    2.7275    3.7015         0         0         0         0         0         0;
                    0         0         0         0         0         0         0         0         0         0;
                    0         0         0         0         0         0         0         0         0         0;
                    0         0         0         0         0       NaN    2.1764    3.5080         0         0;
                    0         0         0         0         0    2.6462    1.4229    3.2820         0         0;
                    0         0         0         0         0         0         0         0         0         0;
                    0         0         0         0         0         0         0         0         0         0];

            pixRad = 2;
            velBase = 0;
            [VELmask, VELsmall, velText] = f_velTexturePre(VEL,pixRad,velBase)

            actSolution = f_fillRegionsClosestPixel(VELmask, VELsmall, velText, VEL)
            actSolution;
            velExpect = [
                 0     0     0     0     0     0     0     0     0   NaN;
                 0     0     0   NaN     0     0     0     0     0   NaN;
                 0     0     0     0     0     0     0     0     0   NaN;
                 0     0     0     0     0     0     0     0     0   NaN;
                 0     0     0     0     0     0     0     0     0     0;
                 0     0     0     0     0     0     0     0     0     0;
                 0     0     0     0     0   NaN     0     0     0     0;
                 0     0     0     0     0     0     0     0     0     0;
                 0     0     0     0     0     0     0     0     0     0;
                 0     0     0     0     0     0     0     0     0   NaN];

            decimal = 1e-5;
            testCase.verifyEqual(actSolution,velExpect,"AbsTol",1e-4)
        end	 

        function fillRegionsClosestPixel_two_components_overlap(testCase)

            % bigr=10, bigc=10, c1center=6, c1r=3, c1c=3, c2center=8, c2r=2, c2c=3, mean1=3, std1=1, mean2=40, std2=2;
            % m = genData(bigr, bigc, c1center, c1r, c1c, c2center, c2r, c2c, mean1, std1, mean2, std2)
        
            VEL = [ 
                 0         0         0         0         0         0         0         0         0         0;
                 0         0         0         0         0         0         0         0         0         0;
                 0         0         0         0         0         0         0         0         0         0;
                 0         0         0    2.9699    4.0933    3.0774         0         0         0         0;
                 0         0         0    2.8351    4.1093    1.7859         0         0         0         0;
                 0         0         0    3.6277    2.1363    1.8865         0         0         0         0;
                 0         0         0         0         0   39.9863   38.4607   39.5488         0         0;
                 0         0         0         0         0   43.0653   40.7428   42.2347         0         0;
                 0         0         0         0         0         0         0         0         0         0;
                 0         0         0         0         0         0         0         0         0         0];

            pixRad = 2;
            velBase = 0;
            [VELmask, VELsmall, velText] = f_velTexturePre(VEL,pixRad,velBase)

            actSolution = f_fillRegionsClosestPixel(VELmask, VELsmall, velText, VEL)
            actSolution;
            velExpect = [
                 0         0         0         0         0         0         0         0         0       NaN;
                 0         0         0         0         0         0         0         0         0       NaN;
                 0         0         0         0         0         0         0         0         0       NaN;
                 0    0.9715    1.2951    2.0143    2.5742    2.0708    1.3177    1.0217         0       NaN;
                 0    0.9079    1.2805    2.1519    2.5773    1.8998    1.3315    0.2574         0       NaN;
                 0    1.2729    1.7482    2.2955    2.1129    1.1011    0.5584    0.3546         0       NaN;
                 0         0         0   15.6476   18.0419   24.0134   29.1219   23.6645   17.8059       NaN;
                 0         0         0   16.8542   19.4985   25.8850   31.1314   25.2212   19.0460       NaN;
                 0         0         0         0         0         0         0         0         0       NaN;
                 0         0         0         0         0         0         0         0         0       NaN];

            decimal = 1e-5;
            testCase.verifyEqual(actSolution,velExpect,"AbsTol",1e-4)
        end	 


    end
end
