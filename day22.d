import std.stdio;
import std.conv;
import std.algorithm;
import std.string;
import std.range;
import std.regex;
import std.container : DList;
import std.typecons;

auto getInputLines() {
    return generate!(() => readln.strip).until(null).array;
}

int[] combat(int[] cardsPlayer1, int[] cardsPlayer2) {
    auto player1 = cardsPlayer1.DList!int;
    auto player2 = cardsPlayer2.DList!int;

    while (!player1.empty && !player2.empty) {
        int x = player1.front;
        player1.removeFront;
        int y = player2.front;
        player2.removeFront;
        if (x > y) {
            player1 ~= x;
            player1 ~= y;
        } else {
            player2 ~= y;
            player2 ~= x;
        }
    }

    return player1.array ~ player2.array;
}

alias RecCombatResult = Tuple!(int, int[]);

RecCombatResult recursiveCombat(int[] cardsPlayer1, int[] cardsPlayer2) {
    auto player1 = cardsPlayer1.DList!int;
    auto player2 = cardsPlayer2.DList!int;

    bool[ulong] history;
    ulong toHash() {
        return player1.array.hashOf + ulong(1337) * player2.array.hashOf;
    }

    int p1l = to!int(cardsPlayer1.length);
    int p2l = to!int(cardsPlayer2.length);
 
    while (!player1.empty && !player2.empty) {
        auto state = toHash;
        if (state in history) {
            return RecCombatResult(1, []);
        }
        history[state] = true;

        int x = player1.front;
        player1.removeFront;
        p1l--;
        int y = player2.front;
        player2.removeFront;
        p2l--;

        int winner;
        if (p1l >= x && p2l >= y) {
            winner = recursiveCombat(player1.array[0..x], player2.array[0..y])[0];
        } else {
            winner = 1 + (y > x);
        }

        if (winner == 1) {
            player1 ~= x;
            player1 ~= y;
            p1l += 2;
        } else {
            player2 ~= y;
            player2 ~= x;
            p2l += 2;
        }
    }

    auto result = player1.array ~ player2.array;
    if (player2.empty) {
        return RecCombatResult(1, result);
    } else {
        return RecCombatResult(2, result);
    }
}

ulong computeScore(int[] cards) {
    return cards.retro.enumerate(1).map!"a.index * a.value".sum;
}

void main() {
    // Input
    auto getCards = () => getInputLines[1..$].map!(to!int).array;
    auto cardsPlayer1 = getCards();
    auto cardsPlayer2 = getCards();

    // Star 1

    combat(cardsPlayer1, cardsPlayer2).computeScore.writeln;

    // Star 2
    recursiveCombat(cardsPlayer1, cardsPlayer2)[1].computeScore.writeln;
}
