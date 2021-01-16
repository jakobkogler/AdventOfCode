# Advent of Code

My solutions in D for this year's [Advent of Code 2020](https://adventofcode.com/2020).

For my solutions of the 2019 year, visit the 2019 branch: [adventofcode2019](https://github.com/jakobkogler/AdventOfCode/tree/adventofcode2019).

### Usage:

You need the official D compiler `dmd` and `make`.
Then you can compile and run each day with the script `run`, e.g. with

    ./run day25

Except for the days 19 and 20. For those you need to run

    dub --build=release --single day19.d <input/day19.in
    
and 

    dub --build=release --single day20.d <input/day20.in

### Downloading data

I use the following script to automatically downloading the input data from the website.
It requires a virtual environment for Python in the `.venv` directory, and the [advent-of-code-data](https://pypi.org/project/advent-of-code-data/) package.

    ./getdata
