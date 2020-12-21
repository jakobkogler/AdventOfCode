import std.stdio;
import std.conv;
import std.algorithm;
import std.string;
import std.range;
import std.regex;

auto getInputLines() {
    return generate!(() => readln.strip).until(null).array;
}

struct Food {
    this(string s) {
        static const re = ctRegex!`(.*) \(contains (.*)\)`;
        auto m = match(s, re);
        ingredients = m.captures[1].split(" ").sort.array;
        allergens = m.captures[2].split(", ");
    }

    string[] ingredients;
    string[] allergens;
}

string[string] maxMatching(string[][string] adj) {
    string[string] mt;
    bool[string] used;

    bool try_kuhn(string v) {
        if (v in used && used[v])
            return false;
        used[v] = true;
        foreach (string to; adj[v]) {
            if (!(to in mt) || try_kuhn(mt[to])) {
                mt[to] = v;
                return true;
            }
        }
        return false;
    }

    foreach (allergen; adj.keys) {
        used.clear;
        try_kuhn(allergen);
    }
    return mt;
}

void main() {
    // Input
    auto foods = getInputLines.map!Food.array;

    // Star 1
    auto allAllergens = foods.map!"a.allergens".reduce!"a ~ b".sort.uniq;

    string[][string] ingredientOptions;
    foreach (allergen; allAllergens) {
        ingredientOptions[allergen] =
            foods.filter!(f => f.allergens.canFind(allergen))
                 .map!"a.ingredients"
                 .reduce!"setIntersection(a, b).array";
    }

    string[] possibleIngredients = ingredientOptions.values.reduce!"a ~ b".sort.uniq.array;
    foods.map!"a.ingredients".reduce!"a ~ b".count!(i => !possibleIngredients.canFind(i)).writeln;

    // Star 2
    auto mt = maxMatching(ingredientOptions);
    mt.byPair.array.sort!"a.value < b.value".map!"a.key".join(",").writeln;
}
