/** 
 * This module contains the `Vec` templated struct representing vectors and
 * their operations.
 */
module dvec.vector;

import std.traits : isNumeric, isFloatingPoint;
import dvec.vector_types;

/** 
 * Generic struct that represents a vector holding `size` elements of type `T`.
 * A vector must contain at least 1 element, and has no upper-bound on the size
 * beyond restrictions imposed by the system.
 */
struct Vec(T, size_t size) if (isNumeric!T && size > 0) {
    /** 
     * A static contstant that can be used to get the size of the vector.
     */
    public static const size_t SIZE = size;

    /** 
     * The internal static array storing the elements of this vector.
     */
    public T[size] data;

    /** 
     * Internal alias to make template methods more readable. We can just say
     * `MY_TYPE` instead of `Vec!(T, size)` everywhere.
     */
    private alias MY_TYPE = Vec!(T, size);

    /** 
     * Constructs a vector from an array of elements.
     * Params:
     *   elements = The elements to put in the vector.
     */
    public this(T[size] elements) {
        static foreach (i; 0 .. size) data[i] = elements[i];
    }
    unittest {
        Vec3f v = Vec3f([1f, 2f, 3f]);
        assert(v.data == [1f, 2f, 3f]);
    }

    /** 
     * Constructs a vector from a variadic list of elements.
     * Params:
     *   elements = The elements to put in the vector.
     */
    public this(T[] elements...) {
        if (elements.length != size) assert(false, "Invalid number of elements provided to Vec constructor.");
        static foreach (i; 0 .. size) data[i] = elements[i];
    }
    unittest {
        Vec3i v = Vec3i(5, 4, 3);
        assert(v.data == [5, 4, 3]);
    }

    /** 
     * Constructs a vector where all elements have the given value.
     * Params:
     *   value = The value to assign to all elements in the vector.
     */
    public this(T value) {
        static foreach (i; 0 .. size) data[i] = value;
    }
    unittest {
        Vec2f v = Vec2f(1f);
        assert(v.data == [1f, 1f]);
        Vec!(float, 25) v2 = Vec!(float, 25)(3f);
        foreach (value; v2.data) {
            assert(value == 3f);
        }
    }

    /** 
     * Constructs a vector as a copy of the other.
     * Params:
     *   other = The vector to copy.
     */
    public this(MY_TYPE other) {
        this(other.data);
    }
    unittest {
        Vec2f vOriginal = Vec2f(5f, 16f);
        Vec2f vCopy = Vec2f(vOriginal);
        assert(vCopy.data == [5f, 16f]);
    }

    /** 
     * Constructs a vector containing all 0's.
     * Returns: An vector containing all 0's.
     */
    public static MY_TYPE empty() {
        MY_TYPE v;
        static foreach (i; 0 .. size) v[i] = 0;
        return v;
    }
    unittest {
        Vec4f v = Vec4f.empty();
        assert(v.data == [0f, 0f, 0f, 0f]);
    }

    /** 
     * Computes the sum of a given array of vectors.
     * Params:
     *   vectors = The list of vectors to compute the sum of.
     * Returns: The sum of all vectors.
     */
    public static MY_TYPE sum(MY_TYPE[] vectors) {
        MY_TYPE v = MY_TYPE(0);
        foreach (vector; vectors) v.add(vector);
        return v;
    }
    unittest {
        Vec2i v1 = Vec2i(1, 1);
        Vec2i v2 = Vec2i(2, 2);
        Vec2i v3 = Vec2i(3, 3);
        Vec2i v4 = Vec2i(-1, -4);
        assert(Vec2i.sum([v1, v2]) == v3);
        assert(Vec2i.sum([v1, v2, v3]) == Vec2i(6, 6));
        assert(Vec2i.sum([v3, v4]) == Vec2i(2, -1));
    }

    /** 
     * Gets a copy of this vector.
     * Returns: A copy of this vector.
     */
    public MY_TYPE copy() const {
        return MY_TYPE(this);
    }
    unittest {
        Vec3f v = Vec3f(0.5f, 1.0f, 0.75f);
        Vec3f vCopy = v.copy();
        assert(v.data == vCopy.data);
        v.data[0] = -0.5f;
        assert(vCopy.data[0] == 0.5f);
    }

    /** 
     * Gets the element at a specified index.
     * Params:
     *   i = The index of the element.
     * Returns: The element at the specified index.
     */
    public T opIndex(size_t i) const {
        return data[i];
    }
    unittest {
        Vec3f v = Vec3f(1f, 2f, 3f);
        assert(v[0] == 1f);
        assert(v[1] == 2f);
        assert(v[2] == 3f);
    }

    /** 
     * Inserts an element at the specified index.
     * Params:
     *   value = The value to assign.
     *   i = The index of the element.
     */
    public void opIndexAssign(T value, size_t i) {
        data[i] = value;
    }
    unittest {
        Vec3i v;
        assert(v[0] == 0);
        v[0] = 42;
        assert(v[0] == 42);
    }

    /** 
     * Adds the given vector to this one.
     * Params:
     *   other = The vector to add to this one.
     * Returns: A reference to this vector, for method chaining.
     */
    public ref MY_TYPE add(V)(Vec!(V, size) other) if (isNumeric!V) {
        static foreach (i; 0 .. size) data[i] += other[i];
        return this;
    }
    unittest {
        Vec3i v1 = Vec3i(1);
        Vec3i v2 = Vec3i(2);
        v1.add(v2);
        assert(v1.data == [3, 3, 3]);
        assert(v2.data == [2, 2, 2]);
    }

    /** 
     * Subtracts the given vector from this one.
     * Params:
     *   other = The vector to subtract from this one.
     * Returns: A reference to this vector, for method chaining.
     */
    public ref MY_TYPE sub(V)(Vec!(V, size) other) if (isNumeric!V) {
        static foreach (i; 0 .. size) data[i] -= other[i];
        return this;
    }
    unittest {
        Vec3i v1 = Vec3i(1);
        Vec3i v2 = Vec3i(2);
        v1.sub(v2);
        assert(v1.data == [-1, -1, -1]);
        assert(v2.data == [2, 2, 2]);
    }

    /** 
     * Multiplies this vector by a factor, element-wise.
     * Params:
     *   factor = The factor to multiply by.
     * Returns: A reference to this vector, for method chaining.
     */
    public ref MY_TYPE mul(V)(V factor) if (isNumeric!V) {
        static foreach (i; 0 .. size) data[i] *= factor;
        return this;
    }
    unittest {
        assert(Vec2i(2).mul(2).data == [4, 4]);
    }

    /** 
     * Multiplies this vector by another vector, element-wise.
     * Params:
     *   other = The other vector to multiply with.
     * Returns: A reference to this vector, for method chaining.
     */
    public ref MY_TYPE mul(V)(Vec!(V, size) other) if (isNumeric!V) {
        static foreach (i; 0 .. size) data[i] *= other[i];
        return this;
    }
    unittest {
        assert(Vec2i(1, 2).mul(Vec2i(3, 2)).data == [3, 4]);
    }

    /** 
     * Divides this vector by a factor, element-wise.
     * Params:
     *   factor = The factor to divide by.
     * Returns: A reference to this vector, for method chaining.
     */
    public ref MY_TYPE div(V)(V factor) if (isNumeric!V) {
        static foreach (i; 0 .. size) data[i] /= factor;
        return this;
    }
    unittest {
        assert(Vec2i(8).div(2).data == [4, 4]);
    }

    /** 
     * Divides this vector by another vector, element-wise.
     * Params:
     *   other = The other vector to divide with.
     * Returns: A reference to this vector, for method chaining.
     */
    public ref MY_TYPE div(V)(Vec!(V, size) other) if (isNumeric!V) {
        static foreach (i; 0 .. size) data[i] /= other[i];
        return this;
    }
    unittest {
        assert(Vec2i(8).div(Vec2i(2, 4)).data == [4, 2]);
    }

    /** 
     * Determines the squared magnitude of this vector.
     * Returns: The squared magnitude of this vector.
     */
    public double mag2() const {
        double sum = 0;
        static foreach (i; 0 .. size) sum += data[i] * data[i];
        return sum;
    }
    unittest {
        assert(Vec2i(2).mag2() == 8);
        assert(Vec2f(3f, 4f).mag2() == 5f * 5f);
    }

    /** 
     * Determines the magnitude of this vector.
     * Returns: The magnitude of this vector.
     */
    public double mag() const {
        import std.math : sqrt;
        return sqrt(mag2());
    }
    unittest {
        import std.math : sqrt;
        assert(Vec2i(1, 0).mag() == 1);
        assert(Vec2f(3f, 4f).mag() == 5f);
        assert(Vec2i(1, 1).mag() == sqrt(2.0));
    }

    /** 
     * Determines the [dot product](https://en.wikipedia.org/wiki/Dot_product)
     * of this vector and another vector.
     * Params:
     *   other = The other vector.
     * Returns: The dot product of the vectors.
     */
    public T dot(MY_TYPE other) const {
        T sum = 0;
        static foreach (i; 0 .. size) sum += data[i] * other[i];
        return sum;
    }
    unittest {
        assert(Vec3i(1, 3, -5).dot(Vec3i(4, -2, -1)) == 3);
        assert(Vec2f(1.0f, 0.0f).dot(Vec2f(0.0f, 1.0f)) == 0f);
        assert(Vec2f(1.0f, 0.0f).dot(Vec2f(1.0f, 0.0f)) == 1f);
        assert(Vec2f(1.0f, 0.0f).dot(Vec2f(-1.0f, 0.0f)) == -1f);
    }

    /** 
     * Adds two vectors.
     * Params:
     *   other = The other vector.
     * Returns: A vector representing the sum of this and the other.
     */
    public MY_TYPE opBinary(string op : "+", V)(Vec!(V, size) other) const if (isNumeric!V) {
        auto result = copy();
        result.add(other);
        return result;
    }
    unittest {
        assert(Vec2i(1) + Vec2i(3) == Vec2i(4));
    }

    /** 
     * Adds a scalar value to a vector, element-wise.
     * Params:
     *   scalar = The scalar value to add to the vector.
     * Returns: A vector representing the sum of this and the scalar value
     * applied to all elements.
     */
    public MY_TYPE opBinary(string op : "+", V)(V scalar) const if (isNumeric!V) {
        auto result = copy();
        result.add(Vec!(V, size)(scalar));
        return result;
    }
    unittest {
        assert(Vec2i(1) + 3 == Vec2i(4));
    }

    /** 
     * Adds a vector to this one.
     * Params:
     *   other = The other vector.
     * Returns: A reference to this vector.
     */
    public ref MY_TYPE opOpAssign(string op : "+", V)(Vec!(V, size) other) if (isNumeric!V) {
        this.add(other);
        return this;
    }
    unittest {
        Vec3i v = Vec3i(1, 2, 3);
        v += Vec3i(1);
        assert(v.data == [2, 3, 4]);
    }

    /** 
     * Adds a scalar value to this vector.
     * Params:
     *   scalar = The scalar value to add to the vector.
     * Returns: A reference to this vector.
     */
    public ref MY_TYPE opOpAssign(string op : "+", V)(V scalar) if (isNumeric!V) {
        this.add(Vec!(V, size)(scalar));
        return this;
    }
    unittest {
        Vec3i v = Vec3i(1, 2, 3);
        v += 2;
        assert(v.data == [3, 4, 5]);
    }

    // TODO: Add scalar operators for:
    // sub
    // mul
    // div
    // and non-operator overload methods for add, sub

    /** 
     * Subtracts two vectors.
     * Params:
     *   other = The other vector.
     * Returns: A vector representing the difference of this and the other.
     */
    public MY_TYPE opBinary(string op : "-", V)(Vec!(V, size) other) const if (isNumeric!V) {
        auto result = copy();
        result.sub(other);
        return result;
    }
    unittest {
        assert(Vec2i(4) - Vec2i(1) == Vec2i(3));
    }

    /** 
     * Subtracts a vector from this one.
     * Params:
     *   other = The other vector.
     * Returns: A reference to this vector.
     */
    public ref MY_TYPE opOpAssign(string op : "-", V)(Vec!(V, size) other) if (isNumeric!V) {
        this.sub(other);
        return this;
    }
    unittest {
        Vec3i v = Vec3i(1, 2, 3);
        v -= Vec3i(2);
        assert(v.data == [-1, 0, 1]);
    }

    /** 
     * Multiplies a vector by a factor.
     * Params:
     *   factor = The factor to multiply by.
     * Returns: The resultant vector.
     */
    public MY_TYPE opBinary(string op : "*", V)(V factor) const if (isNumeric!V) {
        auto result = copy();
        result.mul(factor);
        return result;
    }
    unittest {
        assert(Vec2f(0.5f) * 2f == Vec2f(1.0f));
    }

    /** 
     * Multiplies this vector by a factor.
     * Params:
     *   factor = The factor to multiply by.
     * Returns: A reference to this vector.
     */
    public ref MY_TYPE opOpAssign(string op : "*", V)(V factor) if (isNumeric!V) {
        this.mul(factor);
        return this;
    }
    unittest {
        Vec2f v = Vec2f(2f);
        v *= 2f;
        assert(v.data == [4f, 4f]);
    }

    /** 
     * Divides a vector by a factor.
     * Params:
     *   factor = The factor to divide by.
     * Returns: The resultant vector.
     */
    public MY_TYPE opBinary(string op : "/", V)(V factor) const if (isNumeric!V) {
        auto result = copy();
        result.div(factor);
        return result;
    }
    unittest {
        assert(Vec2f(8f) / 4f == Vec2f(2f));
    }

    /** 
     * Divides this vector by a factor.
     * Params:
     *   factor = The factor to divide by.
     * Returns: A reference to this vector.
     */
    public ref MY_TYPE opOpAssign(string op : "/", V)(V factor) if (isNumeric!V) {
        this.div(factor);
        return this;
    }
    unittest {
        Vec2f v = Vec2f(2f, 4f);
        v /= 4f;
        assert(v.data == [0.5f, 1f]);
    }

    /** 
     * Compares this vector to another, based on their magnitudes.
     * Params:
     *   other = The vector to compare to.
     * Returns: 0 if the vectors have equal magnitude, 1 if this vector's
     * magnitude is bigger, and -1 if the other's is bigger.
     */
    public int opCmp(MY_TYPE other) const {
        double a = this.mag2();
        double b = other.mag2();
        if (a == b) return 0;
        if (a < b) return -1;
        return 1;
    }
    unittest {
        Vec3i v1 = Vec3i(1);
        Vec3i v2 = Vec3i(2);
        Vec3i v3 = Vec3i(3);
        assert(v1 == v1);
        assert(v1 != v2);
        assert(v1 < v2);
        assert(v2 > v1);
        assert(v3 > v2);
    }

    /** 
     * Gets a simple string representation of this vector.
     * Returns: The string representation of this vector.
     */
    public string toString() const {
        import std.array : appender;
        import std.conv : to;
        auto s = appender!string;
        s ~= "[";
        static foreach (i; 0 .. size - 1) {
            s ~= data[i].to!string;
            s ~= ", ";
        }
        s ~= data[size - 1].to!string;
        s ~= "]";
        return s[];
    }

    static if (isFloatingPoint!T) {
        /** 
         * [Normalizes](https://en.wikipedia.org/wiki/Unit_vector) this vector,
         * such that it will have a magnitude of 1.
         * Returns: A reference to this vector, for method chaining.
         */
        public ref MY_TYPE norm() {
            const double mag = mag();
            static foreach (i; 0 .. size) {
                data[i] /= mag;
            }
            return this;
        }
    }

    static if (isFloatingPoint!T && size == 2) {
        /** 
         * Converts this 2-dimensional vector from [Cartesian](https://en.wikipedia.org/wiki/Cartesian_coordinate_system)
         * to [Polar](https://en.wikipedia.org/wiki/Polar_coordinate_system)
         * coordinates. It is assumed that the first element is the **x**
         * coordinate, and the second element is the **y** coordinate. The
         * first element becomes the **radius** and the second becomes the
         * angle **theta**.
         * Returns: A reference to this vector, for method chaining.
         */
        public ref MY_TYPE toPolar() {
            import std.math : atan2;
            T radius = mag();
            T angle = atan2(data[1], data[0]);
            data[0] = radius;
            data[1] = angle;
            return this;
        }

        /** 
         * Converts this 2-dimensional vector from [Polar](https://en.wikipedia.org/wiki/Polar_coordinate_system)
         * to [Cartesian](https://en.wikipedia.org/wiki/Cartesian_coordinate_system)
         * coordinates. It is assumed that the first element is the **radius**
         * and the second element is the angle **theta**. The first element
         * becomes the **x** coordinate, and the second becomes the **y**
         * coordinate.
         * Returns: A reference to this vector, for method chaining.
         */
        public ref MY_TYPE toCartesian() {
            import std.math : cos, sin;
            T x = data[0] * cos(data[1]);
            T y = data[0] * sin(data[1]);
            data[0] = x;
            data[1] = y;
            return this;
        }
    }

    static if (isFloatingPoint!T && size == 3) {
        /** 
         * Computes the [cross product](https://en.wikipedia.org/wiki/Cross_product) of this vector and another, and stores
         * the result in this vector.
         * Params:
         *   other = The other vector.
         * Returns: A reference to this vector, for method chaining.
         */
        public ref MY_TYPE cross(MY_TYPE other) {
            MY_TYPE tmp;
            tmp[0] = data[1] * other[2] - data[2] * other[1];
            tmp[1] = data[2] * other[0] - data[0] * other[2];
            tmp[2] = data[0] * other[1] - data[1] * other[0];
            data[0] = tmp[0];
            data[1] = tmp[1];
            data[2] = tmp[2];
            return this;
        }
    }
}

unittest {
    import std.stdio;
    import std.math;

    void assertFP(double actual, double expected, double delta = 1e-06, string msg = "Assertion failed.") {
        double lowBound = expected - delta;
        double highBound = expected + delta;
        assert(actual > lowBound && actual < highBound, msg);
    }

    // Test floating-point specific methods.
    auto v6 = Vec2f(3, 3);
    v6.norm();
    assertFP(v6.mag, 1);
    assertFP(v6[0], sqrt(2f) / 2f);
    v6 = Vec2f(1, 0);
    auto v6Copy = Vec2f(v6);
    v6.norm();
    assert(v6.mag == 1);
    assert(v6.data == v6Copy.data);

    // Test toPolar
    auto vCart = Vec2d(1, 0);
    vCart.toPolar();
    assert(vCart.data == [1.0, 0.0]);
    vCart.toCartesian();
    assert(vCart.data == [1.0, 0.0]);
    vCart = Vec2d(1, 1);
    vCart.toPolar();
    assertFP(vCart[0], sqrt(2f));
    assertFP(vCart[1], PI_4);
    vCart.toCartesian();
    assertFP(vCart[0], 1);
    assertFP(vCart[1], 1);
    vCart = Vec2d(-1, 1);
    vCart.toPolar();
    assertFP(vCart[0], sqrt(2f));
    assertFP(vCart[1], 3 * PI_4);
}