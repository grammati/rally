import unittest
import spiral

class SpiralTest(unittest.TestCase):
    def test_spiral(self):
        self.assertEqual("0 \n", spiral.string(1))

        self.assertEqual("""6 7 8 
5 0 1 
4 3 2 
""", spiral.string(9))

        self.assertEqual("""20 21 22 23 24 
19 6 7 8 9 
18 5 0 1 10 
17 4 3 2 11 
16 15 14 13 12 
""", spiral.string(25))

        # Invalid input
        self.assertRaises(Exception, spiral.string, -1)

        # Imperfect numbers as input (not an odd square)
        self.assertEqual("""6 7 * 
5 0 1 
4 3 2 
""", spiral.string(8))

        self.assertEqual("""* * * 
* 0 1 
4 3 2 
""", spiral.string(5))




if __name__ == '__main__':
    unittest.main()
