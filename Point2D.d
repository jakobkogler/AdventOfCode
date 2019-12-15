import std.conv;
import std.math;
import std.numeric;


struct Point {
    int x, y;

    this(int x, int y) {
        this.x = x;
        this.y = y;
    }

    this(long x, long y) {
        this.x = to!int(x);
        this.y = to!int(y);
    }

    Point opBinary(string op)(Vector v)
    if (op == "+" || op == "-")
    {
        Point p;
        p.x = mixin("this.x" ~ op ~ "v.x");
        p.y = mixin("this.y" ~ op ~ "v.y");
        return p;
    }

    unittest {
        auto p = Point(1, 2);
        auto v = Vector(3, 4);
        assert(p + v == Point(4, 6));
        assert(p - v == Point(-2, -2));
    }

    Point opOpAssign(string op)(Vector v)
    if (op == "+" || op == "-")
    {
        mixin("this.x" ~ op ~ "=v.x;");
        mixin("this.y" ~ op ~ "=v.y;");
        return this;
    }

    unittest {
        auto p = Point(1, 2);
        auto v = Vector(3, 4);
        p += v;
        assert(p == Point(4, 6));
        p += v;
        assert(p == Point(7, 10));
        p -= v;
        assert(p == Point(4, 6));
    }

    int opCmp(Point p) const
    {
        if (x == p.x)
            return sgn(y - p.y);
        else
            return sgn(x - p.x);
    }
}


struct Vector {
    int x, y;

    this(int x, int y) {
        this.x = x;
        this.y = y;
    }

    this(Point from, Point to) {
        x = to.x - from.x;
        y = to.y - from.y;
    }

    bool canBeSimplified() const {
        return gcd(abs(x), abs(y)) > 1;
    }

    double angle() const {
        double ang = atan2(to!double(y), to!double(x)) + PI_2;
        if (ang < 0)
            ang += 2 * PI;
        return ang;
    }
    unittest {
        assert(approxEqual(Vector(0, -1).angle, 0.));
        assert(approxEqual(Vector(1, 0).angle, PI_2));
        assert(approxEqual(Vector(0, 1).angle, PI));
        assert(approxEqual(Vector(-1, 0).angle, 3 * PI_2));
        assert(approxEqual(Vector(-1, -1).angle, 3 * PI_2 + PI_4));
    }
}
