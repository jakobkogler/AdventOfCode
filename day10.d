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
    auto numbers = getInputLines().map!(to!long).array;
    numbers ~= 0;
    numbers ~= numbers.maxElement + 3;

    // Star 1
    auto byCounts = numbers.sort.slide(2).map!`a[1]-a[0]`.array.sort.group.assocArray;
    byCounts.writeln;
    (byCounts[1] * byCounts[3]).writeln;

    // Star 2
    long[] dp = new long[numbers.length];
    dp[0] = 1;
    foreach (i; 1 .. numbers.length) {
        long j = i - 1;
        while (j >= 1 && numbers[i] - numbers[j] <= 3) {
            dp[i] += dp[j];
            j--;
        }
    }
    dp[$-1].writeln;
}
