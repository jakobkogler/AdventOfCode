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

string[2] withRetro(string line) {
    return [line, line.retro.to!string];
}

string column(const ref string[] image, int column) {
    if (column < 0)
        column += image[0].length;
    string res;
    foreach (line; image)
        res ~= line[column];
    return res;
}

string[] rotate(const ref string[] image) {
    return image.length.iota.map!(i => image.column(to!int(i))).retro.array;
}

string[] mirror(const ref string[] image) {
    return image.map!(line => line.retro.to!string).array;
}

ulong count2(const string[] img, char c) {
    return img.map!(line => line.count(c)).sum;
}

struct Tile {
    int id;
    string[] image;
    int orientation;

    this(string[] lines) {
        this.id = to!int(match(lines[0], `\d+`).captures[0]);
        this.image = lines[1..$];
    }

    string[] getBorders() const {
        string[] borders;
        borders ~= image[0].withRetro;
        borders ~= image[$-1].withRetro;
        borders ~= image.column(0).withRetro;
        borders ~= image.column(-1).withRetro;
        return borders;
    }

    void nextOrientation() {
        image = image.rotate;
        orientation = (orientation + 1) % 8;
        if (orientation % 4 == 0)
            image = image.mirror;
    }
}

int countPattern(const string[] image, const string[] pattern) {
    int cnt = 0;
    foreach (lines; image.slide(pattern.length)) {
        foreach (start; 0 .. lines[0].length - pattern[0].length + 1) {
            auto slice = 3.iota.map!(i => lines[i][start..start + pattern[0].length]).array;
            bool possible = true;
            foreach (ab; zip(pattern, slice)) {
                foreach (cd; zip(ab[0], ab[1])) {
                    if (cd[0] == '#' && cd[1] != '#')
                        possible = false;
                }
            }
            cnt += possible;
        }
    }
    return cnt;
}

void main() {
    // Input
    Tile[] tiles;
    string[] borders;
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
    while (borderOccurences[puzzle[0][0].image[0]] != 1 ||
           borderOccurences[puzzle[0][0].image.column(0)] != 1) {
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
                    if (puzzle[$-1][$-1].image.column(-1) == tile.image.column(0)) {
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
                    if (puzzle[$-1][0].image[$-1] == tile.image[0]) {
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
    string[] image;
    foreach (rowblocks; puzzle) {
        string[] tmp = new string[rowblocks[0].image.length - 2];
        foreach (block; rowblocks) {
            foreach (i, line; block.image[1..$-1]) {
                tmp[i] ~= line[1..$-1];
            }
        }
        image ~= tmp;
    }

    const string[] seamonster = ["                  # ",
                                 "#    ##    ##    ###",
                                 " #  #  #  #  #  #   "];
    foreach (i; 0..8) {
        int cnt = image.countPattern(seamonster);
        if (cnt) {
            (image.count2('#') - seamonster.count2('#') * cnt).writeln;
        }

        image = image.rotate;
        if (i % 4 == 3)
            image = image.mirror;
    }
}
