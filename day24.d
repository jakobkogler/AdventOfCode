import std.stdio;
import std.conv;
import std.algorithm;
import std.string;
import std.range;
import std.regex;
import std.complex;

auto getInputLines() {
    return generate!(() => readln.strip).until(null).array;
}

alias Coord = Complex!double;

Coord move(Coord c, string dir) {
    Coord[string] directionsEvenRow = [
        "e": Coord(1, 0),
        "se": Coord(0, 1),
        "sw": Coord(-1, 1),
        "w": Coord(-1, 0),
        "nw": Coord(-1, -1),
        "ne": Coord(0, -1)
    ];
    Coord[string] directionsOddRow = [
        "e": Coord(1, 0),
        "se": Coord(1, 1),
        "sw": Coord(0, 1),
        "w": Coord(-1, 0),
        "nw": Coord(0, -1),
        "ne": Coord(1, -1)
    ];
    if (c.im % 2 == 0)
        c += directionsEvenRow[dir];
    else
        c += directionsOddRow[dir];
    return c;
}

void main() {
    // Input
    auto lines = getInputLines;

    // Star 1
    int[Coord] flipped;
    foreach (line; lines) {
        auto cur = Coord(0, 0);
        static const re = ctRegex!`(e|se|sw|w|nw|ne)`;
        foreach (dir; matchAll(line, re)) {
            cur = cur.move(dir[1]);
        }
        flipped[cur]++;
    }
    flipped.values.filter!"a % 2".array.length.writeln;//((a, b) => a % 2)(1).writeln;

    // Star 2
}
