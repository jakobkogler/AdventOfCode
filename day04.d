import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;


void main() {
    int a = 245318;
    int b = 765747;

    int star1 = 0;
    int star2 = 0;
    foreach(i; a..b+1) {
        char last = '0';
        string s = to!string(i);
        bool sorted = true;
        foreach(c; s) {
            sorted &= last <= c;
            last = c;
        }

        int[char] cnts;
        foreach(c; s) {
            cnts[c]++;
        }

        if (sorted && cnts.length < 6)
            star1++;
        if (sorted && cnts.values.canFind(2))
            star2++;
    }
        
    writeln(star1);
    writeln(star2);
}
