import std.stdio;
import std.range;
import std.string;
import std.conv;
import std.algorithm;

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

void jumpIfHoleAndSafe(Program program) {
    // jump if hole in the next 3 (A,B,C), and no hole at D
    program.giveInput("NOT A J");
    program.giveInput("NOT B T");
    program.giveInput("OR T J");
    program.giveInput("NOT C T");
    program.giveInput("OR T J");
    program.giveInput("AND D J");
}

void main() {
    auto program_code = readln.strip.split(',').to!(long[]);
    
    // star 1
    auto program = new Program(program_code);
    program.jumpIfHoleAndSafe();
    program.giveInput("WALK");
    program.continue_run();
    program.displayOutput;

    // star 2
    program = new Program(program_code);
    program.jumpIfHoleAndSafe();

    // don't jump if E and H are holes
    program.giveInput("NOT E T");
    program.giveInput("NOT T T");
    program.giveInput("OR H T");
    program.giveInput("AND T J");

    program.giveInput("RUN");

    program.continue_run();
    program.displayOutput;
}
