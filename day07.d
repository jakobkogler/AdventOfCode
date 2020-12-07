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

struct BagAmount {
    this(string amount, string bag) {
        this.amount = to!int(amount);
        this.bag = bag;
    }

    int amount;
    string bag;
}

struct Rule {
    string bag;
    BagAmount[] content;
}

auto parseRule(string ruleText) {
    const sides = ruleText.split(" bags contain ");
    const lhs = sides[0];
    auto rhs = sides[1].matchAll(r"(\d+)\s([^,]*) bags?").map!(m => BagAmount(m[1], m[2])).array;
    return Rule(lhs, rhs);
}

alias AdjacentBags = string[];
alias AdjacencyList = AdjacentBags[string];

void dfs(ref const AdjacencyList adj, string v, ref bool[string] visited) {
    if (v in visited)
        return;

    visited[v] = true;
    if (v in adj) {
        foreach (u; adj[v]) {
            dfs(adj, u, visited);
        }
    }
}

long countBags(ref const Rule[string] rules, string v) {
    long res = 1;
    foreach (amountBag; rules[v].content) {
        res += to!long(amountBag.amount) * countBags(rules, amountBag.bag);
    }
    return res;
}

void main() {
    // Input
    auto lines = getInputLines();
    auto rules = lines.map!parseRule;

    // Star 1
    AdjacencyList adjReverse;
    foreach (rule; rules) {
        foreach (inner_bag; rule.content) {
            adjReverse[inner_bag.bag] ~= rule.bag;
        }
    }
    bool[string] visited;
    string target = "shiny gold";
    dfs(adjReverse, target, visited);
    (visited.length - 1).writeln;

    // Star 2
    auto rulesAssoc = rules.map!(rule => tuple(rule.bag, rule)).assocArray;
    (countBags(rulesAssoc, target) - 1).writeln;
}
