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

bool hasSumPair(T)(in T[] arr, in int k, in long target) pure {
    return arr.combinations(k)
              .filter!(tup => tup.sum == target).any;
}

bool isValid(Range)(Range r) {
    auto arr = r.array;
    return hasSumPair(arr.dropBackOne, 2, arr[$-1]);
}

void main() {
    // Input
    auto numbers = getInputLines().map!(to!long).array;

    // Star 1
    const invalid = numbers.slide(26).filter!(a => !isValid(a)).front[$-1];
    invalid.writeln;

    // Star 2
    int[long] prefixes;
    prefixes[0] = 0;
    long psum = 0;
    foreach (i, elem; numbers) {
        psum += elem;
        auto loc = (psum - invalid) in prefixes;
        if (loc && elem != invalid) {
            const arr = numbers[*loc .. i+1];
            (arr.minElement + arr.maxElement).writeln;
        }
        prefixes[psum] = to!int(i + 1);
    }
}
