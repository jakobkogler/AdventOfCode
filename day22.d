import std.stdio;
import std.string;
import std.algorithm;
import std.range;
import std.conv;
import std.math;
import std.typecons;
import std.bigint;

enum CARD_COUNT = 10007;
enum CARD_COUNT2 = 119315717514047;
enum MOD = CARD_COUNT2;

string[] readInstructions() {
    string[] instructions;
    string tmp;
    while ((tmp = readln()) !is null)
        instructions ~= tmp.strip();
    return instructions;
}

struct Cards {
    int[CARD_COUNT] cards;

    this(int _) {
        cards = CARD_COUNT.iota.array;
    }

    void dealIntoNewStack() {
        cards = cards.array.retro.array;
    }

    void dealWithIncrement(int increment) {
        int[CARD_COUNT] new_;
        foreach(i, e; cards) {
            new_[i*increment%CARD_COUNT] = e;
        }
        cards = new_;
    }

    void cut(int cut) {
        if (cut < 0)
            cut += cards.length;
        bringToFront(cards[0..cut], cards[cut..$]);
    }

    void doInstruction(string instruction) {
        auto words = instruction.split();
        switch(words[0]) {
            case "deal":
                if (words[1] == "into")
                    dealIntoNewStack();
                else
                    dealWithIncrement(to!int(words[$-1]));
                break;
            case "cut":
                cut(to!int(words[$-1]));
                break;
            default:
        }
    }
}

enum zero = BigInt(0);
enum one = BigInt(1);

struct X {
    BigInt factor = 1;
    BigInt summand = 0;
    // position = factor * init + summand;

    long eval(long init) {
        long res = (factor * init + summand) % MOD;
        if (res < 0)
            res += MOD;
        return res;
    }

    void revDealIntoNewStack() {
        factor = (-factor) % MOD;
        summand = (-summand - 1) % MOD;
    }

    void revIncrement(long count) {
        factor = (factor * inverse(count)) % MOD;
        summand = (summand * inverse(count)) % MOD;
    }

    void revCut(long count) {
        summand = (summand + count) % MOD;
    }

    void power(long e) {
        // (factor summand) * (init)  = (factor*init+summand)
        // (0      1      )   (1)     = (1)
        Matrix22 A = [[BigInt(factor), BigInt(summand)], [BigInt(0L), BigInt(1L)]];
        Matrix22 res = [[BigInt(1L), BigInt(0)], [BigInt(0), BigInt(1L)]];
        while (e) {
            if (e & 1)
                res = multMatrix(res, A);
            A = multMatrix(A, A);
            e >>= 1;
        }
        factor = res[0][0].toLong;
        summand = res[0][1].toLong;
    }
}

void main() {
    auto instructions = readInstructions();

    // star 1
    auto cards = Cards(0);
    foreach(instruction; instructions)
        cards.doInstruction(instruction);
    cards.cards.array.minIndex!`a == 2019`.writeln;

    // star 2
    X x;
    foreach(instruction; instructions.retro) {
        auto words = instruction.split();
        switch(words[0]) {
            case "deal":
                if (words[1] == "into")
                    x.revDealIntoNewStack;
                else
                    x.revIncrement(to!long(words[$-1]));
                break;
            case "cut":
                x.revCut(to!long(words[$-1]));
                break;
            default:
        }
    }

    x.power(101741582076661L);
    x.eval(2020).writeln;
}

BigInt inverse(long x) {
    return powmod(BigInt(x), BigInt(MOD-2), BigInt(MOD));
}

alias Matrix22 = BigInt[2][2];

Matrix22 multMatrix(Matrix22 A, Matrix22 B) {
    Matrix22 res;
    foreach(i; 0..2) {
        foreach(j; 0..2) {
            foreach(k; 0..2) {
                res[i][j] += A[i][k] * B[k][j];
            }
            res[i][j] %= MOD;
        }
    }
    return res;
}
