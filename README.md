# Advent of Code 2019

My solutions in D for this year's [Advent of Code](https://adventofcode.com/2019).

### Usage:

You need the official D compiler `dmd` and `make`.
Then you can compile and run each day with the script `run`, e.g. with

    ./run day25

---

The `png` map of the ship from day 25 can be created from the `dot` file via

    dot -Kfdp -n -Tpng -o day25.png day25.dot
