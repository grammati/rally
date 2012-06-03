import unittest
import spiral

class SpiralTest(unittest.TestCase):
    def test_spiral(self):
        self.assertEqual("0\n", spiral.string(0))
        self.assertEqual("""20 21 21 23 24
19 6 7 8 9
18 5 0 1 10
17 4 3 2 11
16 15 14 13 12
""", spiral.string(24))


if __name__ == '__main__':
    unittest.main()