import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;
import std.typecons;
import std.math;


void main() {
    alias Point = Tuple!(int, "x", int, "y");

    int[Point] process() {
        auto moves = split(strip(readln()), ',');

        Point cur = tuple(0, 0);

        Point[char] dirs;
        dirs['U'] = tuple(0, 1);
        dirs['D'] = tuple(0, -1);
        dirs['R'] = tuple(1, 0);
        dirs['L'] = tuple(-1, 0);

        int[Point] steps;
        int step_cnt = 0;
        auto x = tuple(0, 1);
        foreach(move; moves) {
            Point dir = dirs[move[0]];

            int todo = to!int(move[1..$]);
            foreach(step; 0..todo) {
                cur.x += dir.x;
                cur.y += dir.y;
                step_cnt++;

                if ((cur in steps) is null)
                    steps[cur] = step_cnt;
            }
        }

        return steps;
    }

    auto steps1 = process();
    auto steps2 = process();

    int star1 = int.max;
    int star2 = int.max;
    foreach(k, v; steps1) {
        auto p = k in steps2;
        if (p !is null) {
            star1 = min(star1, abs(k.x) + abs(k.y));
            star2 = min(star2, v + *p);
        }
    }
    writeln(star1);
    writeln(star2);
}
