import std.stdio;
import std.string;
import std.algorithm;
import std.range;
import std.conv;
import std.ascii;
import std.math;

import Point2D;

string[] board;
long m, n;
int[][] adj;

int toCoord(Point p) {
    return to!int(p.y * n + p.x);
}

bool isPortal(string s) {
    return isAlpha(s[0]) && isAlpha(s[1]) && s[2] == '.';
}

bool isPortal(int from, int to) {
    int diff = (from - to).abs;
    return diff != 1 && diff != n;
}

bool isOuter(int coord) {
    int y = coord / n;
    int x = coord % n;

    return y == 2 || y == m - 3 || x ==2 || x == n - 3;
}

auto bfs(int start) {
    bool[] visited = new bool[n*m];
    int[] dist = new int[n*m];
    int[] queue;
    queue ~= start;
    visited[start] = true;

    while (!queue.empty) {
        int cur = queue[0];
        int cur_dist = dist[cur];
        queue.popFront;

        foreach(nb; adj[cur]) {
            if (!visited[nb]) {
                dist[nb] = dist[cur] + 1;
                visited[nb] = true;
                queue ~= nb;
            }
        }
    }

    return dist;
}

auto bfs2(int start, int max_level) {
    bool[][] visited = new bool[][](n*m, max_level+1);
    int[][] dist = new int[][](n*m, max_level+1);
    int[2][] queue;
    queue ~= [start, 0];
    visited[start][0] = true;

    while (!queue.empty) {
        int cur = queue[0][0];
        int cur_level = queue[0][1];
        int cur_dist = dist[cur][cur_level];
        queue.popFront;

        foreach(nb; adj[cur]) {
            int nl = cur_level;
            if (isPortal(cur, nb)) {
                if (isOuter(cur))
                    nl--;
                else
                    nl++;
            }
            if (nl < 0 || nl > max_level)
                continue;

            if (!visited[nb][nl]) {
                dist[nb][nl] = dist[cur][cur_level] + 1;
                visited[nb][nl] = true;
                queue ~= [nb, nl];
            }
        }
    }

    return dist;
}

void main() {
    string s;
    while ((s = readln()) !is null)
        board ~= s.strip('\n');

    m = board.length;
    n = board[0].length;

    int[][string] portals;
    // vert
    foreach(y; 0..m-2) {
        foreach(x; 0..n) {
            char c1 = board[y][x];
            char c2 = board[y+1][x];
            char c3 = board[y+2][x];
            if (isPortal("" ~ c1 ~ c2 ~ c3)) {
                portals["" ~ c1 ~ c2] ~= toCoord(Point(x, y+2));
            }
            if (isPortal("" ~ c2 ~ c3 ~ c1)) {
                portals["" ~ c2 ~ c3] ~= toCoord(Point(x, y));
            }
        }
    }
    // horiz
    foreach(y; 0..m) {
        foreach(x; 0..n-2) {
            char c1 = board[y][x];
            char c2 = board[y][x+1];
            char c3 = board[y][x+2];
            if (isPortal("" ~ c1 ~ c2 ~ c3)) {
                portals["" ~ c1 ~ c2] ~= toCoord(Point(x+2, y));
            }
            if (isPortal("" ~ c2 ~ c3 ~ c1)) {
                portals["" ~ c2 ~ c3] ~= toCoord(Point(x, y));
            }
        }
    }

    // adjacency list
    adj = new int[][](n * m);
    foreach(y; 1..m-1) {
        foreach(x; 1..n-1) {
            if (board[y][x] != '.')
                continue;
            int dx = 0;
            int dy = 1;

            foreach(dir; 0..4) {
                if (board[y+dy][x+dx] == '.') {
                    int c1 = toCoord(Point(x, y));
                    int c2 = toCoord(Point(x+dx, y+dy));
                    adj[c1] ~= c2;
                }

                int tmp = dx;
                dx = dy;
                dy = -tmp;
            }
        }
    }

    debug writeln(portals);
    debug writeln(adj);

    foreach(name, portal; portals) {
        if (portal.length == 2) {
            adj[portal[0]] ~= portal[1];
            adj[portal[1]] ~= portal[0];
        }
    }

    int start = portals["AA"][0];
    int goal = portals["ZZ"][0];
    // star 1
    auto dists = bfs(start);
    writeln(dists[goal]);

    // star 2
    int max_depth = 1;
    int[] dists_to_goal;
    while (dists_to_goal.filter!`a != 0`.array.length < 2) {
        auto dists2 = bfs2(start, max_depth);
        dists_to_goal ~= dists2[goal][0];
        max_depth *= 2;
    }

    debug writeln(dists_to_goal);
    writeln(dists_to_goal[$-2..$].minElement);
}
