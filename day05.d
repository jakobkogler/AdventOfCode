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

int computeID(string seat) {
    return reduce!"a*2 + (b == 'B' || b == 'R')"(0, seat);
}

void main() {
    // Input
    const seats = getInputLines();

    // Star 1
    seats.map!computeID.maxElement.writeln;

    // Star 2
    (seats.map!computeID.array.sort.findAdjacent!"b - a == 2".front + 1).writeln;
}
