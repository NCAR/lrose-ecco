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

    def test_5x5_ones(self):
        VEL = np.ones((5,5))
        pixRad = 3
        velPadded = np.pad(VEL, ((0, 0), (pixRad, pixRad)), mode='constant', constant_values=np.nan)
        velText = np.empty(np.shape(VEL))
        velText[:] = np.nan
        velActual = pw.pull_out_window(velPadded, pixRad, velText)

        print("velActual = ")
        print(velActual)

        velExpect = np.array([
            [0.70340104, 0.7013854 , 0.        , 0.7013854 ,        np.nan],
            [0.70340104, 0.7013854 , 0.        , 0.7013854 ,        np.nan],
            [0.70340104, 0.7013854 , 0.        , 0.7013854 ,        np.nan],
            [0.70340104, 0.7013854 , 0.        , 0.7013854 ,        np.nan],
            [0.70340104, 0.7013854 , 0.        , 0.7013854 ,        np.nan]])


        print("velExpect = ")
        print(velExpect)

        decimal = 1e-5
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
# >>> velText
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
