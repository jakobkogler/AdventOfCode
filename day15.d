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

auto findKthNumber(int[] numbers, int k) {
    alias Occurences = int[];
    Occurences[int] lastOccurences;
    foreach (i, x; numbers) {
        lastOccurences[x] ~= to!int(i);
    }
    int lastNumber = numbers[$-1];
    foreach (i; numbers.length .. k) {
        int nextNumber;
        if (lastOccurences[lastNumber].length == 1) {
            nextNumber = 0;
        } else {
            nextNumber = lastOccurences[lastNumber][$-1] - lastOccurences[lastNumber][$-2];
        }
        lastOccurences[nextNumber] ~= to!int(i);
        lastNumber = nextNumber;
    }
    return lastNumber;
}

void main() {
    // Input
    auto lines = getInputLines;
    auto numbers = lines[0].split(",").map!(to!int).array;

    // Star 1
    numbers.findKthNumber(2020).writeln;

    // Star 2
    numbers.findKthNumber(30000000).writeln;
}
