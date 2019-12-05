import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;


void main() {
    // input
    auto a = to!(int[])(split(strip(readln()), ','));

    int get_val(ref int mask, int[] a, int i) {
        int val = (mask % 10 == 1) ? a[i] : a[a[i]];
        mask /= 10;
        return val;
    }

    int program(int[] a, int[] input) {
        int[] output;
        int input_idx = 0;
        for (int i = 0; i < a.length;) {
            int instr = a[i];
            int op = instr % 100;
            instr /= 100;

            if (op == 1) {  // add
                int val1 = get_val(instr, a, i+1);
                int val2 = get_val(instr, a, i+2);
                a[a[i+3]] = val1 + val2;
                i += 4;
            } else if (op == 2) {  // multiply
                int val1 = get_val(instr, a, i+1);
                int val2 = get_val(instr, a, i+2);
                a[a[i+3]] = val1 * val2;
                i += 4;
            } else if (op == 3) {  // input
                a[a[i+1]] = input[input_idx++];
                i += 2;
            } else if (op == 4) {  // output
                output ~= get_val(instr, a, i+1);
                i += 2;
            } else if (op == 5) {  // jump-if-true
                int val1 = get_val(instr, a, i+1);
                int val2 = get_val(instr, a, i+2);
                if (val1)
                    i = val2;
                else
                    i += 3;
            } else if (op == 6) { // jump-if-false
                int val1 = get_val(instr, a, i+1);
                int val2 = get_val(instr, a, i+2);
                if (!val1)
                    i = val2;
                else
                    i += 3;
            } else if (op == 7) {  // less than
                int val1 = get_val(instr, a, i+1);
                int val2 = get_val(instr, a, i+2);
                a[a[i+3]] = to!int(val1 < val2);
                i += 4;
            } else if (op == 8) {  // equals
                int val1 = get_val(instr, a, i+1);
                int val2 = get_val(instr, a, i+2);
                a[a[i+3]] = to!int(val1 == val2);
                i += 4;
            } else if (op == 99) {
                break;
            } else {
                writeln("Alert!");
                writeln(instr * 100 + op);
                break;
            }
        }
        return output[output.length-1];
    }

    // star 1
    writeln(program(a.dup, [1]));
    // star 2
    writeln(program(a.dup, [5]));
}
