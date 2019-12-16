import std.stdio;
import std.range;
import std.algorithm;
import std.conv;
import std.string;
import std.math;

int[] fft(int[] arr) {
    int[] psum = [0] ~ arr.cumulativeFold!"a + b"(0).array;
    int sum(long l, long r) { // inclusive
        r = min(psum.length - 2, r);
        return psum[r+1] - psum[l];
    }

    int[] output;
    foreach(i; 1 .. arr.length+1) {
        long idx = i - 1;
        int sign = 1;
        int cur_sum;
        while (idx < arr.length) {
            cur_sum += sign * sum(idx, idx + i - 1);
            idx += 2*i;
            sign = 0 - sign;
        }
        output ~= cur_sum;
    }

    return output.map!"a.abs % 10".array;
}

void main() {
    auto input = readln().strip;
    auto numbers = input.map!`to!int(a-'0')`.array;

    // star 1
    auto star1 = numbers.dup;
    foreach(_; 0 .. 100) {
        star1 = fft(star1);
    }
    writeln(star1[0..8].map!(to!string).join);

    // star 2
    auto star2 = numbers.cycle.take(10_000 * numbers.length).array;
    foreach(_; 0 .. 100) {
        writeln(_);
        star2 = fft(star2);
    }
    writeln(star2[to!int(input[0..7])..$][0..8].map!(to!string).join);
}
