module dvec.vector;

import std.traits : isNumeric, isFloatingPoint;

/** 
 * Generic struct that represents a vector holding `size` elements of type `T`.
 */
struct Vec(T, size_t size) if (isNumeric!T && size > 1) {
    public static const size_t SIZE = size;

    private T[size] data;

    public this(T[size] elements) {
        static foreach (i; 0 .. size) data[i] = elements[i];
    }

    public this(T[] elements...) {
        if (elements.length != size) assert(false, "Invalid number of elements provided to Vec constructor.");
        static foreach (i; 0 .. size) data[i] = elements[i];
    }

    public this(T value) {
        static foreach (i; 0 .. size) data[i] = value;
    }

    public this(Vec!(T, size) other) {
        this(other.data);
    }

    public static Vec!(T, size) empty() {
        Vec!(T, size) v;
        static foreach (i; 0 .. size) v[i] = 0;
        return v;
    }

    public T opIndex(size_t i) {
        return data[i];
    }

    public void opIndexAssign(T value, size_t i) {
        data[i] = value;
    }

    public void add(V)(Vec!(V, size) other) if (isNumeric!V) {
        static foreach (i; 0 .. size) data[i] += other[i];
    }

    public void sub(V)(Vec!(V, size) other) if (isNumeric!V) {
        static foreach (i; 0 .. size) data[i] -= other[i];
    }

    alias subtract = sub;

    public void mul(V)(V factor) if (isNumeric!V) {
        static foreach (i; 0 .. size) data[i] *= factor;
    }

    alias multiply = mul;

    public void div(V)(V factor) if (isNumeric!V) {
        static foreach (i; 0 .. size) data[i] /= factor;
    }

    alias divide = div;

    public double mag() {
        import std.math : sqrt;
        double sum = 0;
        static foreach (i; 0 .. size) sum += data[i] * data[i];
        return sqrt(sum);
    }

    alias magnitude = mag;
    alias length = mag;
    alias len = mag;

    public T dot(Vec!(T, size) other) {
        T sum = 0;
        static foreach (i; 0 .. size) sum += data[i] * other[i];
        return sum;
    }

    alias dotProduct = dot;

    // TODO: Make this @nogc compatible!
    public string toString() const {
        import std.conv : to;
        string s = "[";
        static foreach (i; 0 .. size - 1) {
            s ~= data[i].to!string;
            s ~= ", ";
        }
        s ~= data[size - 1].to!string;
        s ~= "]";
        return s;
    }

    static if (isFloatingPoint!T) {
        public void norm() {
            const double mag = mag();
            static foreach (i; 0 .. size) {
                data[i] /= mag;
            }
        }

        alias normalize = norm;
    }

    static if (isFloatingPoint!T && size == 2) {
        public void toPolar() {
            import std.math : atan2;
            T radius = mag();
            T angle = atan2(data[1], data[0]);
            data[0] = radius;
            data[1] = angle;
        }

        public void toCartesian() {
            import std.math : cos, sin;
            T x = data[0] * cos(data[1]);
            T y = data[0] * sin(data[1]);
            data[0] = x;
            data[1] = y;
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