import std.stdio;
import std.range;
import std.string;
import std.conv;
import std.algorithm;
import std.file;

import IntCodeProgram;

void giveInput(Program program, string s) {
    program.input ~= (s.dup ~ ['\n']).map!`cast(long)a`.array;
}

void displayOutput(Program program) {
    foreach(group; program.output.split([10L, 10L])) {
        if (group.length == 1)
            group[0].writeln;
        else
            group.map!(to!char).array.writeln;
    }
    program.output.length = 0;
}

bool inOutput(Program program, string s) {
    string output = program.output.map!(to!char).array;
    return count(output, s) > 0;
}

void main() {
    auto program_code = readText("day25.in").strip.split(',').to!(long[]);
    
    // star 1
    auto program = new Program(program_code);

    enum W = "west";
    enum N = "north";
    enum S = "south";
    enum E = "east";

    enum TAKE = "take ";
    enum CAKE = "cake";
    enum CELL = "fuel cell";
    enum EGG = "easter egg";
    enum ORN = "ornament";
    enum HOL = "hologram";
    enum MATTER = "dark matter";
    enum BOTTLE = "klein bottle";
    enum CUBE = "hypercube";
    auto items = [CAKE, CELL, EGG, ORN, HOL, MATTER, BOTTLE, CUBE];
    enum DROP = "drop ";

    foreach(command; [N, N, E, E, TAKE~CAKE, W, W, S, S,
                      S, W, TAKE~CELL, W, TAKE~EGG, E, E, N,
                      E, TAKE~ORN, E, TAKE~HOL, E, TAKE~MATTER,
                      N, N, E, TAKE~BOTTLE, N, TAKE~CUBE, N])
        program.giveInput(command);
    foreach(item; items)
        program.giveInput(DROP~item);
    program.continue_run;

    outer: foreach(mask; 0..1<<items.length) {
        foreach(i, item; items) {
            if (mask & (1 << i))
                program.giveInput(TAKE~item);
        }
        program.continue_run;
        program.output.length = 0;
        program.giveInput(W);
        program.continue_run;

        if (!program.inOutput("Alert!"))
            break outer;

        foreach(i, item; items) {
            if (mask & (1 << i))
                program.giveInput(DROP~item);
        }
        program.continue_run;
        program.output.length = 0;
    }
    program.displayOutput;
}
