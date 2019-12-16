import std.stdio;
import std.range;
import std.algorithm;
import std.conv;
import std.string;
import std.math;

string fft(string input) {
    auto arr = input.map!`to!int(a-'0')`.array;
    return
        arr.length.iota
            .map!(i =>
                 zip(arr,
                     [0, 1, 0, -1]
                     .map!(a => a.repeat(i + 1))
                     .joiner
                     .cycle
                     .dropOne
                    )
                    .map!(x => x[0] * x[1]).sum.abs % 10
                )
            .map!(to!string).join;
}

void main() {
    string number = readln().strip;

    foreach(_; 0 .. 100) {
        number = fft(number);
    }
    writeln(number[0..8]);
}
