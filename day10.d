import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;
import std.range;
import std.numeric;
import std.math;
import std.typecons;

import Point2D;

Nullable!Point firstKometOnRay(char[][] grid, Point p, Vector v) {
    bool in_grid(Point p) {
        return 0 <= p.x && p.x < grid[0].length && 0 <= p.y && p.y < grid.length;
    }

    while (in_grid(p += v)) {
        if (grid[p.y][p.x] == '#')
            return p.nullable;
    }
    return Nullable!Point.init;
}

unittest {
    string[] grid_s = [".#", "#."];
    char[][] grid = grid_s.map!(x => to!(char[])(x)).array;
    assert(firstKometOnRay(grid, Point(0, 1), Vector(1, -1)).get == Point(1, 0));
    assert(firstKometOnRay(grid, Point(0, 1), Vector(0, -1)).isNull);
}

Point[] getKomets(char[][] grid) {
    Point[] komets;
    foreach(y, row; grid) {
        foreach(x, elem; row) {
            if (elem == '#')
                komets ~= Point(to!int(x), to!int(y));
        }
    }
    return komets;
}

Vector[] getSortedVectors(char[][] grid, Point p) {
    Vector[] vectors;
    foreach(y, row; grid) {
        foreach(x, elem; row) {
            auto q = Point(to!int(x), to!int(y));
            if (p == q)
                continue;

            auto v = Vector(p, q);
            if (!v.canBeSimplified()) {
                vectors ~= v;
            }
        }
    }
    return vectors.sort!((v1, v2) => v1.angle < v2.angle).release;
}

void main() {
    char[][] grid;
    string s;
    while ((s = readln()) !is null) {
        grid ~= to!(char[])(strip(s));
    }

    // star 1
    int best = 0;
    Point station;
    foreach(p; getKomets(grid)) {
        int cnt;
        foreach(v; getSortedVectors(grid, p)) {
            if (!firstKometOnRay(grid, p, v).isNull) {
                ++cnt;
            }
        }

        if (cnt > best) {
            best = cnt;
            station = p;
        }
    }
    writeln(best);

    // star 2
    Point[] order;
    foreach(v; cycle(getSortedVectors(grid, station))) {
        auto _p = firstKometOnRay(grid, station, v);
        if (!_p.isNull) {
            auto p = _p.get;
            order ~= p;
            grid[p.y][p.x] = '.';
        }

        if (order.length == 200)
            break;
    }
    auto p = order[199];
    writeln(p.x * 100 + p.y);
}
