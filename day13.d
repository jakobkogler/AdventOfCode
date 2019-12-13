import std.algorithm;
import std.stdio;
import std.conv;
import std.string;
import std.math;
import std.numeric;
import std.range;
import core.thread;


class Program {
    long[long] a;
    long i;
    long[] input;
    long[] output;
    int input_idx;
    bool finished;
    long relative_base;
    this(long[] a) {
        foreach(i, e; a) {
            this.a[i] = e;
        }
        this.i = 0;
        this.input_idx = 0;
        this.finished = false;
        this.relative_base = 0;
    }

    long get_val(ref long mask, long i) {
        long val;
        switch(mask % 10) {
            case 0:
                val = a.get(a.get(i, 0), 0);
                break;
            case 1:
                val = a.get(i, 0);
                break;
            case 2:
                val = a.get(relative_base + a.get(i, 0), 0);
                break;
            default:
                assert(0);
        }
        mask /= 10;
        return val;
    }

    long get_addr(ref long mask, long i) {
        long addr;
        switch(mask % 10) {
            case 0:
                addr = a.get(i, 0);
                break;
            case 1:
                assert(0, "value instead of addr");
            case 2:
                addr = relative_base + a.get(i, 0);
                break;
            default:
                assert(0);
        }
        mask /= 10;
        return addr;
    }

    void continue_run() {
        while (!finished) {
            long instr = a[i];
            int op = instr % 100;
            instr /= 100;

            if (op == 1) {  // add
                long val1 = get_val(instr, i+1);
                long val2 = get_val(instr, i+2);
                long addr = get_addr(instr, i+3);
                a[addr] = val1 + val2;
                debug writeln(val1, " + ", val2, " = ", a[addr]);
                i += 4;
            } else if (op == 2) {  // multiply
                long val1 = get_val(instr, i+1);
                long val2 = get_val(instr, i+2);
                long addr = get_addr(instr, i+3);
                a[addr] = val1 * val2;
                debug writeln(val1, " * ", val2, " = ", a[addr]);
                i += 4;
            } else if (op == 3) {  // input
                if (input_idx == input.length)
                    break;
                long addr = get_addr(instr, i+1);
                a[addr] = input[input_idx++];
                debug writeln("input = ", a[addr]);
                i += 2;
            } else if (op == 4) {  // output
                output ~= get_val(instr, i+1);
                i += 2;
            } else if (op == 5) {  // jump-if-true
                long val1 = get_val(instr, i+1);
                long val2 = get_val(instr, i+2);
                if (val1)
                    i = val2;
                else
                    i += 3;
            } else if (op == 6) { // jump-if-false
                long val1 = get_val(instr, i+1);
                long val2 = get_val(instr, i+2);
                if (!val1)
                    i = val2;
                else
                    i += 3;
            } else if (op == 7) {  // less than
                long val1 = get_val(instr, i+1);
                long val2 = get_val(instr, i+2);
                debug writeln("test ", val1, "<", val2);
                long addr = get_addr(instr, i+3);
                a[addr] = to!long(val1 < val2);
                i += 4;
            } else if (op == 8) {  // equals
                long val1 = get_val(instr, i+1);
                long val2 = get_val(instr, i+2);
                long addr = get_addr(instr, i+3);
                debug writeln("test ", val1, "==", val2);
                a[addr] = to!long(val1 == val2);
                i += 4;
            } else if (op == 9) {
                long val1 = get_val(instr, i+1);
                relative_base += val1;
                debug writeln(" rel: ", relative_base);
                i += 2;
            } else if (op == 99) {
                finished = true;
            } else {
                writeln("Alert!");
                writeln(instr * 100 + op);
                finished = true;
            }
        }
    }
}


struct Point {
    int x, y;

    this(int x, int y) {
        this.x = x;
        this.y = y;
    }

    this(long x, long y) {
        this.x = to!int(x);
        this.y = to!int(y);
    }

    Point opBinary(string op)(Vector v)
    if (op == "+" || op == "-")
    {
        Point p;
        p.x = mixin("this.x" ~ op ~ "v.x");
        p.y = mixin("this.y" ~ op ~ "v.y");
        return p;
    }

    unittest {
        auto p = Point(1, 2);
        auto v = Vector(3, 4);
        assert(p + v == Point(4, 6));
        assert(p - v == Point(-2, -2));
    }

    Point opOpAssign(string op)(Vector v)
    if (op == "+" || op == "-")
    {
        mixin("this.x" ~ op ~ "=v.x;");
        mixin("this.y" ~ op ~ "=v.y;");
        return this;
    }

    unittest {
        auto p = Point(1, 2);
        auto v = Vector(3, 4);
        p += v;
        assert(p == Point(4, 6));
        p += v;
        assert(p == Point(7, 10));
        p -= v;
        assert(p == Point(4, 6));
    }
}


struct Vector {
    int x, y;

    this(int x, int y) {
        this.x = x;
        this.y = y;
    }

    this(Point from, Point to) {
        x = to.x - from.x;
        y = to.y - from.y;
    }

    bool canBeSimplified() const {
        return gcd(abs(x), abs(y)) > 1;
    }

    double angle() const {
        double ang = atan2(to!double(y), to!double(x)) + PI_2;
        if (ang < 0)
            ang += 2 * PI;
        return ang;
    }
    unittest {
        assert(approxEqual(Vector(0, -1).angle, 0.));
        assert(approxEqual(Vector(1, 0).angle, PI_2));
        assert(approxEqual(Vector(0, 1).angle, PI));
        assert(approxEqual(Vector(-1, 0).angle, 3 * PI_2));
        assert(approxEqual(Vector(-1, -1).angle, 3 * PI_2 + PI_4));
    }
}


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
