import std.stdio;
import std.conv;
import std.algorithm;
import std.string;
import std.range;
import std.regex;
import std.math;

auto getInputLines() {
    return generate!(() => readln.strip).until(null).array;
}

void main() {
    // Input
    auto publicKeys = getInputLines.map!(to!uint).array;

    // Star 1
    uint[] loopSizes = new uint[publicKeys.length];
    const uint mod = 20201227;
    ulong p = 1;
    foreach (i; 1 .. mod) {
        p = p * 7 % mod;
        if (publicKeys.canFind(p)) {
            loopSizes[publicKeys.countUntil(p)] = i;
        }
    }
    powmod(7u, loopSizes.reduce!`a.to!ulong*b`, mod).writeln;
}
