import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;
import std.range;

T[][] combinations(T)(in T[] arr, in int k) pure nothrow {
    if (k == 0)
        return [[]];
    typeof(return) result;
    foreach (immutable i, immutable x; arr) {
        foreach (suffix; arr[i + 1 .. $].combinations(k - 1)) {
            result ~= x ~ suffix;
        }
    }
    return result;
}

T prod_with_sum(T)(in T[] arr, in int k) pure {
    return arr.combinations(k)
              .filter!(tup => tup.sum == 2020)
              .front
              .reduce!((a, b) => a * b);
}

void main() {
    // Input
    int[] a;
    string line;
    while ((line = readln()) !is null) {
        a ~= to!int(strip(line));
    }

    // Star 1
    a.prod_with_sum(2).writeln;

    // Star 2
    a.prod_with_sum(3).writeln;
}
