import std.stdio;
import std.conv;
import std.algorithm;
import std.string;
import std.range;
import std.regex;

auto getInputLines() {
    return generate!(() => readln.strip).until(null).array;
}

int[] performMove(int[] arr) {
    int cur = arr[0];
    int[] pickUp = arr[1..4];
    int mx = arr.maxElement;
    int f(int x) {
        if (x < cur) return x;
        return x - mx;
    }
    auto next = arr[4..$].maxIndex!((a, b) => f(a) < f(b)) + 4;
    return arr[4..next] ~ arr[next] ~ pickUp ~ arr[next+1..$] ~ cur;
}

string output(int[] arr) {
    auto idx = arr.countUntil!(c => c == 1);
    bringToFront(arr[0..idx], arr[idx..$]);
    return arr.map!(to!string).join[1..$];
}

void main() {
    // Input
    auto lstOrig = readln.strip.map!"(a - '0').to!int".array;

    // Star 1
    auto lst = lstOrig.dup;
    foreach (i; 0..100) {
        lst = lst.performMove;
    }
    lst.output.writeln;
}
