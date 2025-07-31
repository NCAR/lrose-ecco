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
    end
end
