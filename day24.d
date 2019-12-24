import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.algorithm;
import std.range;
import std.typecons;

alias Board = char[5][5];

int countNeigh(Board board, long x, long y) {
    int c;
    foreach(i; max(0, x-1)..min(5, x+2)) {
        foreach(j; max(0, y-1)..min(5, y+2)) {
            if (i != x && j != y)
                continue;
            if (board[i][j] == '#' && (x != i || y != j))
                c++;
        }
    }
    return c;
}

Board simulate(Board board) {
    Board res;
    foreach(i, row; board) {
        foreach(j, e; row) {
            if (e == '#') {
                if (board.countNeigh(i, j) == 1)
                    res[i][j] = '#';
                else
                    res[i][j] = '.';
            } else {
                int n = board.countNeigh(i, j);
                if (1 <= n && n <= 2)
                    res[i][j] = '#';
                else
                    res[i][j] = '.';
            }
        }
    }
    return res;
}

alias BoardRec = Board[int];

int cntRec(BoardRec board_rec, int level, int x, int y) {
    int cnt;
    // up
    if (x == 3 && y == 2) { // deeper
        if (level+1 in board_rec) {
            foreach(i; 0..5)
                cnt += board_rec[level+1][4][i] == '#';
        }
    } else if (x > 0) {
        if (level in board_rec)
            cnt += board_rec[level][x-1][y] == '#';
    } else if (level-1 in board_rec) {
        cnt += board_rec[level-1][1][2] == '#';
    }

    // down
    if (x == 1 && y == 2) { // deeper
        if (level+1 in board_rec) {
            foreach(i; 0..5)
                cnt += board_rec[level+1][0][i] == '#';
        }
    } else if (x < 4) {
        if (level in board_rec)
            cnt += board_rec[level][x+1][y] == '#';
    } else if (level-1 in board_rec) {
        cnt += board_rec[level-1][3][2] == '#';
    }

    // left
    if (x == 2 && y == 3) { // deeper
        if (level+1 in board_rec) {
            foreach(i; 0..5)
                cnt += board_rec[level+1][i][4] == '#';
        }
    } else if (y > 0) {
        if (level in board_rec)
            cnt += board_rec[level][x][y-1] == '#';
    } else if (level-1 in board_rec) {
        cnt += board_rec[level-1][2][1] == '#';
    }

    // right
    if (x == 2 && y == 1) { // deeper
        if (level+1 in board_rec) {
            foreach(i; 0..5)
                cnt += board_rec[level+1][i][0] == '#';
        }
    } else if (y < 4) {
        if (level in board_rec)
            cnt += board_rec[level][x][y+1] == '#';
    } else if (level-1 in board_rec) {
        cnt += board_rec[level-1][2][3] == '#';
    }

    return cnt;
}

BoardRec simulate(BoardRec board, int time) {
    BoardRec res;
    foreach(t; -time..time+1) {
        Board b;
        res[t] = b;
        foreach(i; 0..5) {
            foreach(j; 0..5) {
                if (i == 2 && j == 2) {
                    res[t][i][j] = '?';
                    continue;
                }
                int n = board.cntRec(t, i, j);
                if (t in board && board[t][i][j] == '#') {
                    if (n == 1)
                        res[t][i][j] = '#';
                    else
                        res[t][i][j] = '.';
                } else {
                    if (1 <= n && n <= 2)
                        res[t][i][j] = '#';
                    else
                        res[t][i][j] = '.';
                }
            }
        }
    }
    return res;
}

long biodiversity(Board board) {
    long res;
    foreach(i, row; board) {
        foreach(j, e; row) {
            if (e == '#')
                res += 2^^(i*5+j);
        }
    }
    return res;
}

void main() {
    Board board;
    foreach(i; 0..5) {
        board[i] = readln.strip.idup;
    }
    Board copy = board;
    
    // star 1
    int[long] seen;
    seen[board.biodiversity] = 1;

    while (true) {
        board = board.simulate;
        long bio = board.biodiversity;
        if (bio in seen) {
            bio.writeln;
            break;
        }
        seen[bio] = 1;
    }

    // star 2
    BoardRec board_rec = [0: copy];
    foreach(time; 0..200) {
        board_rec = board_rec.simulate(time + 1);
    }
    int cnt;
    foreach(time, board2; board_rec) {
        foreach(row; board2) {
            foreach(elem; row) {
                cnt += elem == '#';
            }
        }
    }
    cnt.writeln;
}
