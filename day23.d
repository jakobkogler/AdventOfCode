import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.algorithm;
import std.range;
import std.typecons;

import IntCodeProgram;

struct Point {
    long X, Y;
    this(long[] a) {
        X = a[1];
        Y = a[2];
    }
}

void main() {
    long[] code = readln.strip.split(',').to!(long[]);

    Program[50] programs;
    Point[][50] queues;
    foreach(i; 0..50) {
        auto program = new Program(code);
        program.input ~= i;
        programs[i] = program;
    }
    auto NAT = Nullable!Point.init;

    bool found255 = false;
    long[] NAT_y;
    while (true) {
        bool all_idle = true;
        foreach(i, program; programs) {
            if (queues[i].length == 0)
                program.input ~= -1;
            else {
                all_idle = false;
                program.input ~= queues[i][0].X;
                program.input ~= queues[i][0].Y;
                queues[i].popFront;
            }
            program.continue_run();
            foreach(operation; program.output.chunks(3)) {
                all_idle = false;
                if (operation[0] == 255) {
                    if (!found255) {
                        found255 = true;
                        operation[2].writeln;
                    }
                    NAT = Point(operation);
                } else {
                    queues[operation[0]] ~= Point(operation);
                }
            }
            program.output.length = 0;
        }

        if (all_idle) {
            queues[0] ~= NAT.get;
            NAT_y ~= NAT.get.Y;
            if (NAT_y.length > 1 && NAT_y[$-2] == NAT_y[$-1]) {
                NAT_y[$-1].writeln;
                break;
            }
        }
    }
}
