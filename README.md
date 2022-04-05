# dvec
Library for extremely lightweight vector and matrix operations.

Here's an example:

```d
import dvec;
import std.stdio;

void main() {
    Vec2f p = Vec2f(0, 0);
    Mat3f tx = Mat3f.identity();
    tx.translate(42, 64);
    auto transformed = tx.map(p);
    assert(transformed.data == [42, 64]);
}
```

For more information, please see the documentation.
