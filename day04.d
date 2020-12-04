import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;
import std.range;
import std.regex;
import std.typecons;

string[] getInputLines() {
    string[] lines;
    string line;
    while ((line = readln()) !is null) {
        lines ~= line.strip;
    }
    return lines;
}

void main() {
    // Input
    string[] lines = getInputLines();

    alias Passport = string[string];
    Passport[] passports;
    foreach (block; lines.split("")) {
        Passport passport;
        foreach (line; block) {
            foreach (key_value; line.split(" ")) {
                auto tmp = key_value.split(":");
                passport[tmp[0]] = tmp[1];
            }
        }
        passports ~= passport;
    }

    // Star 1
    bool isPassportValid(Passport passport) {
        static required_fields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"].sort;
        return equal(setIntersection(passport.keys.sort, required_fields), required_fields);
    }

    passports.map!isPassportValid.sum.writeln;

    // Star 2
    bool checkYear(string year, int min_year, int max_year) {
        return match(year, r"^\d{4}$") && to!int(year) >= min_year && to!int(year) <= max_year;
    }

    bool checkHeight(string height, string height_suffix, int min_height, int max_height) {
        auto m = match(height, r"^(\d+)" ~ height_suffix ~ "$");
        if (!m)
            return false;
        const h = to!int(m.captures[1]);
        return min_height <= h && h <= max_height;
    }

    bool isPassportValidDetails(Passport passport) {
        static required_fields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"].sort;
        return equal(setIntersection(passport.keys.sort, required_fields), required_fields)
            && checkYear(passport["byr"], 1920, 2002)
            && checkYear(passport["iyr"], 2010, 2020)
            && checkYear(passport["eyr"], 2020, 2030)
            && (checkHeight(passport["hgt"], "cm", 150, 193) || checkHeight(passport["hgt"], "in", 59, 76))
            && match(passport["hcl"], r"^#[0-9a-f]{6}$")
            && match(passport["ecl"], r"^(amb|blu|brn|gry|grn|hzl|oth)$")
            && match(passport["pid"], r"^\d{9}$");
    }

    passports.map!isPassportValidDetails.sum.writeln;
}
