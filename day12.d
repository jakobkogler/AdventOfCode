import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;
import std.range;
import std.regex;
import std.typecons;
import std.math;
import Point2D;

auto getInputLines() {
    return generate!(() => readln.strip).until(null).array;
}

struct Instruction {
    this(string s) {
        static r = ctRegex!`(\w)(\d+)`;
        auto m = match(s, r);
        direction = m.captures[1][0];
        value = to!int(m.captures[2]);
    }

    char direction;
    int value;
}

auto getDirection(Instruction instruction, ref Vector currentFacingDirection) {
    static N = Vector(0, 1);
    static E = Vector(1, 0);
    static S = Vector(0, -1);
    static W = Vector(-1, 0);
    static O = Vector(0, 0);
    switch(instruction.direction) {
        case 'N':
            return N * instruction.value;
        case 'E':
            return E * instruction.value;
        case 'S':
            return S * instruction.value;
        case 'W':
            return W * instruction.value;
        case 'F':
            return currentFacingDirection * instruction.value;
        case 'R':
            foreach (i; 0 .. instruction.value / 90)
                currentFacingDirection.rotateRight;
            return O;
        case 'L':
            foreach (i; 0 .. instruction.value / 90)
                currentFacingDirection.rotateLeft;
            return O;
        default:
            assert(false);
    }
}

auto getDirection2(Instruction instruction, ref Vector currentFacingDirection) {
    static N = Vector(0, 1);
    static E = Vector(1, 0);
    static S = Vector(0, -1);
    static W = Vector(-1, 0);
    static O = Vector(0, 0);
    switch(instruction.direction) {
        case 'N':
            currentFacingDirection += N * instruction.value;
            return O;
        case 'E':
            currentFacingDirection += E * instruction.value;
            return O;
        case 'S':
            currentFacingDirection += S * instruction.value;
            return O;
        case 'W':
            currentFacingDirection += W * instruction.value;
            return O;
        case 'F':
            return currentFacingDirection * instruction.value;
        case 'R':
            foreach (i; 0 .. instruction.value / 90)
                currentFacingDirection.rotateRight;
            return O;
        case 'L':
            foreach (i; 0 .. instruction.value / 90)
                currentFacingDirection.rotateLeft;
            return O;
        default:
            assert(false);
    }
}

void main() {
    // Input
    auto instructions = getInputLines.map!Instruction.array;

    // Star 1
    auto ship = Point(0, 0);
    auto currentFacingDirection = Vector(1, 0);
    foreach (instr; instructions) {
        ship += getDirection(instr, currentFacingDirection);
    }
    (ship.x.abs + ship.y.abs).writeln;

    // Star 3
    ship = Point(0, 0);
    currentFacingDirection = Vector(10, 1);
    foreach (instr; instructions) {
        ship += getDirection2(instr, currentFacingDirection);
    }
    (ship.x.abs + ship.y.abs).writeln;
}
