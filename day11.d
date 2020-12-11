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

auto rules(Range)(Range boxRange) {
    char[][] box = boxRange.map!(to!(char[])).array;
    auto occupied = chain(box[0], box[1], box[2]).count('#');
    if (box[1][1] == 'L' && occupied == 0) {
        return '#';
    }
    if (box[1][1] == '#' && occupied >= 5) {
        return 'L';
    }
    return box[1][1];
}

auto advanceRound(string[] board) {
    auto line = ('.'.repeat.take(board[0].length)).to!(string);
    board = line ~ board ~ line;
    board = board.map!`'.' ~ a ~ '.'`.array;

    return board.slide(3)
        .map!(lines =>
        lines.array.transposed.map!(to!string).array
        .slide(3).map!rules // slide(3).tee!(a => a.writeln).map!rules
    ).map!(to!string).array;
}

auto advanceRound2(string[] board) {
    bool onBoard(int i, int j) {
        return 0 <= i && i < board.length && 0 <= j && j < board[0].length;
    }

    auto rules2(ulong i, ulong j, dchar c) {
        int occupied = 0;
        int[][] dirs = [[0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1]];
        foreach (dir; dirs) {
            int i2 = to!int(i);
            int j2 = to!int(j);

            i2 += dir[0];
            j2 += dir[1];
            while (onBoard(i2, j2)) {
                if (board[i2][j2] != '.') {
                    if (board[i2][j2] == '#')
                        occupied++;
                    break;
                }
                i2 += dir[0];
                j2 += dir[1];
            }
        }
        if (c == 'L' && occupied == 0)
            return '#';
        if (c == '#' && occupied >= 5)
            return 'L';
        return c;
    }

    return board.enumerate.map!(row =>
        row.value.enumerate.map!(elem =>
            rules2(row.index, elem.index, elem.value)
        )
    ).map!(to!string).array;
}

void main() {
    // Input
    auto initialBoard = getInputLines;

    // Star 1
    auto board = initialBoard;
    auto board2 = board;
    do {
        board2 = board;
        board = board.advanceRound;

    } while (board2 != board);
    board.map!`a.count('#')`.sum.writeln;

    // Star 2
    writeln;
    board = initialBoard;
    board2 = board;
    do {
        board2 = board;
        board = board.advanceRound2;
    } while (board2 != board);
    board.map!`a.count('#')`.sum.writeln;
}
