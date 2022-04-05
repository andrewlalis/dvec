module dvec.matrix;

import std.traits : isNumeric, isFloatingPoint;
import dvec.vector;

/** 
 * Generic struct that represents a matrix with `rowCount` rows and `colCount`
 * columns, holding elements of type `T`. A matrix must be at least 1x1.
 */
struct Mat(T, size_t rowCount, size_t colCount) if (isNumeric!T && rowCount > 0 && colCount > 0) {
    public static const size_t WIDTH = colCount;
    public static const size_t HEIGHT = rowCount;

    /** 
     * The internal static array storing the elements in row-major form.
     */
    public T[rowCount * colCount] data;

    /** 
     * Constructs a matrix from the given elements.
     * Params:
     *   elements = The elements to place in the matrix. Should be in row-major
     *              form.
     */
    public this(T[rowCount * colCount] elements) {
        data[0 .. $] = elements[0 .. $];
    }

    /** 
     * Constructs a matrix from the given elements.
     * Params:
     *   elements = The elements to place in the matrix. Should be in row-major
     *              form.
     */
    public this(T[] elements...) {
        data[0 .. $] = elements[0 .. $];
    }

    /** 
     * Constructs a matrix from the given 2-dimensional array.
     * Params:
     *   elements = The elements to place in the matrix.
     */
    public this(T[colCount][rowCount] elements) {
        static foreach (i; 0 .. rowCount) {
            static foreach (j; 0 .. colCount) {
                this[i, j] = elements[i][j];
            }
        }
    }

    /** 
     * Constructs a matrix as a copy of another.
     * Params:
     *   other = The matrix to copy.
     */
    public this(Mat!(T, rowCount, colCount) other) {
        data[0 .. data.length] = other.data[0 .. data.length];
    }

    /** 
     * Constructs a matrix with all elements initialized to the given value.
     * Params:
     *   value = The value to set all elements to.
     */
    public this(T value) {
        static foreach (i; 0 .. data.length) data[i] = value;
    }

    /** 
     * Helper method to convert a 2-dimensional `[i, j]` index into a
     * 1-dimensional `[i]` index.
     * Params:
     *   i = The row number.
     *   j = The column number.
     * Returns: A 1-dimensional index.
     */
    private static size_t convertToIndex(size_t i, size_t j) {
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

    /** 
     * Computes the matrix multiplication of `this * other`.
     * Params:
     *   other = The matrix to multiply with this one.
     * Returns: The resultant matrix.
     */
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

    /** 
     * Multiplies a vector against this matrix.
     * Params:
     *   vector = The vector to multiply.
     * Returns: The resultant transformed vector.
     */
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

    public Mat!(T, rowCount - n, colCount - m) subMatrix(size_t n, size_t m)(size_t[n] rows, size_t[m] cols)
        if (rowCount - n > 0 && colCount - m > 0) {
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

    // Special methods for square matrices.
    static if (rowCount == colCount) {
        alias N = rowCount;

        public static Mat!(T, N, N) identity() {
            Mat!(T, N, N) m;
            static foreach (i; 0 .. N) {
                static foreach (j; 0 .. N) {
                    m[i, j] = i == j ? 1 : 0;
                }
            }
            return m;
        }

        public T det() {
            static if (N == 1) {
                return data[0];
            } else static if (N == 2) {
                return data[0] * data[3] - data[1] * data[2];
            } else {
                // Laplace expansion, taking i = 0.
                T sum = 0;
                static foreach (j; 0 .. N) {
                    sum += (j % 2 == 0 ? 1 : -1) * this[0, j] * this.subMatrix([0], [j]).det();
                }
                return sum;
            }
        }

        public bool invertible() {
            return det() != 0;
        }

        public Mat!(T, N, N) cofactor() {
            static if (N == 1) {
                return Mat!(T, N, N)(data[0]);
            } else {
                Mat!(T, N, N) c;
                static foreach (i; 0 .. N) {
                    static foreach (j; 0 .. N) {
                        c[i, j] = ((i + j) % 2 == 0 ? 1 : -1) * this.subMatrix([i], [j]).det();
                    }
                }
                return c;
            }
        }

        public Mat!(T, N, N) adjugate() {
            return cofactor().transpose();
        }

        public Mat!(T, N, N) inv() {
            auto m = adjugate();
            m.div(det());
            return m;
        }

        // Special case for 3x3 floating-point matrices: linear transformations
        static if (N == 3 && isFloatingPoint!T) {
            public void rotate(T theta) {
                import std.math : cos, sin;
                this = mul(Mat!(T, N, N)(
                    cos(theta), -sin(theta), 0,
                    sin(theta), cos(theta), 0,
                    0, 0, 1
                ));
            }

            public void translate(T dx, T dy) {
                this = mul(Mat!(T, N, N)(
                    1, 0, dx,
                    0, 1, dy,
                    0, 0, 1
                ));
            }

            public void scale(T sx, T sy) {
                this = mul(Mat!(T, N, N)(
                    sx, 0,  0,
                    0,  sy, 0,
                    0,  0,  1
                ));
            }

            public void scale(T s) {
                scale(s, s);
            }

            public void shear(T sx, T sy) {
                this = mul(Mat!(T, N, N)(
                    1,  sx, 0,
                    sy, 1,  0,
                    0,  0,  1
                ));
            }

            public Vec!(T, 2) map(Vec!(T, 2) v) {
                Vec!(T, 3) v1 = this.mul(Vec!(T, 3)(v[0], v[1], 1));
                return Vec!(T, 2)(v1[0], v1[1]);
            }
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

    assert(Mat2d([[1, 2], [3, 4]]).data == [1, 2, 3, 4]);
    assert(Mat!(double, 2, 3)([[1, 2, 3], [-1, -2, -3]]).data == [1, 2, 3, -1, -2, -3]);

    auto m6 = Mat2d.identity();
    assert(m6.data == [1, 0, 0, 1]);
    auto m7 = Mat3d.identity();
    assert(m7.data == [1, 0, 0, 0, 1, 0, 0, 0, 1]);

    auto m8 = Mat!(double, 2, 3)([1, -1, 2, 0, -3, 1]);
    Vec3d v1 = Vec3d(2, 1, 0);
    assert(m8.mul(v1).data == [1, -3]);

    Vec3f p = Vec3f(0, 0, 1);
    Mat3f tx = Mat3f([
        [1, 0, 42],
        [0, 1, 64],
        [0, 0, 1]
    ]);
    auto transformed = tx.mul(p);
    assert(transformed.data == [42, 64, 1]);

    auto p2 = Vec2f(0, 0);
    auto tx2 = Mat3f.identity();
    tx2.translate(42, 64);
    auto transformed2 = tx2.map(p2);
    assert(transformed2.data == [42, 64]);

    auto m9 = Mat!(double, 3, 4)([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
    auto m10 = m9.subMatrix([2], [1]);
    assert(m10.data == [1, 3, 4, 5, 7, 8]);

    assert(Mat2d([3, 7, 1, -4]).det == -19);
    assert(Mat2d([1, 2, 3, 4]).det == -2);
    assert(Mat3d([1, 2, 3, 4, 5, 6, 7, 8, 9]).det == 0);

    assert(Mat2d.identity().inv() == Mat2d.identity());
    assert(Mat3f.identity().inv() == Mat3f.identity());
    assert(Mat2d(4, 7, 2, 6).inv() == Mat2d(0.6, -0.7, -0.2, 0.4));
    assert(Mat2d(-3, 1, 5, -2).inv() == Mat2d(-2, -1, -5, -3));
    assert(Mat3d(1, 3, 3, 1, 4, 3, 1, 3, 4).inv() == Mat3d(7, -3, -3, -1, 1, 0, -1, 0, 1));
}