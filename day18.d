import std.stdio;
import std.string;
import std.algorithm;
import std.conv;
import std.range;
import std.traits;
import std.container.rbtree;
import core.thread;
import std.ascii;
import std.typecons;

int n, m;
string[] board;
int[][] adj;
immutable COUNT = 26;
int[] pos;

int toCoord(long x, long y) {
    return to!int(x * m + y);
}

alias Dist = Tuple!(int, "c", int, "dist");

auto bfs(int start, int passable) {
    bool[] visited = new bool[n*m];
    int[] dist = new int[n*m];
    int[] queue;
    queue ~= start;
    visited[start] = true;
    int[COUNT] ret_dists = int.max;

    while (!queue.empty) {
        int cur = queue[0];
        int cur_dist = dist[cur];
        queue.popFront;

        int x = cur / m;
        int y = cur % m;
        char c = board[x][y];
        if (c != '.') {
            if (isUpper(c) && !((passable >> (c - 'A')) & 1))
                continue;
            if (isLower(c)) {
                ret_dists[c - 'a'] = dist[cur];
            }
        }

        foreach(nb; adj[cur]) {
            if (!visited[nb]) {
                dist[nb] = dist[cur] + 1;
                visited[nb] = true;
                queue ~= nb;
            }
        }
    }

    return ret_dists.array
                    .enumerate
                    .map!(pair => Dist(to!int(pair.index), pair.value))
                    .filter!(pair => pair.dist < int.max);
}

void main() {
    string s;
    while ((s = readln.strip) !is null) {
        board ~= s;
    }
    star1(board);
    star2.writeln;
}

void star1(string[] board) {
    findPosAndAdj();

    int[COUNT][int] dp;

    // initialize dp
    auto init_dists = bfs(pos[$-1], 0);
    foreach(pair; init_dists) {
        int[26] t = int.max;
        t[pair.c] = pair.dist;
        dp[1<<pair.c] = t;
    }

    // make transitions
    foreach(mask; 0..1<<COUNT) {
        if (!(mask in dp))
            continue;

        foreach(last; 0..COUNT) {
            if (dp[mask][last] == int.max)
                continue;
            if (!(mask & (1 << last)))
                continue;

            foreach(i, d; bfs(pos[last], mask)) {
                if (mask & (1 << i))
                    continue;
                int new_mask = mask | (1 << i);
                if (!(new_mask in dp)) {
                    int[26] t = int.max;
                    dp[new_mask] = t;
                }
                dp[new_mask][i] = min(dp[new_mask][i], dp[mask][last] + d);
            }
        }
    }

    writeln(minElement(dp[(1<<COUNT)-1].array));
}

struct MaskDPValues {
    int[] arr;
    static int[COUNT+4] mapping;
    static int[4] lengths;

    static void set_mapping(int[][] possible_robot_pos) {
        foreach(robot, positions; possible_robot_pos) {
            lengths[robot] = to!int(positions.length);
            foreach(i, pos; positions) {
                mapping[pos] = to!int(i);
            }
        }
    }

    this(int init) {
        arr = new int[lengths[0] * lengths[1] * lengths[2] * lengths[3]];
        arr.fill(init);
    }

    ref int opIndex(int[4] pos) {
        int idx =              (((mapping[pos[0]])
                   * lengths[1] + mapping[pos[1]])
                   * lengths[2] + mapping[pos[2]])
                   * lengths[3] + mapping[pos[3]];
        return arr[idx];
    }
}

int star2() {
    // change board
    auto robot_coord = findRobotCoord();
    auto rx = robot_coord[0];
    auto ry = robot_coord[1];
    board[rx-1] = board[rx-1][0..ry-1] ~ "@#@" ~ board[rx-1][ry+2..$];
    board[rx+0] = board[rx+0][0..ry-1] ~ "###" ~ board[rx+0][ry+2..$];
    board[rx+1] = board[rx+1][0..ry-1] ~ "@#@" ~ board[rx+1][ry+2..$];

    // find all positions of letters and robots, and setup adjacency graph
    findPosAndAdj();

    // find the list of letters that each robot can reach (assuming all doors are open)
    int full_mask = (1 << COUNT) - 1;
    auto possible_robot_pos =
        iota(COUNT, COUNT+4)
        .map!(robot => bfs(pos[robot], full_mask).array ~ Dist(robot, 0))
        .map!(pairs => pairs.map!(pair => pair.c).array)
        .array;
    // set the search space
    MaskDPValues.set_mapping(possible_robot_pos);

    // start point (all robots are on default position)
    MaskDPValues[int] dp;
    dp[0] = MaskDPValues(int.max);
    dp[0][[COUNT+0, COUNT+1, COUNT+2, COUNT+3]] = 0;

    // dp (try all transitions)
    foreach(mask; 0..1<<COUNT) {
        if (!(mask in dp))
            continue;

        foreach(robot_pos; iteratePossibleRobots(possible_robot_pos, mask)) {
            if (dp[mask][robot_pos] == int.max)
                continue;

            transition(dp, 0, pos, mask, robot_pos);
            transition(dp, 1, pos, mask, robot_pos);
            transition(dp, 2, pos, mask, robot_pos);
            transition(dp, 3, pos, mask, robot_pos);
        }
    }

    return dp[full_mask].arr.minElement;
}

auto findRobotCoord() {
    // find x and y coordinates of '@'
    foreach(x, row; board) {
        foreach(y, elem; row) {
            if (elem == '@')
                return tuple(x, y);
        }
    }
    assert(0);
}
    
void findPosAndAdj() {
    // setup graph and locations
    n = to!int(board.length);
    m = to!int(board[0].length);

    pos = new int[COUNT];
    adj.length = 0;
    adj.length = n * m;
    foreach(x, row; board) {
        foreach(y, elem; row) {
            if (elem == '@')
                pos ~= toCoord(x, y);
            if (elem != '#' && elem != '.' && elem != '@' && isLower(elem))
                pos[elem - 'a'] = toCoord(x, y);
            if (elem != '#') {
                int dx = 1, dy = 0;
                foreach(_; 0..4) {
                    if (board[x+dx][y+dy] != '#') {
                        adj[toCoord(x+dx, y+dy)] ~= toCoord(x, y);
                        adj[toCoord(x, y)] ~= toCoord(x+dx, y+dy);
                    }
                    int tmp = dx;
                    dx = -dy;
                    dy = tmp;
                }
            }
        }
    }
}

int[][] filterPossibilities(int[][] possibilities, int mask) {
    // filter the list of possible locations from each robot
    // according to the mask of visited locations
    return possibilities
           .map!(positions =>
                     positions
                     .filter!(pos => (mask & (1 << pos)) || pos >= COUNT)
                     .array
                )
           .array;
}

auto iteratePossibleRobots(int[][] possible_robot_pos, int mask) {
    // find all possible robot configurations given some mask
    auto positions = filterPossibilities(possible_robot_pos, mask);
    int[4][] tuples;
    foreach(p0; positions[0])
    foreach(p1; positions[1])
    foreach(p2; positions[2])
    foreach(p3; positions[3])
        tuples ~= [p0, p1, p2, p3];
    return tuples;
}

void transition(DP)(ref DP dp, int robot, in int[] pos, int mask, int[4] from) {
    // make transition of `robot` assuming all 4 robots are at locations `from`
    foreach(i, d; bfs(pos[from[robot]], mask)) {
        if (mask & (1 << i))
            continue;
        int new_mask = mask | (1 << i);
        if (!(new_mask in dp))
            dp[new_mask] = MaskDPValues(int.max);
        auto to = from;
        to[robot] = i;
        dp[new_mask][to] = min(dp[new_mask][to], dp[mask][from] + d);
    }
}
