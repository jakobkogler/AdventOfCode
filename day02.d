import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;
import std.range;
import std.regex;

struct PasswordLine {
    int min_occurences, max_occurences;
    char c;
    string password;
}

void main() {
    // Input
    PasswordLine[] passwordLines;
    string line;
    const lineRegex = ctRegex!r"^(\d+)-(\d+) (\w): (\w+)$";
    while ((line = readln()) !is null) {
        auto m = match(line.strip, lineRegex);
        passwordLines ~= PasswordLine(to!int(m.captures[1]),
                                      to!int(m.captures[2]),
                                      to!char(m.captures[3]),
                                      m.captures[4]);
    }

    // Star 1
    int valid = 0;
    foreach (pl; passwordLines) {
        const occurrences = pl.password.count(pl.c);
        if (pl.min_occurences <= occurrences && occurrences <= pl.max_occurences)
            valid++;
    }
    valid.writeln;

    // Star 2
    valid = 0;
    foreach (pl; passwordLines) {
        if ((pl.password[pl.min_occurences - 1] == pl.c) ^ (pl.password[pl.max_occurences - 1] == pl.c))
            valid ++;
    }
    valid.writeln;
}
