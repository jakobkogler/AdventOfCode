import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;
import std.range;
import std.regex;
import std.typecons;

string[] getInputLines() {
    string[] lines;
    string line;
    while ((line = readln()) !is null) {
        lines ~= line.strip;
    }
    return lines;
}

auto makeUnique(T)(T s) {
    return s.array.sort.uniq.array;
}

auto countInGroup(const string[] group) {
    return group.reduce!"a ~ b".makeUnique.length;
}

auto countAllInGroup(const string[] group) {
    return group.map!makeUnique.reduce!"setIntersection(a, b).array".length;
}

void main() {
    // Input
    const lines = getInputLines();

    // Star 1
    lines.split("").map!countInGroup.sum.writeln;

    // Star 2
    lines.split("").map!countAllInGroup.sum.writeln;
}
