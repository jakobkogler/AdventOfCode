import std.stdio;
import std.string;
import std.algorithm;
import std.conv;
import std.range;
import std.traits;
import std.container.rbtree;
import core.thread;

import IntCodeProgram;

void main() {
    auto code = readln().strip.split(",").map!(to!long).array;

    // star 1
    auto program = new Program(code);
    program.continue_run();

    string picture = program.output.map!(to!char).array;
    string[] board = picture.strip.split('\n');

    char getChar(long y, long x) {
        if (y < 0 || y >= board.length || x < 0 || x >= board[0].length)
            return ' ';
        else
            return board[y][x];
    }

    int alignment_sum;
    foreach(y, row; board) {
        foreach(x, c; row) {
            if (c == '#' && getChar(y-1, x) == '#' && getChar(y+1, x) == '#'
                         && getChar(y, x-1) == '#' && getChar(y, x+1) == '#')
                alignment_sum += x * y;
        }
    }
    writeln(alignment_sum);

    // star 2
    program = new Program(code);
    program.a[0] = 2;
    void giveInput(string s) {
        program.input ~= (s.dup ~ ['\n']).map!`cast(long)a`.array;
    }
    giveInput("A,B,A,B,C,C,B,A,B,C");
    giveInput("L,4,R,8,L,6,L,10"); //,A
    giveInput("L,6,R,8,R,10,L,6,L,6"); //,B
    giveInput("L,4,L,4,L,10"); //,C
    giveInput("n"); // live feed

    program.continue_run();

    foreach(pic; program.output.split([10L, 10L])) {
        if (pic.length == 1) {
            writeln(pic[0]);
        } else {
            picture = pic.map!(to!char).array;
            debug writeln(picture);
        }
    }
}
