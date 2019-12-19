import std.algorithm;
import std.stdio;
import std.conv;
import std.string;
import std.math;
import std.numeric;

import IntCodeProgram;
import Point2D;


void main() {
    auto a = to!(long[])(split(strip(readln()), ','));

    // star 1
    auto program = new Program(a);

    auto cur = Point(0, 0);
    auto dir = Vector(0, -1);
    int[Point] grid;

    while (!program.finished) {
        program.input ~= grid.get(cur, 0);
        program.continue_run();
        grid[cur] = to!int(program.output[$-2]);
        if (program.output[$-1] == 0)
            dir = Vector(dir.y, -dir.x);
        else
            dir = Vector(-dir.y, dir.x);
        cur += dir;
    }
    writeln(grid.length);
    
    // star 2
    program = new Program(a);
    cur = Point(0, 0);
    dir = Vector(0, -1);
    grid = [cur: 1];

    while (!program.finished) {
        program.input ~= grid.get(cur, 0);
        program.continue_run();
        grid[cur] = to!int(program.output[$-2]);
        if (program.output[$-1] == 0)
            dir = Vector(dir.y, -dir.x);
        else
            dir = Vector(-dir.y, dir.x);
        cur += dir;
    }

    Point mi, ma;
    foreach(p, c; grid) {
        if (c) {
            mi.x = min(mi.x, p.x);
            ma.x = max(ma.x, p.x);
            mi.y = min(mi.y, p.y);
            ma.y = max(ma.y, p.y);
        }
    }
    foreach(y; mi.y .. ma.y+1) {
        foreach(x; mi.x .. ma.x+1) {
            int color = grid.get(Point(x, y), 0);
            string colors = ".#";
            write(colors[color]);
        }
        writeln();
    }
}
