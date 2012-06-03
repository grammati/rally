#! /usr/bin/python
# spiral.py

import math
from StringIO import StringIO

class Spiraler:

    def __init__(self, n):
        assert n > 0, "n must be one or more"
        
        # limit is the largest number to be printed
        self.limit = n - 1

        # The "order" is the number of cells in each row or column, which is
        # always and odd number.
        # A spiral of order N contains a spiral or order N-2 inside it.
        self.order = int( math.ceil( math.sqrt(n) ) )

        # Set self.n to the total number of cells in this spiral:
        self.n = self.order ** 2

        # Delegate to another instance responsible for creating the inner spiral
        # - that is, the spiral of order self.order - 2.
        if self.order >= 3:
            self.inner = Spiraler((self.order - 2) ** 2)
        else:
            self.inner = None

        # For convenience, precalculate the lowest number in the "outer shell".
        self.first = (self.order - 2) ** 2

    def row(self, rownum):
        "Returns an iterator of the numbers that constitute the given row (zero-based)."
        if rownum == 0:
            # first row is the ascending sequence of self.order
            # numbers ending at self.n
            for i in range(self.n - self.order, self.n):
                yield i
        elif rownum == self.order - 1:
            # last row is the descending sequence of self.order
            # numbers from (self.n - self.order - (self.order - 1))
            start = (self.n 
                     - self.order # first row
                     - (self.order - 1)) # first column - top cell
            for i in range(start, start - self.order, -1):
                yield i
        else:
            # Other rows: number in the first column, then delegate to inner,
            # then number in last column.
            yield self.n - self.order - rownum
            if self.inner:
                for i in self.inner.row(rownum - 1):
                    yield i
            yield self.first + rownum - 1

    def rows(self):
        "Returns an iterator over the rows, where each row is itself an iterator over numbers."
        for rownum in range(0, self.order):
            yield self.row(rownum)

    def write_to(self, writer):
        for row in self.rows():
            for number in row:
                writer.write("%d " % number)
            writer.write("\n")


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
