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
    bool[Coord] black;
    foreach (key, cnt; flipped) {
        if (cnt % 2)
            black[key] = true;
    }
    black.length.writeln;

    int countBlackNeighbors(Coord c) {
        int cnt = 0;
        foreach (dir; ["e", "se", "sw", "w", "nw", "ne"]) {
            auto c2 = c.move(dir);
            if (c2 in black)
                cnt += 1;
        }
        return cnt;
    }

    foreach (day; 1 .. 101) {
        write("Day ", day, ": ");
        double xMin = black.keys.map!"a.re".minElement - 1;
        double xMax = black.keys.map!"a.re".maxElement + 1;
        double yMin = black.keys.map!"a.im".minElement - 1;
        double yMax = black.keys.map!"a.im".maxElement + 1;

        bool[Coord] black2;
        foreach (x; xMin .. xMax+1) {
            foreach (y; yMin .. yMax+1) {
                auto c = Coord(x, y);
                int cnt = countBlackNeighbors(c);
                if (c in black) {
                    if (cnt == 1 || cnt == 2)
                        black2[c] = true;
                } else {
                    if (cnt == 2)
                        black2[c] = true;
                }
            }
        }
        black = black2;
        black.length.writeln;
    }
}
