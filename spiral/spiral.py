#! /usr/bin/python
# spiral.py

import math
from StringIO import StringIO

class Spiraler:

    def __init__(self, n):
        assert n >= 0, "n must not be negative"
        self.n = n

    def write_to(self, writer):
        writer.write("%d\n" % self.n)

def string(n):
    "Write a number-spiral of the given size to a string, and return it."
    out = StringIO()
    Spiraler(n).write_to(out)
    return out.getvalue()


if __name__ == '__main__':
    # print to stdout
    import sys
    n = int(sys.argv[1])
    Spiraler(n).write_to(sys.stdout)
