import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;
import std.range;
import std.regex;
import std.typecons;

auto getInputLines() {
    return generate!(() => readln.strip).until(null).array;
}

struct Instruction {
    this(string instructionLine) {
        static const instrRegex = ctRegex!(r"(\w+)\s\+?(-?\d+)");
        const m = match(instructionLine, instrRegex);
        this.type = m.captures[1];
        this.value = to!int(m.captures[2]);
    }

    string type;
    long value;
}

class Console {
    this(string[] code) {
        this.code = code.map!Instruction.array;
    }

    bool run() {
        while (!(line in visited)) {
            if (line == code.length)
                return true;

            visited[line] = true;
            const cur = code[line];
            switch (cur.type) {
                case "acc":
                    acc += cur.value;
                    line++;
                    break;
                case "nop":
                    line++;
                    break;
                case "jmp":
                    line += cur.value;
                    break;
                default:
                    "Error".writeln;
            }
        }
        return false;
    }

    void reset() {
        line = 0;
        acc = 0;
        visited.clear;
    }

    Instruction[] code;
    private int line;
    long acc;
    private bool[int] visited;
    alias code this;
}

void main() {
    // Input
    auto lines = getInputLines();

    // Star 1
    auto console = new Console(lines);
    console.run;
    console.acc.writeln;

    // Star 2
    foreach (ref instruction; console) {
        foreach (tup; [tuple("jmp", "nop"), tuple("nop", "jmp")]) {
            if (instruction.type == tup[0]) {
                instruction.type = tup[1];
                console.reset;
                if (console.run) {
                    console.acc.writeln;
                }
                instruction.type = tup[0];
            }
        }
    }
}
