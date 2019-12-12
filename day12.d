import std.string;
import std.stdio;
import std.range;
import std.algorithm;
import std.format;
import std.math;
import std.numeric;


struct Point {
    int x, y, z;

    Point opBinary(string op)(Vector v)
    if (op == "+" || op == "-")
    {
        Point p;
        p.x = mixin("this.x" ~ op ~ "v.x");
        p.y = mixin("this.y" ~ op ~ "v.y");
        p.z = mixin("this.z" ~ op ~ "v.z");
        return p;
    }

    unittest {
        auto p = Point(1, 2, 1);
        auto v = Vector(3, 4, 1);
        assert(p + v == Point(4, 6, 2));
        assert(p - v == Point(-2, -2, 0));
    }

    Point opOpAssign(string op)(Vector v)
    if (op == "+" || op == "-")
    {
        mixin("this.x" ~ op ~ "=v.x;");
        mixin("this.y" ~ op ~ "=v.y;");
        mixin("this.z" ~ op ~ "=v.z;");
        return this;
    }

    Vector opBinary(string op)(Point p) const
    if (op == "-")
    {
        return Vector(x - p.x, y - p.y, z - p.z);
    }

    unittest {
        auto p = Point(1, 2, 1);
        auto v = Vector(3, 4, 1);
        p += v;
        assert(p == Point(4, 6, 2));
        p += v;
        assert(p == Point(7, 10, 3));
        p -= v;
        assert(p == Point(4, 6, 2));
    }
}


struct Vector {
    int x, y, z;

    this(int x, int y, int z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    this(Point from, Point to) {
        x = to.x - from.x;
        y = to.y - from.y;
        y = to.z - from.z;
    }

    Vector sgn() const {
        return Vector(std.math.sgn(x), std.math.sgn(y), std.math.sgn(z));
    }

    Vector opOpAssign(string op)(Vector v)
    if (op == "+" || op == "-")
    {
        mixin("this.x" ~ op ~ "=v.x;");
        mixin("this.y" ~ op ~ "=v.y;");
        mixin("this.z" ~ op ~ "=v.z;");
        return this;
    }
}

Point readPoint() {
    int x, y, z;
    readf("<x=%d, y=%d, z=%d>\n", &x, &y, &z);
    return Point(x, y, z);
}

struct Moon {
    Point pos;
    Vector vel;

    void applyGravity(Moon other) {
        vel += (other.pos - pos).sgn();
    }

    void applyVelocity() {
        pos += vel;
    }

    int pot() const {
        return abs(pos.x) + abs(pos.y) + abs(pos.z);
    }

    int kin() const {
        return abs(vel.x) + abs(vel.y) + abs(vel.z);
    }

    int total() const {
        return pot * kin;
    }

    string toString() const {
        return format("pos=<x=%3.d, y=%3.d, z=%3.d>, vel=<x=%3.d, y=%3.d, z=%3.d>",
                      pos.x, pos.y, pos.z, vel.x, vel.y, vel.z);
    }

    Moon projection(string axis)() {
        Moon proj;
        mixin("proj.pos." ~ axis ~ " = this.pos." ~ axis ~ ";");
        mixin("proj.vel." ~ axis ~ " = this.vel." ~ axis ~ ";");
        return proj;
    }
    unittest {
        auto m = Moon(Point(1, 2, 3), Vector(4, 5, 6));
        assert(m.projection!("x") == Moon(Point(1, 0, 0), Vector(4, 0, 0)));
        assert(m.projection!("y") == Moon(Point(0, 2, 0), Vector(0, 5, 0)));
        assert(m.projection!("z") == Moon(Point(0, 0, 3), Vector(0, 0, 6)));
    }
}

void oneIteration(Moon[] moons) {
    foreach(i, ref moon1; moons) {
        foreach(ref moon2; moons) {
            moon1.applyGravity(moon2);
        }
    }

    foreach(ref moon; moons) {
        moon.applyVelocity();
    }

    debug foreach(moon; moons) {
        writeln(moon);
    }
    debug writeln();
}

struct Cycle {
    int offset, length;
}

Cycle findCycle(Moon[] moons) {
    auto tortoise = moons.dup;
    auto hare = moons.dup;
    do {
        tortoise.oneIteration;
        hare.oneIteration;
        hare.oneIteration;
    } while (tortoise != hare);

    int mu;
    tortoise = moons.dup;
    while (tortoise != hare) {
        tortoise.oneIteration;
        hare.oneIteration;
        ++mu;
    }

    int length;
    do {
        hare.oneIteration;
        ++length;
    } while (tortoise != hare);

    return Cycle(mu, length);
}

Moon[] projection(string axis)(Moon[] moons) {
    return moons.map!(moon => moon.projection!(axis)).array;
}

long lcm(long a, long b) {
    return a / gcd(a, b) * b;
}

void main() {
    Moon[] moons;
    foreach(_; 0 .. 4) {
        moons ~= Moon(readPoint(), Vector(0, 0, 0));
    }
    auto moons_copy = moons.dup;

    foreach(_; 0 .. 1000) {
        moons.oneIteration;
    }

    // star 1
    writeln(moons.map!(x => x.total).sum);

    // star 2
    auto cycle1 = findCycle(projection!("x")(moons_copy));
    auto cycle2 = findCycle(projection!("y")(moons_copy));
    auto cycle3 = findCycle(projection!("z")(moons_copy));
    assert(cycle1.offset == 0);
    assert(cycle2.offset == 0);
    assert(cycle3.offset == 0);
    writeln(lcm(lcm(cycle1.length, cycle2.length), cycle3.length));
}
