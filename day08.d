import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;
import std.range;

void main() {
    enum int wide = 25;
    enum int tall = 6;

    int[] numbers;
    foreach(c; strip(readln())) {
        numbers ~= to!int(c - '0');
    }

    auto layers = chunks(numbers, wide * tall);
    auto best_layer = layers[0];
    foreach(layer; layers) {
        if (count(layer, 0) < count(best_layer, 0))
            best_layer = layer;
    }

    // star 1
    writeln(count(best_layer, 1) * count(best_layer, 2));

    // star 2
    char[] symb = [' ', '*', char.init];
    char[] image = new char[tall*wide];
    foreach(layer; layers) {
        foreach(i, numb; layer) {
            if (image[i] == char.init)
                image[i] = symb[numb];
        }
    }

    foreach(line; chunks(image, wide)) {
        writeln(line);
    }
}
