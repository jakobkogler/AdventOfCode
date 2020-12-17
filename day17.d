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

void main() {
    // Input
    auto lines = getInputLines;

    // Star 1
    const ulong N = 6;
    ulong offset = N + 1;
    ulong X = lines.length + 2 * offset;
    ulong Y = lines[0].length + 2 * offset;
    ulong Z = 1 + 2 * offset;
    int[][][] board = new int[][][](X, Y, Z);
    foreach (x, row; lines) {
        foreach (y, elem; row) {
            if (elem == '#') {
                board[x+offset][y+offset][offset] = elem == '#';
            }
        }
    }

    foreach (i; 0 .. N) {
        int[][][] board2 = new int[][][](X, Y, Z);
        foreach (x; 1 .. X-1) {
            foreach (y; 1 .. Y-1) {
                foreach (z; 1 .. Z-1) {
                    int activeCnt = 0;
                    foreach (x2; x-1 .. x+2) {
                        foreach (y2; y-1 .. y+2) {
                            foreach (z2; z-1 .. z+2) {
                                activeCnt += board[x2][y2][z2];
                            }
                        }
                    }
                    activeCnt -= board[x][y][z];
                    if (board[x][y][z] && (activeCnt == 2 || activeCnt == 3))
                        board2[x][y][z] = 1;
                    if (!board[x][y][z] && activeCnt == 3)
                        board2[x][y][z] = 1;
                }
            }
        }
        board = board2;
    }
    board.map!(yz => yz.map!sum.sum).sum.writeln;


    // Star 2
    ulong W = 1 + 2 * offset;
    int[][][][] boardw = new int[][][][](X, Y, Z, W);
    foreach (x, row; lines) {
        foreach (y, elem; row) {
            if (elem == '#') {
                boardw[x+offset][y+offset][offset][offset] = elem == '#';
            }
        }
    }

    foreach (i; 0 .. N) {
        int[][][][] board2 = new int[][][][](X, Y, Z, W);
        foreach (x; 1 .. X-1) {
            foreach (y; 1 .. Y-1) {
                foreach (z; 1 .. Z-1) {
                    foreach (w; 1 .. W-1) {
                        int activeCnt = 0;
                        foreach (x2; x-1 .. x+2) {
                            foreach (y2; y-1 .. y+2) {
                                foreach (z2; z-1 .. z+2) {
                                    foreach (w2; w-1 .. w+2) {
                                        activeCnt += boardw[x2][y2][z2][w2];
                                    }
                                }
                            }
                        }
                        activeCnt -= boardw[x][y][z][w];
                        if (boardw[x][y][z][w] && (activeCnt == 2 || activeCnt == 3))
                            board2[x][y][z][w] = 1;
                        if (!boardw[x][y][z][w] && activeCnt == 3)
                            board2[x][y][z][w] = 1;
                    }
                }
            }
        }
        boardw = board2;
    }
    boardw.map!(yzw => yzw.map!(zw => zw.map!sum.sum).sum).sum.writeln;
}
