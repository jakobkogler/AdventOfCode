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

auto setBitTo(long value, long bitidx, long bit) {
    // remove bit at location
    value &= ~(value & (1L << bitidx));
    // set the bit
    value |= bit << bitidx;
    return value;
}

auto applyMask(ulong value, string mask) {
    foreach (i, c; mask.array.reverse) {
        if (c != 'X') {
            value = value.setBitTo(i, c - '0');
        }
    }
    return value;
}

auto toBinary(ulong value, ulong size) {
    int[] bits;
    foreach (i; 0 .. size) {
        bits ~= value & 1;
        value /= 2;
    }
    return bits;
}

auto fromBinary(int[] bits) {
    long value;
    foreach (bit; bits) {
        value = value * 2 + bit;
    }
    return value;
}

auto allAddresses(long address, string mask) {
    long[] addresses;
    int[] indices;
    foreach (i, c; mask.array.reverse) {
        if (c == 'X')
            indices ~= to!int(i);
        else
            address |= (c - '0') << i;
    }

    foreach (x; 0L .. (1L << indices.length)) {
        auto xMask = toBinary(x, indices.length);
        foreach (tup; zip(indices, xMask)) {
            address = address.setBitTo(tup.expand);
        }
        addresses ~= address;
    }
    return addresses;
}

void main() {
    // Input
    auto lines = getInputLines;

    // Star 1
    static const maskRegex = ctRegex!`mask = (\w+)`;
    static const memRegex = ctRegex!`mem\[(\d+)\] = (\d+)`;
    long[long] mem;
    string mask;
    foreach (line; lines) {
        if (auto m = match(line, maskRegex)) {
            mask = m.captures[1];
        } else if (auto m = match(line, memRegex)) {
            const address = to!long(m.captures[1]);
            const value = to!long(m.captures[2]);
            mem[address] = value.applyMask(mask);
        }
    }
    mem.values.sum.writeln;

    // Star 2
    // max number of Xs is 9, so just brute-force the answer
    mem.clear;
    foreach (line; lines) {
        if (auto m = match(line, maskRegex)) {
            mask = m.captures[1];
        } else if (auto m = match(line, memRegex)) {
            const address = to!long(m.captures[1]);
            const value = to!long(m.captures[2]);
            foreach (actualAddress; allAddresses(address, mask)) {
                mem[actualAddress] = value;
            }
        }
    }
    mem.values.sum.writeln;
}
