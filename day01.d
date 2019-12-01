import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;


void main() {
    // Input
    int[] a;
    string line;
    while ((line = readln()) !is null) {
        a ~= to!int(strip(line));
    }

    // Star 1
    auto x = a.map!(val => val / 3 - 2).array();
    int s = sum(x);
    writeln(s);

    // Star 2
    while (maxElement(x) > 0) {
        x = x.map!(val => max(0, val / 3 - 2)).array();
        s += sum(x);
    }
    writeln(s);
}
