import std.stdio;
import std.string;
import std.algorithm;
import std.conv;
import std.range;
import std.traits;
import std.container.rbtree;

import IntCodeProgram;
import Point2D;

int ida(ref Program program) {
    int steps;
    auto rbtree = redBlackTree([Point(0, 0)]);

    long[] visited_cnts;
    bool isSolvable;
    do {
        steps++;
        debug writeln(steps, ":");
        rbtree.clear();
        isSolvable = solveable(program, Point(0, 0), rbtree, steps);
        debug writeln("  ", rbtree.length, " vertices visited");
        visited_cnts ~= rbtree.length;
        if (visited_cnts[$-2] == visited_cnts[$-1])
            break; // star 2
    } while(!isSolvable);
    return steps;
}

enum Direction { NORTH=1, SOUTH=2, WEST=3, EAST=4 };
enum Direction[Direction] opposite = [
    Direction.NORTH: Direction.SOUTH,
    Direction.SOUTH: Direction.NORTH,
    Direction.WEST: Direction.EAST,
    Direction.EAST: Direction.WEST
];
enum Vector[Direction] vec = [
    Direction.NORTH: Vector(0, -1),
    Direction.SOUTH: Vector(0, 1),
    Direction.WEST: Vector(1, 0),
    Direction.EAST: Vector(-1, 0)
];

bool solveable(T)(ref Program program, Point cur, ref T rbtree, int todo) {
    rbtree.insert(cur);

    if (todo == 0)
        return false;

    foreach(dir; EnumMembers!Direction) {
        auto v = vec[dir];
        if (rbtree.equalRange(cur + v).array.length) // already visited
            continue;

        long res = program.doMove(dir);

        if (res == 0) {  // wall
            continue;
        }
        if (res == 2)  // found it
            return true;
        if (res == 1) {
            if (solveable(program, cur + v, rbtree, todo-1))
                return true;
            program.doMove(opposite[dir]);
        }
    }
    return false;
}

long doMove(ref Program program, int dir) {
    program.input ~= dir;
    program.continue_run();
    return program.output[$-1];
}

struct QueueItem {
    Point p;
    int dist;
}

bool contains(const ref RedBlackTree!(Point, "a < b", false) rbtree, Point p) {
    return rbtree.equalRange(p).array.length > 0;
}

void main() {
    auto code = readln().strip.split(",").map!(to!long).array;

    // star 1
    auto program = new Program(code);
    writeln(ida(program));

    // star 2
    writeln(ida(program) - 1);
}
