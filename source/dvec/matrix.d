module dvec.matrix;

import std.traits : isNumeric, isFloatingPoint;

struct Mat(T, size_t rowSize, size_t colSize) if (isNumeric!T && rowSize > 1 && colSize > 1) {
    public T[rowSize * colSize] data;

    public T opIndex(size_t i, size_t j) {
        return data[rowSize * i + j];
    }

    public void opIndexAssign(T value, size_t i, size_t j) {
        data[rowSize * i + j] = value;
    }

    public void add(Mat!(T, rowSize, colSize) other) {
        static foreach (i; 0 .. data.length) data[i] += other.data[i];
    }

    public void sub(Mat!(T, rowSize, colSize) other) {
        static foreach (i; 0 .. data.length) data[i] -= other.data[i];
    }

    public void mul(T factor) {
        static foreach (i; 0 .. data.length) data[i] *= factor;
    }

    public void div(T factor) {
        static foreach (i; 0 .. data.length) data[i] /= factor;
    }

    public Mat!(T, colSize, rowSize) transpose() {
        Mat!(T, colSize, rowSize) m;
        static foreach (i; 0 .. colSize) {
            static foreach (j; 0 .. rowSize) {
                m[j, i] = this[i, j];
            }
        }
        return m;
    }

    // TODO: Fix this!
    public Mat!(T, colSize, otherRowSize) mul(T, size_t otherRowSize, size_t otherColSize)
        (Mat!(T, otherRowSize, otherColSize) other) {
        Mat!(T, colSize, otherRowSize) m;
        T sum;
        static foreach (i; 0 .. colSize) {
            static foreach (j; 0 .. otherRowSize) {
                sum = 0;
                static foreach (k; 0 .. rowSize) {
                    sum += this[i, j] * other[k, j];
                }
                m[i, j] = sum;
            }
        }
        return m;
    }
}

// Aliases for common matrix types.
alias Mat2f = Mat!(float, 2, 2);
alias Mat3f = Mat!(float, 3, 3);
alias Mat4f = Mat!(float, 4, 4);

alias Mat2d = Mat!(double, 2, 2);
alias Mat3d = Mat!(double, 3, 3);
alias Mat4d = Mat!(double, 4, 4);

unittest {
    import std.stdio;

    auto m1 = Mat3d();
    assert(m1.data.length == 9);

    auto m2 = Mat!(double, 3, 2)([1, 2, 3, 0, -6, 7]);
    auto m3 = m2.transpose();
    assert(m3.data == [1, 0, 2, -6, 3, 7]);

    auto m4 = Mat2d([1, 2, 3, 4]);
    auto m5 = m4.mul(Mat2d([0, 1, 0, 0]));
    writeln(m5);
    // assert(m5.data == [0, 1, 0, 3]);
}