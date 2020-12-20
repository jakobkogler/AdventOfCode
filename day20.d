/+dub.sdl:
dependency "mir-algorithm" version="~>2.0.0"
+/
// run with dub --build=release --single day20.d <input/day20.in

import std.stdio;
import std.conv;
import std.algorithm;
import std.string;
import std.range;
import std.regex;
import mir.ndslice : slice, Slice, fuse;
import mir.ndslice.topology : map, as, mirRetro = retro, windows;
import mir.ndslice.dynamic : rotated, reversed;
import mir.ndslice.concatenation : concatenation;
import mir.math.sum: mirSum = sum;

auto getInputLines() {
    return generate!(() => readln.strip).until(null).array;
}

alias Vector = Slice!(int*, 1);
alias Matrix = Slice!(int*, 2);

int toInt(Range)(Range v) {
    return 0.reduce!`a * 2 + b`(v);
}

Matrix stringsToMatrix(const string[] s) {
    return s.fuse.map!(a => a == '#').as!int.slice;
}

struct Tile {
    int id;
    Matrix image;
    int orientation = 0;

    this(string[] lines) {
        this.id = to!int(match(lines[0], `\d+`).captures[0]);
        this.image = lines[1..$].stringsToMatrix;
    }

    int[] getBorders() const {
        Vector[] borders;
        borders ~= image[0, 0..$].dup;
        borders ~= image[$-1, 0..$].dup;
        borders ~= image[0..$, 0].dup;
        borders ~= image[0..$, $-1].dup;
        foreach (v; borders.dup)
            borders ~= v.mirRetro.slice;
        return borders.map!toInt.array;
    }

    void nextOrientation() {
        image = image.rotated.slice;
        orientation = (orientation + 1) % 8;
        if (orientation % 4 == 0)
            image = image.reversed.slice;
    }
}

bool containsPattern(R)(R m, const Matrix pattern) {
    return (m.slice & pattern).slice == pattern;
}

int countPattern(const Matrix image, const Matrix pattern) {
    return image.windows(pattern.shape).map!(w => w.containsPattern(pattern)).mirSum(0);
}

void main() {
    // Input
    Tile[] tiles;
    int[] borders;
    while (true) {
        auto lines = getInputLines;
        if (lines) {
            tiles ~= Tile(lines);
            borders ~= tiles[$-1].getBorders;
        } else
            break;
    }

    auto borderOccurences = borders.sort.group.assocArray;
    debug borderOccurences.values.sort.group.writeln;
    // looks like there are every border is unique, since there are 96 = 12 * 4 * 2
    // many borders that only appear once, and the others appear only twice

    // Star 1
    auto corners = tiles.filter!(tile =>
        tile.getBorders.map!(b => borderOccurences[b]).count(1) == 4).array;
    corners.map!(t => t.id).map!(to!long).reduce!`a*b`.writeln;

    // Star 2
    // first solve the puzzle
    Tile[][] puzzle;
    void removeById(Tile toRemove) {
        tiles = tiles.remove!(tile => tile.id == toRemove.id);
    }

    // start with corner and orient it accordingly
    puzzle ~= [corners[0]];
    while (borderOccurences[puzzle[0][0].image[0, 0..$].toInt] != 1 ||
           borderOccurences[puzzle[0][0].image[0..$, 0].toInt] != 1) {
        puzzle[0][0].nextOrientation;
    }
    removeById(puzzle[0][0]);

    while (!tiles.empty) {
        while (true) {
            // try to fill the current line
            Tile found;
            found.id = -1;
            foreach (tile; tiles) {
                foreach (i; 0..8) {
                    if (puzzle[$-1][$-1].image[0..$, $-1] == tile.image[0..$, 0]) {
                        found = tile;
                        break;
                    }
                    tile.nextOrientation;
                }
                if (found.id != -1)
                    break;
            }
            if (found.id == -1)
                break;
            puzzle[$-1] ~= found;
            removeById(found);
        }

        // try to find start of next line
        if (!tiles.empty) {
            Tile found;
            found.id = -1;
            foreach (tile; tiles) {
                foreach (i; 0..8) {
                    if (puzzle[$-1][0].image[$-1, 0..$] == tile.image[0, 0..$]) {
                        found = tile;
                        break;
                    }
                    tile.nextOrientation;
                }
                if (found.id != -1)
                    break;
            }

            puzzle ~= [found];
            removeById(found);
        }
    }
    debug puzzle.map!(line => line.map!(x => x.id).array).each!writeln;

    // convert to the final image
    auto fullPuzzle = puzzle.map!(tiles =>
        tiles.map!(tile => tile.image[1..$-1, 1..$-1].slice).array).array;
    Matrix[] rowblocks;
    foreach (blocks; fullPuzzle) {
        rowblocks ~= blocks.reduce!((a, b) => concatenation!1(a, b).slice);
    }
    Matrix image = rowblocks.reduce!((a, b) => concatenation(a, b).slice);

    const string[] seamonster = ["                  # ",
                                 "#    ##    ##    ###",
                                 " #  #  #  #  #  #   "];
    Matrix pattern = seamonster.stringsToMatrix;
    foreach (i; 0..8) {
        int cnt = image.countPattern(pattern);
        if (cnt)
            (image.mirSum - pattern.mirSum * cnt).writeln;

        image = image.rotated.slice;
        if (i % 4 == 3)
            image = image.reversed.slice;
    }
}
