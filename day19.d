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

class Rule {
    abstract bool match(string s, int level = 0);
    abstract int[] lengths();

    int[] _lengths;
    int[] getLengths() {
        if (_lengths.empty)
            _lengths = lengths();
        return _lengths;
    }
}

Rule[int] rules;

bool matchAnd(int[] lst, string s, int level) {
    if (lst.length == 1)
        return rules[lst[0]].match(s);

    /* foreach (l1; 1 .. s.length) { */
    auto l1 = rules[lst[0]].getLengths[0];
        if (rules[lst[0]].match(s[0 .. l1], level + 1) && matchAnd(lst[1..$], s[l1..$], level + 1))
            return true;
    /* } */
    return false;
}

int[] combinationLengths(int[][] lst) {
    if (lst.length == 1)
        return lst[0];

    auto tmp = combinationLengths(lst[1..$]);
    int[] x;
    foreach (v; lst[0]) {
        foreach (w; tmp) {
            x ~= v + w;
        }
    }
    return x.sort.uniq.array;
}

class AndRule : Rule {
    this(int[] lst) {
        this.lst = lst;
    }

    int[] lst;

    override string toString() {
        return "AndRule(" ~ lst.map!(to!string).join(", ") ~ ")";
    }

    override bool match(string s, int level) {
        debug writeln("  ".repeat(level).join("") ~ "Try to match " ~ this.toString ~ " with \"" ~ s ~ "\"");
        return matchAnd(lst, s, level);
    }

    override int[] lengths() {
        return combinationLengths(lst.map!(idx => rules[idx].getLengths).array);
    }
}

class OrRule : Rule {
    this(Rule[2] lst) {
        this.lst = lst;
    }

    Rule[2] lst;

    override string toString() {
        return "OrRule(" ~ lst[0].toString ~ ", " ~ lst[1].toString ~ ")";
    }

    override bool match(string s, int level) {
        debug writeln("  ".repeat(level).join("") ~ "Try to match " ~ this.toString ~ " with \"" ~ s ~ "\"");
        return lst[0].match(s, level + 1) || lst[1].match(s, level + 1);
    }

    override int[] lengths() {
        int[] ls = lst[0].getLengths ~ lst[1].getLengths;
        return ls.sort.uniq.array;
    }
}

class CharRule : Rule {
    this(char c) {
        this.c = c;
    }

    char c;

    override string toString() {
        return "CharRule(\"" ~ c ~ "\")";
    }

    override bool match(string s, int level) {
        debug writeln("  ".repeat(level).join("") ~ "Try to match " ~ this.toString ~ " with \"" ~ s ~ "\"");
        return s.length == 1 && s[0] == c;
    }

    override int[] lengths() {
        return [1];
    }
}

Rule parseRule(string s) {
    if (s.startsWith("\"")) {
        return new CharRule(s[1]);
    }
    if (s.indexOf(" | ") >= 0) {
        auto tmp = s.split(" | ");
        return new OrRule([parseRule(tmp[0]), parseRule(tmp[1])]);
    }
    auto tmp = s.split(" ");
    return new AndRule(tmp.map!(to!int).array);
}

void main() {
    // Input
    auto ruleStrings = getInputLines;
    auto messages = getInputLines;

    foreach (line; ruleStrings) {
        auto tmp = line.split(": ");
        rules[to!int(tmp[0])] = parseRule(tmp[1]);
    }
    debug rules.writeln;

    // Star 1

    messages.map!(msg => rules[0].match(msg)).sum.writeln;

    // Star 2
    bool matchLoops(string msg) {
        int l1 = rules[42].getLengths[0];
        int l2 = rules[31].getLengths[0];
        foreach (i; 1 .. msg.length / l1 + 1) {
            int j = to!int((to!int(msg.length) - i * l1) / l2);
            if (i * l1 + j * l2 == msg.length && i > j && j > 0) {
                debug writeln(i, "*", l1, " + ", j, "*", l2, " = ", msg.length);
                bool success = true;
                foreach (I; 0 .. i) {
                    success &= rules[42].match(msg[l1*I .. l1*(I+1)]);
                }
                foreach (J; 0 .. j) {
                    success &= rules[31].match(msg[l1*i + l2*J .. l1*i + l2*(J+1)]);
                }
                if (success)
                    return true;
            }
        }
        return false;
    }

    messages.map!matchLoops.sum.writeln;
}
