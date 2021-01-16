#!/usr/bin/env dub
/+ dub.sdl:
    name "day19"
    dependency "cyk" version="~>1.0.0"
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

import cyk : CYK;

auto getInputLines() {
    return generate!(() => readln.strip).until(null).array;
}

auto buildCYK(string[] rules) {
    return new CYK(rules.map!(rule => rule.replace(":", "→")).array, "0");
}

void main() {
    // read input file at compile time
    auto rules = getInputLines;
    const messages = getInputLines;

    // Star 1
    auto cyk = buildCYK(rules);
    messages.map!(message => cyk.check(message.map!(to!string).array)).sum.writeln;

    // Star 2
    rules.remove!(rule => rule == "8: 42" || rule == "11: 42 31");
    rules ~= ["8: 42 | 42 8", "11: 42 31 | 42 11 31"];
    cyk = buildCYK(rules);
    messages.map!(message => cyk.check(message.map!(to!string).array)).sum.writeln;
}
