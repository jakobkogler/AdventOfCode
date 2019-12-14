import std.stdio;
import std.algorithm;
import std.string;
import std.range;
import std.container.rbtree;
import std.format;


struct ItemCount {
    int units;
    string item;

    this(string tup) {
        tup.formattedRead!"%d %s"(units, item);
    }
    unittest {
        assert(ItemCount("12 ABC").units == 12);
        assert(ItemCount("12 ABC").item == "ABC");
    }

    string toString() const {
        return format!"%d %s"(units, item);
    }
}

struct Vertex {
    ItemCount item_count;
    ItemCount[] requirements;
    long required;
    int todo;
    bool finished = false;

    this(string s) {
        auto line = s.split(" => ");
        item_count = line[1].ItemCount;
        requirements = line[0].split(", ").map!(ItemCount).array;
    }
}

long computeORE(Vertex[string] graph, long fuel) {
    graph["FUEL"].required = fuel;
    while (!graph.byValue.all!"a.finished") {
        foreach(ref v; graph) {
            if (v.todo == 0 && !v.finished) {
                debug writeln(v);
                int units = v.item_count.units;
                long factor = (v.required + units - 1) / units;
                debug writeln(v.required, " ", units, ": ", factor);
                foreach(ref req; v.requirements) {
                    graph[req.item].todo--;
                    graph[req.item].required += req.units * factor;
                }
                v.finished = true;
            }
        }
    }
    return graph["ORE"].required;
}


void main() {
    Vertex[string] graph;
    graph["ORE"] = Vertex(" => 1 ORE");

    string s;
    while ((s = readln()) !is null) {
        auto v = Vertex(s.strip);
        graph[v.item_count.item] = v;
    }

    foreach(v; graph) {
        foreach(ic; v.requirements) {
            graph[ic.item].todo++;
        }
    }

    // star 1
    writeln(graph.dup.computeORE(1));

    // star 2
    long TRIL = 1_000_000_000_000;
    long L = 0;  // possible
    long R = TRIL;  // impossible
    while (L + 1 < R) {
        long M = (L + R) / 2;
        if (graph.dup.computeORE(M) > TRIL)
            R = M;
        else
            L = M;
    }
    writeln(L);
}
