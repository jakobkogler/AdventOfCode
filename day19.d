#!/usr/bin/env dub
/+ dub.sdl:
    name "day19"
    dependency "cyk" version="~>1.1.0"
    stringImportPaths "."
+/
// run with dub --build=release --single day19.d <input/day19.in

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
    messages.map!(msg => cyk.check(msg)).array.sum.writeln;

    // Star 2
    rules = rules.replace("8: 42", "8: 42 | 42 8")
                 .replace("11: 42 31", "11: 42 31 | 42 11 31");
    cyk = buildCYK(rules);
    messages.map!(msg => cyk.check(msg)).sum.writeln;
}
