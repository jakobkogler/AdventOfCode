import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;
import std.range;


class Program {
    int[] a;
    int i;
    int[] input;
    int[] output;
    int input_idx;
    bool finished;
    this(int[] a, int phase) {
        this.a = a.dup;
        this.i = 0;
        this.input_idx = 0;
        this.input ~= phase;
        this.finished = false;
    }

    int get_val(ref int mask, int[] a, int i) {
        int val = (mask % 10 == 1) ? a[i] : a[a[i]];
        mask /= 10;
        return val;
    }

    void continue_run() {
        while (!finished) {
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
                if (input_idx == input.length)
                    break;
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
                finished = true;
            } else {
                writeln("Alert!");
                writeln(instr * 100 + op);
                finished = true;
            }
        }
    }

}

void main() {
    // input
    auto a = to!(int[])(split(strip(readln()), ','));

    // star 1
    int amp_chain(int[] a, int[] seq) {
        int last_output = 0;
        foreach(inp; seq) {
            auto program = new Program(a.dup, inp);
            program.input ~= last_output;
            program.continue_run();
            last_output = program.output[$-1];
        }
        return last_output;
    }

    int max_amp_chain(int[] a) {
        int best = 0;
        int[] perm = [0, 1, 2, 3, 4];
        do {
            best = max(best, amp_chain(a.dup, perm));
        } while (nextPermutation(perm));
        return best;
    }

    assert(max_amp_chain([3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]) == 43210);
    assert(max_amp_chain([3,23,3,24,1002,24,10,24,1002,23,-1,23,
    101,5,23,23,1,24,23,23,4,23,99,0,0]) == 54321);
    assert(max_amp_chain([3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,
                1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]) == 65210);
    writeln(max_amp_chain(a.dup));

    // star 2
    int amp_chain_rep(int[] a, int[] seq) {
        Program[] programs;
        foreach(phase; seq) {
            programs ~= new Program(a, phase);
        }

        int last_output = 0;
        while (!programs[$-1].finished) {
            foreach(program; programs) {
                program.input ~= last_output;
                program.continue_run();
                last_output = program.output[$-1];
            }
        }
        return last_output;
    }

    assert(amp_chain_rep([3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,
            27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5], [9, 8, 7, 6, 5]) == 139629729);
    assert(amp_chain_rep([3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,
                -5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,
                53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10], [9, 7, 8, 5, 6]) == 18216);

    int max_amp_chain_rep(int[] a) {
        int best = 0;
        int[] perm = [5, 6, 7, 8, 9];
        do {
            best = max(best, amp_chain_rep(a.dup, perm));
        } while (nextPermutation(perm));
        return best;
    }

    assert(max_amp_chain_rep([3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,
            27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]) == 139629729);
    assert(max_amp_chain_rep([3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,
                -5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,
                53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10]) == 18216);
    writeln(max_amp_chain_rep(a.dup));
}
