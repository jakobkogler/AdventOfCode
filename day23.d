import std.stdio;
import std.conv;
import std.algorithm;
import std.string;
import std.range;
import std.regex;

auto getInputLines() {
    return generate!(() => readln.strip).until(null).array;
}

class LinkedListElem {
    public:
        int value;
        LinkedListElem next = null;
        LinkedListElem prev = null;

        this(int v) {
            value = v;
        }

        override string toString() const {
            return "LL(" ~ value.to!string ~ ", prev=" ~ prev.value.to!string
                ~ ", next=" ~ next.value.to!string ~ ")";
        }
}

LinkedListElem performMove(ref LinkedListElem[] ll, LinkedListElem cur) {
    int[] nextThree;
    // remember next three
    nextThree ~= cur.next.value;
    nextThree ~= cur.next.next.value;
    nextThree ~= cur.next.next.next.value;

    // remove next three
    cur.next = cur.next.next.next.next;
    cur.next.prev = cur;

    // find insert point
    int insert = cur.value - 1;
    if (insert == 0)
        insert = to!int(ll.length) - 1;
    while (nextThree.canFind(insert)) {
        insert--;
        if (insert == 0)
            insert = to!int(ll.length) - 1;
    }

    // insert the three
    // at the back
    ll[insert].next.prev = ll[nextThree[2]];
    ll[nextThree[2]].next = ll[insert].next;
    // and at the front
    ll[insert].next = ll[nextThree[0]];
    ll[nextThree[0]].prev = ll[insert];

    // return next
    return cur.next;
}

int[] playGame(int[] lst, int moves) {
    LinkedListElem[] ll;
    foreach (i; 0 .. lst.length + 1) {
        ll ~= new LinkedListElem(i.to!int);
    }
    foreach (i, v; lst) {
        int w = lst[(i + 1) % lst.length];
        ll[v].next = ll[w];
        ll[w].prev = ll[v];
    }
    
    LinkedListElem cur = ll[lst[0]];
    foreach (i; 0..moves) {
        if ((i + 1) % 1000 == 0)
            writeln("iteration ", i+1);
        cur = performMove(ll, cur);
    }

    int[] result;
    cur = ll[1];
    do {
        result ~= cur.value;
        cur = cur.next;
    } while (cur != ll[1]);
    return result;
}

void main() {
    // Input
    auto lst = readln.strip.map!"(a - '0').to!int".array;

    // Star 1
    lst.playGame(100)[1..$].map!(to!string).join.writeln;

    // Star 2
    lst ~= iota(lst.maxElement + 1, 1_000_001).array;
    auto result = lst.playGame(10_000_000);
    (result[1].to!long * result[2]).writeln;
}
