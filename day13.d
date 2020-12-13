import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;
import std.range;
import std.regex;
import std.typecons;
import std.functional;
import std.math;

auto getInputLines() {
    return generate!(() => readln.strip).until(null).array;
}

auto modularInverse(long x, long mod) {
    // assuming that mod is prime
    return powmod(to!ulong(x % mod), to!ulong(mod-2), to!ulong(mod));
}

struct Congruence {
    this(long remainder, long mod) {
        this.remainder = ((remainder % mod) + mod) % mod;
        this.mod = mod;
    }

    long remainder;
    long mod;
}

void main() {
    // Input
    auto lines = getInputLines;

    // Star 1
    const earliestTimestamp = to!long(lines[0]);
    auto ids = lines[1].replace("x", "").split(regex(`,+`)).map!(to!long).array;
    auto minutesToWait = (long id) => (id - earliestTimestamp % id) % id;

    auto best = ids.minElement!minutesToWait;
    (best * minutesToWait(best)).writeln;

    // Star 2
    ids = lines[1].replace("x", "1").split(",").map!(to!long).array;
    // x + 0 = 0 mod id0
    // x + 1 = 0 mod id1
    // x + 2 = 0 mod id2
    //    =>
    // x = 0 mod id0
    // x = -1 mod id1
    // x = -2 mod id2
    auto congruences = ids.enumerate
                          .map!(c => Congruence(-c.index, c.value))
                          .filter!`a.mod != 1`
                          .array;

    // chinese remainder theorem
    long result;
    auto M = ids.reduce!`a * b`;
    foreach (congruence; congruences) {
        const a = congruence.remainder;
        const b = M / congruence.mod;
        const c = modularInverse(b, congruence.mod);
        result += a * b % M * c % M;
        result %= M;
    }
    result.writeln;
}
