import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;
import std.range;
import std.regex;
import std.typecons;

void main() {
    // Input
    string[] map;
    string line;
    while ((line = readln()) !is null) {
        map ~= line.strip;
    }

    long count_trees(int dx, int dy) {
        int cnt = 0;
        int x = 0, y = 0;
        do {
            cnt += map[x][y % map[0].length] == '#';
            x += dx;
            y += dy;
        } while (x < map.length);
        return cnt;
    }

    // Star 1
    count_trees(1, 3).writeln;

    // Star 2
    const slopes = [tuple(1, 1), tuple(1, 3), tuple(1, 5), tuple(1, 7), tuple(2, 1)];
    slopes.map!(d => count_trees(d[0], d[1]))
          .reduce!((a, b) => a * b)
          .writeln;
}
