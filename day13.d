import std.algorithm;
import std.stdio;
import std.conv;
import std.string;
import std.math;
import std.numeric;
import std.range;
import core.thread;

import IntCodeProgram;
import Point2D;

enum Tile { EMPTY=0, WALL=1, BLOCK=2, HPADDLE=3, BALL=4 }

struct Game {
    Program program;
    Tile[Point] board;
    int score;
    
    void continue_run() {
        program.continue_run();

        foreach(tile_spec; program.output.chunks(3)) {
            auto x = tile_spec[0];
            auto y = tile_spec[1];
            auto tile_id = tile_spec[2];
            if (x == -1 && y == 0) {
                score = to!int(tile_id);
            } else {
                board[Point(x, y)] = to!Tile(tile_id);
            }
        }
        program.output.length = 0;
    }

    void input(int inp) {
        program.input ~= inp;
    }

    bool finished() {
        return program.finished;
    }

    void drawGame() {
        Point mi, ma;
        foreach(p, tile; board) {
            mi.x = min(mi.x, p.x);
            ma.x = max(ma.x, p.x);
            mi.y = min(mi.y, p.y);
            ma.y = max(ma.y, p.y);
        }
        
        foreach(_; 0 .. 10)
            writeln();
        writefln("Score %d", score);
        foreach(y; mi.y .. ma.y+1) {
            foreach(x; mi.x .. ma.x+1) {
                int color = board.get(Point(x, y), Tile.EMPTY);
                string colors = " WB-*";
                write(colors[color]);
            }
            writeln();
        }
    }

    Point get(Tile tile) const {
        return (board.byPair.filter!(pair => pair.value == tile).array)[0].key;
    }
}


void main() {
    auto a = to!(long[])(split(strip(readln()), ','));

    // star 1
    auto game = Game(new Program(a));
    game.continue_run();
    writeln(game.board.byValue.count(Tile.BLOCK));

    // star 2
    game = Game(new Program(a));
    game.program.a[0] = 2;

    while(!game.finished) {
        game.continue_run();
        debug game.drawGame();
        debug Thread.sleep(1.seconds);

        auto paddle = game.get(Tile.HPADDLE);
        auto ball = game.get(Tile.BALL);
        game.input((ball.x - paddle.x).sgn);
    }
    writeln(game.score);
}
