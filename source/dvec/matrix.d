module dvec.matrix;

import std.traits : isNumeric, isFloatingPoint;
import dvec.vector;
import std.stdio;

struct Mat(T, size_t rowCount, size_t colCount) if (isNumeric!T && rowCount > 1 && colCount > 1) {
    public T[rowCount * colCount] data;

    private size_t convertToIndex(size_t i, size_t j) {
        return colCount * i + j;
    }

    public T opIndex(size_t i, size_t j) {
        return data[convertToIndex(i, j)];
    }

    public void opIndexAssign(T value, size_t i, size_t j) {
        data[convertToIndex(i, j)] = value;
    }

    public Vec!(T, colCount) getRow(size_t row) {
        size_t idx = convertToIndex(row, 0);
        return Vec!(T, colCount)(data[idx .. idx + colCount]);
    }

    public void setRow(size_t row, Vec!(T, colCount) vector) {
        size_t idx = convertToIndex(row, 0);
        data[idx .. idx + colCount] = vector.data;
    }

    public Vec!(T, rowCount) getCol(size_t col) {
        Vec!(T, rowCount) v;
        static foreach (i; 0 .. rowCount) {
            v[i] = this[i, col];
        }
        return v;
    }

    public void setCol(size_t col, Vec!(T, rowCount) vector) {
        static foreach (i; 0 .. rowCount) {
            this[i, col] = vector[i];
        }
    }

    public void add(Mat!(T, rowCount, colCount) other) {
        static foreach (i; 0 .. data.length) data[i] += other.data[i];
    }

    public void sub(Mat!(T, rowCount, colCount) other) {
        static foreach (i; 0 .. data.length) data[i] -= other.data[i];
    }

    public void mul(T factor) {
        static foreach (i; 0 .. data.length) data[i] *= factor;
    }

    public void div(T factor) {
        static foreach (i; 0 .. data.length) data[i] /= factor;
    }

    public Mat!(T, colCount, rowCount) transpose() {
        Mat!(T, colCount, rowCount) m;
        static foreach (i; 0 .. rowCount) {
            static foreach (j; 0 .. colCount) {
                m[j, i] = this[i, j];
            }
        }
        return m;
    }

    public Mat!(T, rowCount, otherColCount) mul(T, size_t otherRowCount, size_t otherColCount)
        (Mat!(T, otherRowCount, otherColCount) other) {
        Mat!(T, rowCount, otherColCount) m;
        T sum;
        static foreach (i; 0 .. rowCount) {
            static foreach (j; 0 .. otherColCount) {
                sum = 0;
                static foreach (k; 0 .. colCount) {
                    sum += this[i, k] * other[k, j];
                }
                m[i, j] = sum;
            }
        }
        return m;
    }

    public Vec!(T, rowCount) mul(Vec!(T, colCount) vector) {
        Vec!(T, rowCount) result;
        T sum;
        static foreach (i; 0 .. rowCount) {
            sum = 0;
            static foreach (j; 0 .. colCount) {
                sum += this[i, j] * vector[j];
            }
            result[i] = sum;
        }
        return result;
    }

    public void rowSwitch(size_t rowI, size_t rowJ) {
        auto r = getRow(rowI);
        setRow(rowJ, r);
    }

    public void rowMultiply(size_t row, T factor) {
        size_t idx = convertToIndex(row, 0);
        static foreach (i; 0 .. colCount) {
            data[idx + i] *= factor;
        }
    }

    public void rowAdd(size_t rowI, T factor, size_t rowJ) {
        auto row = getRow(rowJ);
        row.mul(factor);
        setRow(rowI, row);
    }

    public Mat!(T, rowCount - n, colCount - m) subMatrix(size_t n, size_t m)(size_t[n] rows, size_t[m] cols) {
        // TODO: Improve efficiency with static stuff.
        Mat!(T, rowCount - n, colCount - m) sub;
        size_t subIdx = 0;
        foreach (idx; 0 .. data.length) {
            size_t row = idx / colCount;
            size_t col = idx % colCount;
            bool skip = false;
            foreach (r; rows) {
                if (r == row) {
                    skip = true;
                    break;
                }
            }
            if (!skip) {
                foreach (c; cols) {
                    if (c == col) {
                        skip = true;
                        break;
                    }
                }
            }
            if (!skip) {
                sub.data[subIdx++] = this[row, col];
            }
        }
        return sub;
    }

    static if (rowCount == colCount) {
        alias N = rowCount;

        public static Mat!(T, rowCount, colCount) identity() {
            Mat!(T, rowCount, colCount) m;
            static foreach (i; 0 .. rowCount) {
                static foreach (j; 0 .. colCount) {
                    m[i, j] = i == j ? 1 : 0;
                }
            }
            return m;
        }

        public T det() {
            // TODO: Implement determinant using Laplace expansion?
            return 0;
        }
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
    import dvec.vector;

    auto m1 = Mat3d();
    assert(m1.data.length == 9);

    auto m2 = Mat!(double, 2, 3)([1, 2, 3, 0, -6, 7]);
    auto m3 = m2.transpose();
    assert(m3.data == [1, 0, 2, -6, 3, 7]);

    auto m4 = Mat2d([1, 2, 3, 4]);
    assert(m4.getRow(0).data == [1, 2]);
    assert(m4.getRow(1).data == [3, 4]);
    assert(m4.getCol(0).data == [1, 3]);
    assert(m4.getCol(1).data == [2, 4]);
    auto m5 = m4.mul(Mat2d([0, 1, 0, 0]));
    assert(m5.data == [0, 1, 0, 3]);

    auto m6 = Mat2d.identity();
    assert(m6.data == [1, 0, 0, 1]);
    auto m7 = Mat3d.identity();
    assert(m7.data == [1, 0, 0, 0, 1, 0, 0, 0, 1]);

    auto m8 = Mat!(double, 2, 3)([1, -1, 2, 0, -3, 1]);
    Vec3d v1 = Vec3d(2, 1, 0);
    assert(m8.mul(v1).data == [1, -3]);

    auto m9 = Mat!(double, 3, 4)([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
    auto m10 = m9.subMatrix([2], [1]);
    assert(m10.data == [1, 3, 4, 5, 7, 8]);
}