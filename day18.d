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

long evaluate(string s) {
    s = s.replace(" ", "");
    ulong idx = 0;
    debug writeln;
    debug writeln(s, ":");

    long recEvaluate(int depth) {
        debug writeln(' '.repeat.take(depth * 2), "start recursion: ");
        // get number 1
        long number1;
        if (s[idx] == '(') {
            idx++;
            number1 = recEvaluate(depth + 1);
        } else {
            number1 = s[idx] - '0';
            idx++;
        }
        debug writeln(' '.repeat.take(depth * 2), "number1: ", number1);

        while (idx < s.length && s[idx] != ')') {
            // operation
            char operation = s[idx];
            idx++;
            debug writeln(' '.repeat.take(depth * 2), "operation: ", operation);

            // get number 2
            long number2;
            if (s[idx] == '(') {
                idx++;
                number2 = recEvaluate(depth + 1);
            } else {
                number2 = s[idx] - '0';
                idx++;
            }
            debug writeln(' '.repeat.take(depth * 2), "number2: ", number2);

            // do operation
            debug write(' '.repeat.take(depth * 2), number1, " ", operation, " ", number2, " = ");
            if (operation == '+') {
                number1 += number2;
            } else if (operation == '*') {
                number1 *= number2;
            }
            debug writeln(number1);
        }

        if (idx < s.length && s[idx] == ')') {
            idx++;
        }
        return number1;
    }
    return recEvaluate(1);
}

void main() {
    // Input
    auto lines = getInputLines;

    // Star 1
    lines.map!evaluate.sum.writeln;

    // Star 2
}
