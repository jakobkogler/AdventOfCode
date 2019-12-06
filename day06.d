import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;


void main() {
    // input
    string[][string] adj;
    string line;
    while ((line = readln()) !is null) {
        auto from_to = split(strip(line), ')');
        auto from = from_to[0];
        auto to = from_to[1];
        adj[from] ~= to;
    }

    // star 1
    int dfs(string v, int depth=0) {
        int sum = depth;
        if (v in adj) {
            foreach(u; adj[v]) {
                sum += dfs(u, depth+1);
            }
        }
        return sum;
    }
    writeln(dfs("COM"));

    // star 2
    string[string] parent;
    foreach(from, tos; adj) {
        foreach(to; tos) {
            parent[to] = from;
        }
    }

    string[] find_path(string cur) {
        string[] path;
        path ~= cur;
        while (cur != "COM") {
            cur = parent[cur];
            path ~= cur;
        }
        return reverse(path);
    }

    auto path1 = find_path("YOU");
    auto path2 = find_path("SAN");
    int similar = 0;
    while (path1[similar] == path2[similar])
        similar++;
    writeln(path1.length + path2.length - 2 - 2*similar);
}
