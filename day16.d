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

struct Range {
    int from, to;

    bool valid(int x) {
        return from <= x && x <= to;
    }
}

struct Rule {
    this(string rule) {
        static const re = ctRegex!`(.+): (\d+)-(\d+) or (\d+)-(\d+)`;
        auto m = match(rule, re);
        name = m.captures[1];
        ranges[0] = Range(to!int(m.captures[2]), to!int(m.captures[3]));
        ranges[1] = Range(to!int(m.captures[4]), to!int(m.captures[5]));
    }
    string name;
    Range[2] ranges;

    bool valid(int x) {
        return ranges[0].valid(x) || ranges[1].valid(x);
    }
}

struct Ticket {
    this(string ticket) {
        fields = ticket.split(",").map!(to!int).array;
    }

    int[] fields;
    alias fields this;
}

void main() {
    // Input
    auto rules = getInputLines.map!(to!Rule).array;
    auto myTicket = getInputLines[1].to!Ticket;
    auto nearbyTickets = getInputLines[1..$].map!(to!Ticket).array;

    // Star 1
    int invalid = 0;
    Ticket[] validTickets;
    foreach (ticket; nearbyTickets) {
        bool isInvalid = false;
        foreach (x; ticket.fields) {
            if (rules.all!(rule => !rule.valid(x))) {
                invalid += x;
                isInvalid = true;
            }
        }
        if (!isInvalid)
            validTickets ~= ticket;
    }
    invalid.writeln;

    // Star 2
    const N = rules.length;
    alias FieldIds = int[];
    FieldIds[Rule] possible;
    foreach (ruleId, rule; rules) {
        foreach (fieldId; 0 .. N) {
            if (validTickets.all!(ticket => rule.valid(ticket[fieldId])))
                possible[rule] ~= to!int(fieldId);
        }
    }
    auto tmp = possible.byPair.array;
    int[Rule] assignment;
    while (tmp.any!(rulePoss => rulePoss.value.length == 1)) {
        auto one = tmp.find!((rulePoss, one) => rulePoss.value.length == one)(1).front;
        const idx = one.value[0];
        assignment[one.key] = idx;
        foreach (ref pair; tmp) {
            pair.value = pair.value.filter!(a => a != idx).array;
        }
    }

    long result = 1;
    foreach (rule; rules) {
        if (rule.name.startsWith("departure"))
            result *= myTicket[assignment[rule]];
    }
    result.writeln;
}
