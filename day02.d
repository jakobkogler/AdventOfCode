import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;


void main() {
    // input
    auto a = to!(int[])(split(strip(readln()), ','));

    // star 1
    a[1] = 12;
    a[2] = 2;

    int[] program(int[] a) {
        for (int i = 0; i < a.length; i+=4) {
            if (a[i] == 1) {
                a[a[i+3]] = a[a[i+1]] + a[a[i+2]];
            } else if (a[i] == 2) {
                a[a[i+3]] = a[a[i+1]] * a[a[i+2]];
            } else if (a[i] == 99) {
                break;
            } else {
                writeln("Alert!");
                break;
            }
        }
        return a;
    }
    assert(program([1,9,10,3,2,3,11,0,99,30,40,50]) == [3500,9,10,70,2,3,11,0,99,30,40,50]);
    assert(program([1,0,0,0,99]) == [2,0,0,0,99]);
    assert(program([2,3,0,3,99]) == [2,3,0,6,99]);
    assert(program([2,4,4,5,99,0]) == [2,4,4,5,99,9801]);
    assert(program([1,1,1,4,99,5,6,0,99]) == [30,1,1,4,2,5,6,0,99]);
    writeln(program(a.dup)[0]);

    // star 2
    for (int noun = 0; noun < a.length; noun++) {
        for (int verb = 0; verb < a.length; verb++) {
            a[1] = noun;
            a[2] = verb;
            if (program(a.dup)[0] == 19690720)
                writeln(100 * noun + verb);
        }
    }
}
