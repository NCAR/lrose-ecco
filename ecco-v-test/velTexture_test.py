import unittest
import numpy as np
import sys
sys.path.insert(1, '../ecco-v-py')
import f_velTexture

class Test_velTexture_Methods(unittest.TestCase):

    @unittest.skip("demonstrating skipping")
    def test_zero(self):
        VEL=[0,0,0,0]
        pixRad = 2  # int between 0 and len(VEL) ??
        velBase = -1   # base value for velocities; this is subtracted from VEL; must have same dimensions as VEL? or not???
        velText = f_velTexture.f_velTexture(VEL, pixRad, velBase)
        velExpect = [0,0,0,np.Nan]
        self.assertEqual(velActual, velExpect)

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

    def test_20x20_zero_5_5_nan_15_15(self):
        VEL = np.ones((20,20))
        VEL[4,4] = 0
        VEL[14,14] = np.nan
        pixRad = 5  # int between 0 and len(VEL) ??
        velBase = 10   # base value for velocities; this is subtracted from VEL; must have same dimensions as VEL? or not???
        velActual = f_velTexture.f_velTexture(VEL, pixRad, velBase)
        print(velActual)
        velExpect = np.zeros((20,20))
        velExpect[14,14] = np.nan
        velExpect[:,19] = np.nan
        decimal = 1e-5
        result = np.allclose(velActual, velExpect, decimal, equal_nan = True)
        # self.assertAlmostEqual(velActual, velExpect, decimal, "not equal")
        self.assertTrue(result, "not equal")

if __name__ == '__main__':
    unittest.main()
