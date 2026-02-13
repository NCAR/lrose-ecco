import unittest
import numpy as np
import sys
sys.path.insert(1, '../ecco-v-py')
import pullOutWindow as pw

class Test_velTexture_Methods(unittest.TestCase):

    @unittest.skip("demonstrating skipping")
    def test_zero(self):
        VEL=[0,0,0,0]
        pixRad = 2  # int between 0 and len(VEL) ??
        velBase = -1   # base value for velocities; this is subtracted from VEL; must have same dimensions as VEL? or not???
        velText = f_velTexture.f_velTexture(VEL, pixRad, velBase)
        velExpect = [0,0,0,np.Nan]
        self.assertEqual(velActual, velExpect)

    @unittest.skip("demonstrating skipping")
    def test_rand(self):
        VEL = np.array([
            [79.,  9., 78., 13.],
            [12., 97., 48., 30.],
            [85., 48., 60.,  5.],
            [39., 57., 71., 79.]])
        pixRad = 2  # int between 0 and len(VEL) ??
        velBase = 1   # base value for velocities; this is subtracted from VEL; must have same dimensions as VEL? or not???
        velActual = f_velTexture.f_velTexture(VEL, pixRad, velBase)
        print(velActual)
        velExpect = np.array([
            [40.38800768, 40.38800768, 32.37019165, 32.37019165],
            [40.38800768,      np.nan,      np.nan, 32.37019165],
            [40.38800768, 40.38800768, 32.37019165, 32.37019165],
            [40.38800768, 40.38800768, 32.37019165, 32.37019165]])
        # velExpect_matlab = np.array([...
        decimal = 1e-5
        result = np.allclose(velActual, velExpect, decimal, equal_nan = True)
        # self.assertAlmostEqual(velActual, velExpect, decimal, "not equal")
        self.assertTrue(result, "not equal")

    def test_scipy_cKDTree_one_component(self):
        import numpy as np
        import cv2 as cv
        import pullOutWindow as pw
        import f_velTexturePre as vtp
        import fillRegionsClosestPixel as frcp

        VEL = np.array([[0,0,0,0,0], [3.5377,3.8622,2.5664,0,0], [4.8339,3.3188,3.3426,0,0], [0.7412,1.6923,6.5784,0,0], [0,0,0,0,0]])
        pixRad = 2
        velBase = 0
        VELmask, VELsmall, velText = vtp.f_velTexture(VEL,pixRad,velBase)

        retval, labels = cv.connectedComponents(VELmask)
        velActual = frcp.fillRegionsClosestPixel(VELmask, VELsmall, velText, VEL)
        velExpect = np.array([
            [0.        , 0.        , 0.        , 0.        ,        np.nan],
            [1.70757646, 2.27440453, 1.68817099, 1.18394518,        np.nan],
            [1.89013863, 2.43437944, 1.88271026, 1.41732399,        np.nan],
            [2.59920887, 4.0022225 , 4.33711156, 3.63572722,        np.nan],
            [0.        , 0.        , 0.        , 0.        ,        np.nan]])

        print("velActual = ")
        print(velActual)

        print("velExpect = ")
        print(velExpect)

        decimal = 1e-5
        result = np.allclose(velActual, velExpect, decimal, equal_nan = True)
        # self.assertAlmostEqual(velActual, velExpect, decimal, "not equal")
        self.assertTrue(result, "not equal")


    def test_scipy_cKDTree_two_components(self):
        import numpy as np
        import cv2 as cv
        import pullOutWindow as pw
        import f_velTexturePre as vtp
        import fillRegionsClosestPixel as frcp

        VEL = np.array([
            [0,        0,        0,        0, 0,        0,        0,        0, 0, 0],
            [0,   5.9080,   1.9418,   4.0984, 0,        0,        0,        0, 0, 0],
            [0,   3.8252,   2.5314,   2.7221, 0,        0,        0,        0, 0, 0],
            [0,   4.3790,   2.7275,   3.7015, 0,        0,        0,        0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0,        0,        0,        0, 0,   0.9482,   2.1764,   3.5080, 0, 0],
            [0,        0,        0,        0, 0,   2.6462,   1.4229,   3.2820, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]])
 
        pixRad = 2
        velBase = 0
        [VELmask, VELsmall, velText] = vtp.f_velTexture(VEL,pixRad,velBase)
 
        velActual = frcp.fillRegionsClosestPixel(VELmask, VELsmall, velText, VEL)
        velExpect = np.array([
            [0, 0, 0, 0, 0, 0, 0, 0, 0,       np.nan],
            [3.1898, 3.8120,    3.7372,    2.5388,    2.0744,    1.4811, 0, 0, 0,       np.nan],
            [1.8173, 2.3941,    2.3161,    1.5529,    1.1164,    0.8541, 0, 0, 0,       np.nan],
            [2.1356, 2.7278,    2.8059,    2.2085,    1.7154,    1.3059, 0, 0, 0,       np.nan],
            [0, 0, 0, 0, 0, 0, 0, 0, 0,       np.nan],
            [0, 0, 0, 0, 0, 0, 0, 0, 0,       np.nan],
            [0, 0, 0,      0, 0.3318,    1.0404,    2.0304,    2.2148,    1.6660,       np.nan],
            [0, 0, 0, 0.8177, 1.2243,    1.5679,    2.0662,    2.0540,    1.6406,       np.nan],
            [0, 0, 0, 0, 0, 0, 0, 0, 0,       np.nan],
            [0, 0, 0, 0, 0, 0, 0, 0, 0,       np.nan] ])
  
        print("velActual = ")
        print(velActual)

        print("velExpect = ")
        print(velExpect)

        decimal = 1e-4
        result = np.allclose(velActual, velExpect, decimal, equal_nan = True)
        # self.assertAlmostEqual(velActual, velExpect, decimal, "not equal")
        self.assertTrue(result, "not equal") 

    @unittest.skip("demonstrating skipping")
    def test_10x10_ones_pixRad_2_velBase_0(self):
        VEL = np.ones((10,10))
        pixRad = 2  # int between 0 and len(VEL) ??
        velBase = 0   # base value for velocities; this constant is subtracted from VEL
        velActual = f_velTexture.f_velTexture(VEL, pixRad, velBase)
        print("velActual = ")
        print(velActual)

#
#         velText
# array([[ 0.,  0.,  0.,  0.,  0.,  0.,  0.,  0.,  0., nan],
#        [ 0.,  0.,  0.,  0.,  0.,  0.,  0.,  0.,  0., nan],
#        [ 0.,  0.,  0.,  0.,  0.,  0.,  0.,  0.,  0., nan],
#        [ 0.,  0.,  0.,  0.,  0.,  0.,  0.,  0.,  0., nan],
#        [ 0.,  0.,  0.,  0.,  0.,  0.,  0.,  0.,  0., nan],
#        [ 0.,  0.,  0.,  0.,  0.,  0.,  0.,  0.,  0., nan],
#        [ 0.,  0.,  0.,  0.,  0.,  0.,  0.,  0.,  0., nan],
#        [ 0.,  0.,  0.,  0.,  0.,  0.,  0.,  0.,  0., nan],
#        [ 0.,  0.,  0.,  0.,  0.,  0.,  0.,  0.,  0., nan],
#        [ 0.,  0.,  0.,  0.,  0.,  0.,  0.,  0.,  0., nan]])
#

        velExpect = np.zeros((10,10))
        velExpect[:,9] = np.nan
        decimal = 1e-5
        result = np.allclose(velActual, velExpect, decimal, equal_nan = True)
        # self.assertAlmostEqual(velActual, velExpect, decimal, "not equal")
        self.assertTrue(result, "not equal")

if __name__ == '__main__':
    unittest.main()
