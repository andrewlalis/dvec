/** 
 * This module contains the `Mat` templated struct representing matrices and
 * their operations.
 */
module dvec.matrix;

import std.traits : isNumeric, isFloatingPoint;
import dvec.vector;
import dvec.vector_types;

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
        setData(elements);
    }

    /** 
     * Constructs a matrix from the given elements.
     * Params:
     *   elements = The elements to place in the matrix. Should be in row-major
     *              form.
     */
    public this(T[] elements...) {
        data[0 .. $] = elements[0 .. data.length];
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
        setData(other.data);
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

    /** 
     * Gets the value at a specified location in the matrix. For example,
     * with a `Mat!(float, 2, 2) m`, we can say `float v = m[0, 1];`
     * Params:
     *   i = The row number, starting from 0.
     *   j = The column number, starting from 0.
     * Returns: The value at the specified location.
     */
    public T opIndex(size_t i, size_t j) const {
        return data[convertToIndex(i, j)];
    }

    /** 
     * Sets the value at a specified location in the matrix.
     * Params:
     *   value = The value to assign.
     *   i = The row number, starting from 0.
     *   j = The column number, starting from 0.
     */
    public void opIndexAssign(T value, size_t i, size_t j) {
        data[convertToIndex(i, j)] = value;
    }

    /** 
     * Gets a specified row as a vector.
     * Params:
     *   row = The row number, starting from 0.
     * Returns: The row.
     */
    public Vec!(T, colCount) getRow(size_t row) {
        size_t idx = convertToIndex(row, 0);
        return Vec!(T, colCount)(data[idx .. idx + colCount]);
    }

    /** 
     * Sets a specified row to the given vector of elements.
     * Params:
     *   row = The row number, starting from 0.
     *   vector = The elements to set in the row.
     * Returns: A reference to this matrix, for method chaining.
     */
    public ref Mat!(T, rowCount, colCount) setRow(size_t row, Vec!(T, colCount) vector) {
        size_t idx = convertToIndex(row, 0);
        data[idx .. idx + colCount] = vector.data;
        return this;
    }

    /** 
     * Gets a specified column as a vector.
     * Params:
     *   col = The column number, starting from 0.
     * Returns: The column.
     */
    public Vec!(T, rowCount) getCol(size_t col) const {
        Vec!(T, rowCount) v;
        static foreach (i; 0 .. rowCount) {
            v[i] = this[i, col];
        }
        return v;
    }

    /** 
     * Sets a specified column to the given vector of elements.
     * Params:
     *   col = The column number, starting from 0.
     *   vector = The elements to set in the column.
     * Returns: A reference to this matrix, for method chaining.
     */
    public ref Mat!(T, rowCount, colCount) setCol(size_t col, Vec!(T, rowCount) vector) {
        static foreach (i; 0 .. rowCount) {
            this[i, col] = vector[i];
        }
        return this;
    }

    /** 
     * Sets all elements of this matrix using the given elements.
     * Params:
     *   elements = The elements to set.
     * Returns: A reference to this matrix, for method chaining.
     */
    public ref Mat!(T, rowCount, colCount) setData(T[rowCount * colCount] elements) {
        data[0 .. $] = elements[0 .. $];
        return this;
    }

    /** 
     * Gets a copy of this matrix.
     * Returns: A copy of this matrix.
     */
    public Mat!(T, rowCount, colCount) copy() const {
        return Mat!(T, rowCount, colCount)(this);
    }

    /** 
     * Adds a given matrix to this one.
     * Params:
     *   other = The other matrix to add to this one.
     * Returns: A reference to this matrix, for method chaining.
     */
    public ref Mat!(T, rowCount, colCount) add(Mat!(T, rowCount, colCount) other) {
        static foreach (i; 0 .. data.length) data[i] += other.data[i];
        return this;
    }

    /** 
     * Subtracts a given matrix from this one.
     * Params:
     *   other = The other matrix to subtract from this one.
     * Returns: A reference to this matrix, for method chaining.
     */
    public ref Mat!(T, rowCount, colCount) sub(Mat!(T, rowCount, colCount) other) {
        static foreach (i; 0 .. data.length) data[i] -= other.data[i];
        return this;
    }

    /** 
     * Multiplies this matrix by a factor.
     * Params:
     *   factor = The factor to muliply by.
     * Returns: A reference to this matrix, for method chaining.
     */
    public ref Mat!(T, rowCount, colCount) mul(T factor) {
        static foreach (i; 0 .. data.length) data[i] *= factor;
        return this;
    }

    /** 
     * Divides this matrix by a factor.
     * Params:
     *   factor = The factor to divide by.
     * Returns: A reference to this matrix, for method chaining.
     */
    public ref Mat!(T, rowCount, colCount) div(T factor) {
        static foreach (i; 0 .. data.length) data[i] /= factor;
        return this;
    }

    /** 
     * Gets the [transpose](https://en.wikipedia.org/wiki/Transpose) of this
     * matrix, and stores it in this matrix.
     * Returns: A reference to this matrix, for method chaining.
     */
    public ref Mat!(T, rowCount, colCount) transpose() {
        Mat!(T, colCount, rowCount) m;
        static foreach (i; 0 .. rowCount) {
            static foreach (j; 0 .. colCount) {
                m[j, i] = this[i, j];
            }
        }
        return setData(m.data);
    }

    /** 
     * Computes the [matrix multiplication](https://en.wikipedia.org/wiki/Matrix_multiplication)
     * of `this * other`.
     * Params:
     *   other = The matrix to multiply with this one.
     * Returns: A new matrix of size `this.rowCount x other.colCount`.
     */
    public Mat!(T, rowCount, otherColCount) mul(T, size_t otherRowCount, size_t otherColCount)
        (Mat!(T, otherRowCount, otherColCount) other) const {
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
    public Vec!(T, rowCount) mul(Vec!(T, colCount) vector) const {
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

    /** 
     * Switches two rows in this matrix.
     * Params:
     *   rowI = A row to swap, starting from 0.
     *   rowJ = A row to swap, starting from 0.
     * Returns: A reference to this matrix, for method chaining.
     */
    public ref Mat!(T, rowCount, colCount) rowSwitch(size_t rowI, size_t rowJ) {
        auto r = getRow(rowI);
        setRow(rowI, getRow(rowJ));
        setRow(rowJ, r);
        return this;
    }

    /** 
     * Multiplies a row by a factor.
     * Params:
     *   row = The row number, starting from 0.
     *   factor = The factor to multiply by.
     * Returns: A reference to this matrix, for method chaining.
     */
    public ref Mat!(T, rowCount, colCount) rowMultiply(size_t row, T factor) {
        size_t idx = convertToIndex(row, 0);
        static foreach (i; 0 .. colCount) {
            data[idx + i] *= factor;
        }
        return this;
    }

    /** 
     * Adds a row, multiplied by a factor, to another row.
     * Params:
     *   rowI = The row number to add to.
     *   factor = The factor to multiply `rowJ` by.
     *   rowJ = The row to add to `rowI`.
     * Returns: A reference to this matrix, for method chaining.
     */
    public ref Mat!(T, rowCount, colCount) rowAdd(size_t rowI, T factor, size_t rowJ) {
        auto row = getRow(rowJ);
        row.mul(factor);
        setRow(rowI, row);
        return this;
    }

    /** 
     * Gets a submatrix of this matrix, with the given rows and columns removed.
     * Params:
     *   rows = The set of rows to remove.
     *   cols = The set of columns to remove.
     * Returns: A matrix with the given rows and columns removed.
     */
    public Mat!(T, rowCount - n, colCount - m) subMatrix(size_t n, size_t m)(size_t[n] rows, size_t[m] cols) const
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

    /** 
     * Converts this matrix to a string.
     * Returns: A string representation of the matrix.
     */
    public string toString() const {
        import std.conv : to;
        import std.algorithm : max;
        import std.array : appender, replicate;
        string[data.length] values;
        size_t[colCount] columnWidths;
        foreach (i; 0 .. data.length) {
            values[i] = data[i].to!string;
            size_t colIdx = i % colCount;
            columnWidths[colIdx] = max(columnWidths[colIdx], values[i].length + 1);
        }
        auto s = appender!string;
        foreach (r; 0 .. rowCount) {
            s ~= "| ";
            foreach (c; 0 .. colCount) {
                size_t idx = convertToIndex(r, c);
                size_t padAmount = columnWidths[c] - values[idx].length;
                string padding = replicate(" ", padAmount);
                s ~= padding ~ values[idx];
                if (c < colCount - 1) s ~= ", ";
            }
            s ~= " |";
            if (r < rowCount - 1) s ~= "\n";
        }
        return s[];
    }

    // Special methods for square matrices.
    static if (rowCount == colCount) {
        alias N = rowCount;

        /** 
         * Gets an [identity matrix](https://en.wikipedia.org/wiki/Identity_matrix).
         * Returns: An identity matrix.
         */
        public static Mat!(T, N, N) identity() {
            Mat!(T, N, N) m;
            static foreach (i; 0 .. N) {
                static foreach (j; 0 .. N) {
                    m[i, j] = i == j ? 1 : 0;
                }
            }
            return m;
        }

        /** 
         * Gets the [determinant](https://en.wikipedia.org/wiki/Determinant)
         * of this matrix.
         * Returns: The determinant of this matrix.
         */
        public T det() const {
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

        /** 
         * Determines if this matrix is invertible, which simply means a
         * non-zero determinant.
         * Returns: True if this matrix is invertible.
         */
        public bool invertible() const {
            return det() != 0;
        }

        /** 
         * Gets a [cofactor matrix](https://en.wikipedia.org/wiki/Minor_(linear_algebra)#Cofactor_expansion_of_the_determinant).
         * Returns: A reference to this matrix, for method chaining.
         */
        public ref Mat!(T, N, N) cofactor() {
            static if (N > 1) {
                Mat!(T, N, N) c;
                static foreach (i; 0 .. N) {
                    static foreach (j; 0 .. N) {
                        c[i, j] = ((i + j) % 2 == 0 ? 1 : -1) * this.subMatrix([i], [j]).det();
                    }
                }
                setData(c.data);
            }
            return this;
        }

        /** 
         * Gets an [adjugate matrix](https://en.wikipedia.org/wiki/Adjugate_matrix).
         * Returns: A reference to this matrix, for method chaining.
         */
        public ref Mat!(T, N, N) adjugate() {
            cofactor();
            transpose();
            return this;
        }

        /** 
         * Gets the inverse of this matrix.
         * Returns: A reference to this matrix, for method chaining.
         */
        public ref Mat!(T, N, N) inv() {
            T d = det();
            adjugate();
            div(d);
            return this;
        }

        // Special case for 3x3 floating-point matrices: linear transformations
        static if (N == 3 && isFloatingPoint!T) {
            /** 
             * Applies a 2D rotation to this matrix.
             * Params:
             *   theta = The angle in radians.
             * Returns: A reference to this matrix, for method chaining.
             */
            public ref Mat!(T, N, N) rotate(T theta) {
                import std.math : cos, sin;
                this = mul(Mat!(T, N, N)(
                    cos(theta), -sin(theta), 0,
                    sin(theta), cos(theta),  0,
                    0,          0,           1
                ));
                return this;
            }

            /** 
             * Applies a 2D translation to this matrix.
             * Params:
             *   dx = The translation on the x-axis.
             *   dy = The translation on the y-axis.
             * Returns: A reference to this matrix, for method chaining.
             */
            public ref Mat!(T, N, N) translate(T dx, T dy) {
                this = mul(Mat!(T, N, N)(
                    1, 0, dx,
                    0, 1, dy,
                    0, 0, 1
                ));
                return this;
            }

            /** 
             * Applies a 2D scaling to this matrix.
             * Params:
             *   sx = The scale factor on the x-axis.
             *   sy = The scale factor on the y-axis.
             * Returns: A reference to this matrix, for method chaining.
             */
            public ref Mat!(T, N, N) scale(T sx, T sy) {
                this = mul(Mat!(T, N, N)(
                    sx, 0,  0,
                    0,  sy, 0,
                    0,  0,  1
                ));
                return this;
            }

            /** 
             * Applies a uniform 2D scaling to this matrix on all axes.
             * Params:
             *   s = The scale factor to apply.
             * Returns: A reference to this matrix, for method chaining.
             */
            public ref Mat!(T, N, N) scale(T s) {
                return scale(s, s);
            }

            /** 
             * Applies a 2D shear to this matrix.
             * Params:
             *   sx = The shear factor on the x-axis.
             *   sy = The shear factor on the y-axis.
             * Returns: A reference to this matrix, for method chaining.
             */
            public ref Mat!(T, N, N) shear(T sx, T sy) {
                this = mul(Mat!(T, N, N)(
                    1,  sx, 0,
                    sy, 1,  0,
                    0,  0,  1
                ));
                return this;
            }

            /** 
             * Maps the given 2D vector using this matrix.
             * Params:
             *   v = The vector to map.
             * Returns: The resultant vector.
             */
            public Vec!(T, 2) map(Vec!(T, 2) v) {
                Vec!(T, 3) v1 = this.mul(Vec!(T, 3)(v[0], v[1], 1));
                return Vec!(T, 2)(v1[0], v1[1]);
            }
        }

        // Special case for 4x4 floating-point matrices: linear transformations
        static if (N == 4 && isFloatingPoint!T) {
            /** 
             * Applies a 3D translation to this matrix.
             * Params:
             *   dx = The translation on the x-axis.
             *   dy = The translation on the y-axis.
             *   dz = The translation on the z-axis.
             * Returns: A reference to this matrix, for method chaining.
             */
            public ref Mat!(T, N, N) translate(T dx, T dy, T dz) {
                this = mul(Mat!(T, N, N)(
                    1, 0, 0, dx,
                    0, 1, 0, dy,
                    0, 0, 1, dz,
                    0, 0, 0, 1
                ));
                return this;
            }

            /** 
             * Applies a 3D scaling to this matrix.
             * Params:
             *   sx = The scale factor on the x-axis.
             *   sy = The scale factor on the y-axis.
             *   sz = The scale factor on the z-axis.
             * Returns: A reference to this matrix, for method chaining.
             */
            public ref Mat!(T, N, N) scale(T sx, T sy, T sz) {
                this = mul(Mat!(T, N, N)(
                    sx, 0,  0,  0,
                    0,  sy, 0,  0,
                    0,  0,  sz, 0,
                    0,  0,  0,  1
                ));
                return this;
            }

            /** 
             * Applies a uniform 3D scaling to this matrix on all axes.
             * Params:
             *   s = The scale factor to apply.
             * Returns: A reference to this matrix, for method chaining.
             */
            public ref Mat!(T, N, N) scale(T s) {
                return scale(s, s, s);
            }

            /** 
             * Applies a rotation to this matrix about the x-axis.
             * Params:
             *   theta = The angle in radians.
             * Returns: A reference to this matrix, for method chaining.
             */
            public ref Mat!(T, N, N) rotateX(T theta) {
                import std.math : cos, sin;
                this = mul(Mat!(T, N, N)(
                    1, 0,          0,           0,
                    0, cos(theta), -sin(theta), 0,
                    0, sin(theta), cos(theta),  0,
                    0, 0,          0,           1
                ));
                return this;
            }

            /** 
             * Applies a rotation to this matrix about the y-axis.
             * Params:
             *   theta = The angle in radians.
             * Returns: A reference to this matrix, for method chaining.
             */
            public ref Mat!(T, N, N) rotateY(T theta) {
                import std.math : cos, sin;
                this = mul(Mat!(T, N, N)(
                    cos(theta),  0, sin(theta), 0,
                    0,           1, 0,          0,
                    -sin(theta), 0, cos(theta), 0,
                    0,           0, 0,          1
                ));
                return this;
            }

            /** 
             * Applies a rotation to this matrix about the z-axis.
             * Params:
             *   theta = The angle in radians.
             * Returns: A reference to this matrix, for method chaining.
             */
            public ref Mat!(T, N, N) rotateZ(T theta) {
                import std.math : cos, sin;
                this = mul(Mat!(T, N, N)(
                    cos(theta), -sin(theta), 0, 0,
                    sin(theta), cos(theta),  0, 0,
                    0,          0,           1, 0,
                    0,          0,           0, 1
                ));
                return this;
            }

            /** 
             * Applies a 3D rotation to this matrix about the x, y, and then z
             * axes.
             * Params:
             *   x = The angle to rotate about the x-axis.
             *   y = The angle to rotate about the y-axis.
             *   z = The angle to rotate about the z-axis.
             * Returns: A reference to this matrix, for method chaining.
             */
            public ref Mat!(T, N, N) rotate(T x, T y, T z) {
                rotateX(x);
                rotateY(y);
                rotateZ(z);
                return this;
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
    assert(m2.transpose.data == [1, 0, 2, -6, 3, 7]);

    auto m4 = Mat2d([1, 2, 3, 4]);
    assert(m4.getRow(0).data == [1, 2]);
    assert(m4.getRow(1).data == [3, 4]);
    assert(m4.getCol(0).data == [1, 3]);
    assert(m4.getCol(1).data == [2, 4]);
    auto m5 = m4.mul(Mat2d([0, 1, 0, 0]));
    assert(m5.data == [0, 1, 0, 3]);

    assert(Mat2d([[1, 2], [3, 4]]).data == [1, 2, 3, 4]);
    assert(Mat!(double, 2, 3)([[1, 2, 3], [-1, -2, -3]]).data == [1, 2, 3, -1, -2, -3]);

    assert(Mat2d.identity.data == [1, 0, 0, 1]);
    assert(Mat3d.identity.data == [1, 0, 0, 0, 1, 0, 0, 0, 1]);

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

    auto m9 = Mat!(double, 3, 4)([
        1, 2, 3, 4,
        5, 6, 7, 8,
        9, 10, 11, 12
    ]);
    auto m10 = m9.subMatrix([2], [1]);
    assert(m10.data == [
        1, 3, 4,
        5, 7, 8
    ]);
    assert(m10.subMatrix(cast(size_t[])[], [0]).data == [
        3, 4,
        7, 8
    ]);

    assert(Mat2d([3, 7, 1, -4]).det == -19);
    assert(Mat2d([1, 2, 3, 4]).det == -2);
    assert(Mat3d([1, 2, 3, 4, 5, 6, 7, 8, 9]).det == 0);

    assert(Mat2d.identity.inv() == Mat2d.identity());
    assert(Mat3f.identity.inv() == Mat3f.identity());
    assert(Mat2d(4, 7, 2, 6).inv() == Mat2d(0.6, -0.7, -0.2, 0.4));
    assert(Mat2d(-3, 1, 5, -2).inv() == Mat2d(-2, -1, -5, -3));
    assert(Mat3d(1, 3, 3, 1, 4, 3, 1, 3, 4).inv() == Mat3d(7, -3, -3, -1, 1, 0, -1, 0, 1));
}