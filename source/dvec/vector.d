module dvec.vector;

import std.traits : isNumeric, isFloatingPoint;

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
     * Constructs a vector from an array of elements.
     * Params:
     *   elements = The elements to put in the vector.
     */
    public this(T[size] elements) {
        static foreach (i; 0 .. size) data[i] = elements[i];
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

    /** 
     * Constructs a vector where all elements have the given value.
     * Params:
     *   value = The value to assign to all elements in the vector.
     */
    public this(T value) {
        static foreach (i; 0 .. size) data[i] = value;
    }

    /** 
     * Constructs a vector as a copy of the other.
     * Params:
     *   other = The vector to copy.
     */
    public this(Vec!(T, size) other) {
        this(other.data);
    }

    /** 
     * Constructs a vector containing all 0's.
     * Returns: An vector containing all 0's.
     */
    public static Vec!(T, size) empty() {
        Vec!(T, size) v;
        static foreach (i; 0 .. size) v[i] = 0;
        return v;
    }

    /** 
     * Computes the sum of a given array of vectors.
     * Params:
     *   vectors = The list of vectors to compute the sum of.
     * Returns: The sum of all vectors.
     */
    public static Vec!(T, size) sum(Vec!(T, size)[] vectors) {
        Vec!(T, size) v = Vec!(T, size)(0);
        foreach (vector; vectors) v.add(vector);
        return v;
    }

    /** 
     * Gets a copy of this vector.
     * Returns: A copy of this vector.
     */
    public Vec!(T, size) copy() const {
        return Vec!(T, size)(this);
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

    /** 
     * Inserts an element at the specified index.
     * Params:
     *   value = The value to assign.
     *   i = The index of the element.
     */
    public void opIndexAssign(T value, size_t i) {
        data[i] = value;
    }

    /** 
     * Adds the given vector to this one.
     * Params:
     *   other = The vector to add to this one.
     * Returns: A reference to this vector, for method chaining.
     */
    public ref Vec!(T, size) add(V)(Vec!(V, size) other) if (isNumeric!V) {
        static foreach (i; 0 .. size) data[i] += other[i];
        return this;
    }

    /** 
     * Subtracts the given vector from this one.
     * Params:
     *   other = The vector to subtract from this one.
     * Returns: A reference to this vector, for method chaining.
     */
    public ref Vec!(T, size) sub(V)(Vec!(V, size) other) if (isNumeric!V) {
        static foreach (i; 0 .. size) data[i] -= other[i];
        return this;
    }

    alias subtract = sub;

    /** 
     * Multiplies this vector by a factor, element-wise.
     * Params:
     *   factor = The factor to multiply by.
     * Returns: A reference to this vector, for method chaining.
     */
    public ref Vec!(T, size) mul(V)(V factor) if (isNumeric!V) {
        static foreach (i; 0 .. size) data[i] *= factor;
        return this;
    }

    alias multiply = mul;

    /** 
     * Divides this vector by a factor, element-wise.
     * Params:
     *   factor = The factor to divide by.
     * Returns: A reference to this vector, for method chaining.
     */
    public ref Vec!(T, size) div(V)(V factor) if (isNumeric!V) {
        static foreach (i; 0 .. size) data[i] /= factor;
        return this;
    }

    alias divide = div;

    /** 
     * Determines the magnitude of this vector.
     * Returns: The magnitude of this vector.
     */
    public double mag() const {
        import std.math : sqrt;
        double sum = 0;
        static foreach (i; 0 .. size) sum += data[i] * data[i];
        return sqrt(sum);
    }

    alias magnitude = mag;
    alias length = mag;
    alias len = mag;

    /** 
     * Determines the [dot product](https://en.wikipedia.org/wiki/Dot_product)
     * of this vector and another vector.
     * Params:
     *   other = The other vector.
     * Returns: The dot product of the vectors.
     */
    public T dot(Vec!(T, size) other) const {
        T sum = 0;
        static foreach (i; 0 .. size) sum += data[i] * other[i];
        return sum;
    }

    alias dotProduct = dot;

    /** 
     * Adds two vectors.
     * Params:
     *   other = The other vector.
     * Returns: A vector representing the sum of this and the other.
     */
    public Vec!(T, size) opBinary(string op : "+", V)(Vec!(V, size) other) const if (isNumeric!V) {
        auto result = copy();
        result.add(other);
        return result;
    }

    /** 
     * Adds a vector to this one.
     * Params:
     *   other = The other vector.
     * Returns: A reference to this vector.
     */
    public ref Vec!(T, size) opOpAssign(string op : "+", V)(Vec!(V, size) other) if (isNumeric!V) {
        this.add(other);
        return this;
    }

    /** 
     * Subtracts two vectors.
     * Params:
     *   other = The other vector.
     * Returns: A vector representing the difference of this and the other.
     */
    public Vec!(T, size) opBinary(string op : "-", V)(Vec!(V, size) other) const if (isNumeric!V) {
        auto result = copy();
        result.sub(other);
        return result;
    }

    /** 
     * Subtracts a vector from this one.
     * Params:
     *   other = The other vector.
     * Returns: A reference to this vector.
     */
    public ref Vec!(T, size) opOpAssign(string op : "-", V)(Vec!(V, size) other) if (isNumeric!V) {
        this.sub(other);
        return this;
    }

    /** 
     * Multiplies a vector by a factor.
     * Params:
     *   factor = The factor to multiply by.
     * Returns: The resultant vector.
     */
    public Vec!(T, size) opBinary(string op : "*", V)(V factor) const if (isNumeric!V) {
        auto result = copy();
        result.mul(factor);
        return result;
    }

    /** 
     * Multiplies this vector by a factor.
     * Params:
     *   factor = The factor to multiply by.
     * Returns: A reference to this vector.
     */
    public ref Vec!(T, size) opOpAssign(string op : "*", V)(V factor) if (isNumeric!V) {
        this.mul(factor);
        return this;
    }

    /** 
     * Divides a vector by a factor.
     * Params:
     *   factor = The factor to divide by.
     * Returns: The resultant vector.
     */
    public Vec!(T, size) opBinary(string op : "/", V)(V factor) const if (isNumeric!V) {
        auto result = copy();
        result.div(factor);
        return result;
    }

    /** 
     * Divides this vector by a factor.
     * Params:
     *   factor = The factor to divide by.
     * Returns: A reference to this vector.
     */
    public ref Vec!(T, size) opOpAssign(string op : "/", V)(V factor) if (isNumeric!V) {
        this.div(factor);
        return this;
    }

    /** 
     * Compares this vector to another, based on their magnitudes.
     * Params:
     *   other = The vector to compare to.
     * Returns: 0 if the vectors have equal magnituded, 1 if this vector's
     * magnitude is bigger, and -1 if the other's is bigger.
     */
    public int opCmp(Vec!(T, size) other) const {
        double a = this.mag();
        double b = other.mag();
        if (a == b) return 0;
        if (a < b) return -1;
        return 1;
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
        public ref Vec!(T, size) norm() {
            const double mag = mag();
            static foreach (i; 0 .. size) {
                data[i] /= mag;
            }
            return this;
        }

        alias normalize = norm;
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
        public ref Vec!(T, size) toPolar() {
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
        public ref Vec!(T, size) toCartesian() {
            import std.math : cos, sin;
            T x = data[0] * cos(data[1]);
            T y = data[0] * sin(data[1]);
            data[0] = x;
            data[1] = y;
            return this;
        }
    }
}

// Aliases for common vector types.
alias Vec2f = Vec!(float, 2);
alias Vec3f = Vec!(float, 3);
alias Vec4f = Vec!(float, 4);

alias Vec2d = Vec!(double, 2);
alias Vec3d = Vec!(double, 3);
alias Vec4d = Vec!(double, 4);

alias Vec2i = Vec!(int, 2);
alias Vec3i = Vec!(int, 3);
alias Vec4i = Vec!(int, 4);

unittest {
    import std.stdio;
    import std.math;

    void assertFP(double actual, double expected, double delta = 1e-06, string msg = "Assertion failed.") {
        double lowBound = expected - delta;
        double highBound = expected + delta;
        assert(actual > lowBound && actual < highBound, msg);
    }

    // Test constructors.
    auto v1 = Vec2d([1.0, 2.0]);
    assert(v1.data == [1.0, 2.0]);
    auto v2 = Vec2d(1.0, 2.0);
    assert(v2.data == [1.0, 2.0]);
    auto v3 = Vec3f(3.14f);
    assert(v3.data == [3.14f, 3.14f, 3.14f]);
    auto v4 = Vec3f(v3);
    assert(v4.data == v3.data);
    auto v5 = Vec2i.empty();
    assert(v5.data == [0, 0]);

    // Test basic methods.
    v1.add(v2);
    assert(v1.data == [2.0, 4.0]);
    assert(v1[0] == 2.0);
    assert(v1[1] == 4.0);
    v1.sub(v2);
    assert(v1.data == [1.0, 2.0]);
    v1.mul(3.0);
    assert(v1.data == [3.0, 6.0]);
    v1.div(6.0);
    assert(v1.data == [0.5, 1.0]);
    assert(Vec2f(3, 4).mag == 5.0f);
    assert(Vec2d.empty.mag == 0);
    assert(Vec2d(1.0, 1.0).dot(Vec2d(1.0, 1.0)) == 2.0);

    // Operator overloads.
    assert(Vec2d(1, 1) + Vec2d(2, 1) == Vec2d(3, 2));
    assert(Vec2d(4, 4) - Vec2d(0, 3) == Vec2d(4, 1));
    v1 = Vec2d(1, 1);
    v1 += Vec2d(1, 1);
    v1 *= -2;
    assert(v1 == Vec2d(-4, -4));
    v1 /= -4;
    assert(v1 == Vec2d(1, 1));
    assert(Vec2d(0, 0) < Vec2d(1, 1));
    assert(Vec2d(42, 1) > Vec2d(0, 0));
    assert(Vec2d(0, 0).toString() == "[0, 0]");
    assert(Vec3f(1, -2.5f, 0.05).toString() == "[1, -2.5, 0.05]");

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