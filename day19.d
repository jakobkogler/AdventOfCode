#!/usr/bin/env dub
/+ dub.sdl:
    name "day19"
    dependency "pegged" version="~>0.4.4"
    stringImportPaths "."
+/

import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;
import std.range;
import std.regex;
import std.typecons;
import pegged.grammar;

string prepairRule(string s) {
    string result;
    char last = ' ';
    foreach (c; s) {
        if (c >= '0' && c <= '9') {
            if (last == ' ')
                result ~= 'R';
            result ~= c;
        } else if (c == '|') {
            result ~= '/';
        } else if (c == ':') {
            result ~= ' ';
            result ~= '<';
            result ~= '-';
        } else {
            result ~= c;
        }
        last = c;
    }
    return result;
}

bool checkGrammar(Grammar)(string msg) {
    auto tree = Grammar(msg);
    return tree.successful && tree.begin == 0 && tree.end == msg.length;
}

void main() {
    // read input file at compile time
    const foo = import("input/day19.in").split("\n");
    const rulesAndMessages = foo.split("");
    const ruleStrings = rulesAndMessages[0];
    const messages = rulesAndMessages[1];

    // Star 1
    mixin(grammar("Star1:\n" ~ ruleStrings.map!prepairRule.array.sort.join("\n")));
    messages.map!(checkGrammar!Star1).sum.writeln;
}
