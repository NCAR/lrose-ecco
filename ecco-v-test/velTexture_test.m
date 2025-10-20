classdef velTexture_test < matlab.unittest.TestCase
    methods(Test)
        function nonnumericInput(testCase)
            testCase.verifyError(@()quadraticSolver(1,'-3',2), ...
                'quadraticSolver:InputMustBeNumeric')
        end
	function velTexture_zero(testCase)
	    actSolution = f_velTexture([0,0,0,0], 2, -1);
	    expSolution = [0     0     0   NaN];
	    testCase.verifyEqual(actSolution,expSolution)
	end
%	function velTexture_simple(testCase)
%	    actSolution = f_velTexture([5,6,7,8,9], 5, -1);
%	    expSolution = [3.2587    3.1047    3.0594    3.2722       NaN];
%	    testCase.verifyEqual(actSolution,expSolution)
%	end
	function velTexture_rand(testCase)
	    VEL = [
            79.,  9., 78., 13.;
            12., 97., 48., 30.;
            85., 48., 60.,  5.;
            39., 57., 71., 79.]
	    pixRad = 2;
	    velBase = 1;
	    actSolution = f_velTexture(VEL, pixRad, velBase);
	    actSolution;
	    expSolution_python = [
	    40.38800768, 40.38800768, 32.37019165, 32.37019165;
            40.38800768,      nan,      nan, 32.37019165;
            40.38800768, 40.38800768, 32.37019165, 32.37019165;
            40.38800768, 40.38800768, 32.37019165, 32.37019165]
	    expSolution_matlab = [
	       54.6788   55.7095   48.5106       NaN;
               51.4405   62.0419   58.6940       NaN;
               38.7871   42.7051   34.2273       NaN;
               24.8109   21.6468   26.7611       NaN]
	    testCase.verifyEqual(actSolution,expSolution_matlab,"AbsTol",1e-4)
	end

        function velTexture_20x20_zero_5_5_nan_15_15(testCase)
            VEL = ones(20,20);
            VEL(5,5) = 0;
            VEL(15,15) = nan ;
            pixRad = 5;
            velBase = 10;
            actSolution = f_velTexture(VEL, pixRad, velBase);
            actSolution;
            velExpect = zeros(20,20)
            velExpect(15,15) = nan
            velExpect(:,20) = nan
            decimal = 1e-5
            testCase.verifyEqual(actSolution,velExpect,"AbsTol",1e-4)
        end

    % python version 
%    def test_20x20_zero_5_5_nan_15_15(self):
%        VEL = np.ones((20,20))
%        VEL[4,4] = 0
%        VEL[14,14] = np.nan
%        pixRad = 5  # int between 0 and len(VEL) ??
%        velBase = 10   # base value for velocities; this is subtracted from VEL; must have same dimensions as VEL? or not???
%        velActual = f_velTexture.f_velTexture(VEL, pixRad, velBase)
%        print(velActual)
%        velExpect = np.zeros((20,20))
%        velExpect[14,14] = np.nan
%        velExpect[:,19] = np.nan
%        decimal = 1e-5
%        result = np.allclose(velActual, velExpect, decimal, equal_nan = True)
%        # self.assertAlmostEqual(velActual, velExpect, decimal, "not equal")
%        self.assertTrue(result, "not equal")
%
%
%
%    end

end
