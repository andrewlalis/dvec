# dvec - Easy linear algebra for D
dvec is a library that offers vector and matrix data structures and functions in a way that's intuitive, easy to use, tested, and well-documented. It takes advantage of the D language's advanced templating system and compile-time code-generation to help optimize performance and type safety.

dvec offers the basic linear algebra primitives:
- Vectors
- Matrices

Each of these can be of any desired integer size (within the limits of your system). For example, `Vec!(float, 5) v;` defines a 5-dimensional floating-point vector, and `Mat!(int, 2, 3) m;` defines a 2x3 (2 rows by 3 columns) integer matrix. However, this can get to be a bit tedious, so we've included the most common vectors and matrices as aliases for you:
- 2, 3, and 4-dimensional vectors of float, double, and int types: `Vec3d`, `Vec2i`, and `Vec4f`, for example.
- 2, 3, and 4-dimensional square matrices of float, double, and int types: `Mat2f`, `Mat3i`, and `Mat4d`, for example.

Each primitive is a simple struct with a fully transparent internal structure, and implements all the basic arithmetic operators, so you can do things like this easily:
```d
Vec3f v = Vec3f(1f, 2f, 3f) * 5 - Vec3f(0.5f);
// v.data == [4.5f, 9.5f, 14.5f]
```

**Besides the `toString()` methods**, no parts of this library make use of the GC, and are thus `@nogc` compatible.

### Vectors
Vectors are simply a fixed-size list of numerical elements, which implement a lot of mathematical operations that are useful in linear algebra.

The values of a vector can be accessed in the following ways:
- By index: `v[1]` gets the second element in vector `v`.
- By name: `v.x, v.y, v.z, v.w` gets the first, second, third, or fourth element of a vector, respectively.
- By the internal data: `v.data` gets the internal array.

#### Casting
You can cast vectors of different types and sizes using D's standard `cast(type)` syntax. Note that the individual elements are casted using `cast` as well, and that may result in data loss if you, for example, cast from a floating-point to integer vector. If you cast to a vector with a different size, the following rules apply:
- If the new vector type is smaller, extra elements are truncated.
- If the new vector type is larger, any missing elements are initialized to zero.

#### Specialization
Certain vector types get access to extra special functions:

- Any floating-point (float, double) vector supports the `norm()` method, to normalize the vector to a unit vector of length 1.
- Any floating-point (float, double) 2-dimensional vector supports the `toPolar()` and `toCartesian()` methods, so that the vector can be treated as polar or cartesian coordinates and converted between the two.
- Any floating-point (float, double) 3-dimensional vector supports the `cross()` method for computing the cross product with another 3-dimensional vector.

### Matrices
Certain matrix types get access to extra special functions:

- Square matrices (NxM matrices where N = M) support a variety of additional methods that are useful for linear algebra, like `det()` (determinant), `inv()` (inverse), and so on.
- 3x3 matrices support linear transformation methods in 2 dimensions, like translation, rotation, skew, and scaling.
- 4x4 matrices support linear transformation methods in 3 dimensions.

For more information, please see [dub project page](https://code.dlang.org/packages/dvec) and its associated documentation.
> A lot of effort has gone into making sure everything in this library is well-documented and explained well. If you find that documentation is missing or insufficient for a certain part, please make an issue on GitHub!
