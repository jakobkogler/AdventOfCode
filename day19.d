import std.stdio;
import std.range;
import std.string;
import std.conv;
import std.algorithm;

import IntCodeProgram;

long[] program_code;

bool insideBeam(long x, long y) {
    auto program = new Program(program_code);
    program.input ~= x;
    program.input ~= y;
    program.continue_run();
    assert(program.finished);
    return program.output[$-1] == 1;
}

void main() {
    program_code = readln.strip.split(',').to!(long[]);

    // star 1
    cartesianProduct(50.iota, 50.iota)
        .map!(a => insideBeam(a[0], a[1]))
        .sum
        .writeln;

    // star 2
    int left_x = 10;
    int left_y = 0;
    int right_y = 0;
    enum size = 100;

    bool found = false;
    while (!found) {
        left_x++;

        // find left bottom corner
        while (!insideBeam(left_x, left_y) || insideBeam(left_x, left_y + 1))
            left_y++;

        // find right upper corner
        while (!insideBeam(left_x + size - 1, right_y))
            right_y++;

        // does it fit
        found = left_y - right_y + 1 >= size;
    }

    writeln(left_x * 10000 + right_y);
}
