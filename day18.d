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

void processOp(ref long[] st, char op) {
    auto r = st.back;
    st.popBack;
    auto l = st.back;
    st.popBack;
    if (op == '+')
        st ~= l + r;
    if (op == '*')
        st ~= l * r;
}

long evaluate(string s, int[char] priority) {
    debug writeln(s, ":");
    long[] st;
    char[] op;
    foreach (i, char c; s) {
        if (c == ' ')
            continue;

        debug writeln("stack: ", st);
        debug writeln("ops:   \"", op, "\"");
        debug writeln("current char: ", c);
        if (c == '(') {
            op ~= c;
        } else if (c == ')') {
            while (op.back != '(') {
                debug writeln("  last operation: ", op.back);
                processOp(st, to!char(op.back));
                op.popBack;
                debug writeln("  ", st);
                debug writeln("  ", op);
            }
            op.popBack;
        } else if (c == '+' || c == '*') {
            while (!op.empty && op.back != '(' && priority[to!char(op.back)] >= priority[c]) {
                processOp(st, to!char(op.back));
                op.popBack;
            }
            op ~= c;
        } else {
            st ~= c - '0';
        }
        debug writeln;
    }
    while (!op.empty) {
        processOp(st, to!char(op.back));
        op.popBack;
    }
    debug writeln("return ", st);
    return st[0];
}

void main() {
    // Input
    const lines = getInputLines;

    // Star 1
    lines.map!(line => line.evaluate(['+': 1, '*': 1])).sum.writeln;

    // Star 2
    lines.map!(line => line.evaluate(['+': 2, '*': 1])).sum.writeln;
}
