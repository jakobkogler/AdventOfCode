import std.stdio;
import std.conv;


class Program {
    long[long] a;
    long i;
    long[] input;
    long[] output;
    int input_idx;
    bool finished;
    long relative_base;
    this(long[] a) {
        foreach(i, e; a) {
            this.a[i] = e;
        }
        this.i = 0;
        this.input_idx = 0;
        this.finished = false;
        this.relative_base = 0;
    }

    long get_val(ref long mask, long i) {
        long val;
        switch(mask % 10) {
            case 0:
                val = a.get(a.get(i, 0), 0);
                break;
            case 1:
                val = a.get(i, 0);
                break;
            case 2:
                val = a.get(relative_base + a.get(i, 0), 0);
                break;
            default:
                assert(0);
        }
        mask /= 10;
        return val;
    }

    long get_addr(ref long mask, long i) {
        long addr;
        switch(mask % 10) {
            case 0:
                addr = a.get(i, 0);
                break;
            case 1:
                assert(0, "value instead of addr");
            case 2:
                addr = relative_base + a.get(i, 0);
                break;
            default:
                assert(0);
        }
        mask /= 10;
        return addr;
    }

    void continue_run() {
        while (!finished) {
            long instr = a[i];
            int op = instr % 100;
            instr /= 100;

            if (op == 1) {  // add
                long val1 = get_val(instr, i+1);
                long val2 = get_val(instr, i+2);
                long addr = get_addr(instr, i+3);
                a[addr] = val1 + val2;
                debug writeln(val1, " + ", val2, " = ", a[addr]);
                i += 4;
            } else if (op == 2) {  // multiply
                long val1 = get_val(instr, i+1);
                long val2 = get_val(instr, i+2);
                long addr = get_addr(instr, i+3);
                a[addr] = val1 * val2;
                debug writeln(val1, " * ", val2, " = ", a[addr]);
                i += 4;
            } else if (op == 3) {  // input
                if (input_idx == input.length)
                    break;
                long addr = get_addr(instr, i+1);
                a[addr] = input[input_idx++];
                debug writeln("input = ", a[addr]);
                i += 2;
            } else if (op == 4) {  // output
                output ~= get_val(instr, i+1);
                i += 2;
            } else if (op == 5) {  // jump-if-true
                long val1 = get_val(instr, i+1);
                long val2 = get_val(instr, i+2);
                if (val1)
                    i = val2;
                else
                    i += 3;
            } else if (op == 6) { // jump-if-false
                long val1 = get_val(instr, i+1);
                long val2 = get_val(instr, i+2);
                if (!val1)
                    i = val2;
                else
                    i += 3;
            } else if (op == 7) {  // less than
                long val1 = get_val(instr, i+1);
                long val2 = get_val(instr, i+2);
                debug writeln("test ", val1, "<", val2);
                long addr = get_addr(instr, i+3);
                a[addr] = to!long(val1 < val2);
                i += 4;
            } else if (op == 8) {  // equals
                long val1 = get_val(instr, i+1);
                long val2 = get_val(instr, i+2);
                long addr = get_addr(instr, i+3);
                debug writeln("test ", val1, "==", val2);
                a[addr] = to!long(val1 == val2);
                i += 4;
            } else if (op == 9) {
                long val1 = get_val(instr, i+1);
                relative_base += val1;
                debug writeln(" rel: ", relative_base);
                i += 2;
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
