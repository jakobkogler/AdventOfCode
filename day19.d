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

/// A → BC
struct Production {
    int left;
    int right1, right2;
}

/// A -> a
struct UnitProduction {
    int left;
    char right;
}

/// A -> a
struct SingleProduction {
    int left;
    int right;
}

class CYK {
    Production[] productions;
    UnitProduction[] unitProductions;
    SingleProduction[] singleProductions;
    int S;

    void addRule(string rule) {
        auto sides = rule.split(": ");
        int left = sides[0].to!int;
        auto right = sides[1];
        if (right.startsWith("\"")) {
            unitProductions ~= UnitProduction(left, right[1]);
        } else {
            foreach (rightPossibility; right.split(" | ")) {
                auto tmp = rightPossibility.split(" ");
                if (tmp.length == 1)
                    singleProductions ~= SingleProduction(left, tmp[0].to!int);
                else if (tmp.length == 2)
                    productions ~= Production(left, tmp[0].to!int, tmp[1].to!int);
                else
                    assert(false, "right side with more than 2 nonterminal are not supported");
            }
        }
    }

    void normalize() {
        // kinda inefficient, but good enough for our input
        // also doesn't work if there are multiple interleaving single productions
        void replace(T)(SingleProduction singleProduction, ref T[] productions) {
            foreach (production; productions) {
                if (singleProduction.right == production.left) {
                    production.left = singleProduction.left;
                    productions ~= production;
                }
            }
        }

        foreach (singleProduction; singleProductions) {
            replace(singleProduction, productions);
            replace(singleProduction, unitProductions);
        }
    }

    bool check(string word) {
        int n = word.length.to!int;
        int r = max(productions.map!"a.left".maxElement, singleProductions.map!"a.left".maxElement) + 1;
        bool[][][] P = new bool[][][](n, n, r);
        foreach (s, c; word) {
            foreach (unitProduction; unitProductions) {
                if (unitProduction.right == c)
                    P[0][s][unitProduction.left] = true;
            }
        }

        foreach (l; 2 .. n+1) {
            foreach (s; 0 .. n-l+1) {
                foreach (p; 1 .. l) {
                    foreach (production; productions) {
                        if (P[p-1][s][production.right1] && P[l-p-1][s+p][production.right2])
                            P[l-1][s][production.left] = true;
                    }
                }
            }
        }

        return P[n-1][0][S];
    }
}

void main() {
    // Input
    auto ruleStrings = getInputLines;
    auto messages = getInputLines;

    int countInGrammar(string[] messages, string[] ruleStrings) {
        auto cyk = new CYK;
        foreach (line; ruleStrings) {
            cyk.addRule(line);
        }
        cyk.normalize;
        cyk.S = 0;
        return messages.map!(msg => cyk.check(msg)).sum;
    }

    // Star 1
    countInGrammar(messages, ruleStrings).writeln;

    // Star 2
    ruleStrings = ruleStrings.replace("8: 42", "8: 42 | 42 8");
    ruleStrings = ruleStrings.replace("11: 42 31", "11: 42 31 | 42 132");
    ruleStrings ~= "132: 11 31";
    countInGrammar(messages, ruleStrings).writeln;

}
