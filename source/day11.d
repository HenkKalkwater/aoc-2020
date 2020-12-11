import std.array;
import std.algorithm;
import std.range;
import std.string;
import std.stdio;
import std.traits;
import std.variant;

import dayutil;

enum Spot {
	FLOOR,
	EMPTY,
	TAKEN
}

Variant run(int part, File input, bool bigboy, string[] args) {
	Spot[][] spots = parseInput(input.byLineCopy);

	return Variant(parts!size_t(part,
			() => part1(spots),
			() => part2(spots)));
}

Spot[][] parseInput(Range)(Range range) if (isInputRange!Range && isSomeString!(ElementType!Range)) {
	return range.map!(row => row.map!((spot) {
		switch(spot) {
		case '.':
			return Spot.FLOOR;
		case 'L':
			return Spot.EMPTY;
		case '#':
			return Spot.TAKEN;
		default:
			assert(false, "Unknown type");
		}
	}).array).array;
}

size_t part1(Spot[][] input) {
	Spot[][] prev = input.dup;
	do {
		foreach (i, row; input.enumerate) {
			prev[i] = row.dup;
		}
		//prev = input.dup;
		for (int y = 0; y < input.length; y++) {
			for (int x = 0; x < input[y].length; x++) {
				if(input[y][x] == Spot.FLOOR) continue;

				uint adjacent_taken = 0;
				for (int dy = max(0, y - 1); dy <= min(prev.length - 1, y + 1); dy++) {
					for (int dx = max(0, x - 1); dx <= min(prev[y].length - 1, x + 1); dx++) {
						if (dx == x && dy == y) continue;
						switch(prev[dy][dx]) {
						case Spot.TAKEN:
							adjacent_taken++;
							break;
						default:
							break;
						}
					}
				}
				import std.format;
				if (adjacent_taken == 0) {
					input[y][x] = Spot.TAKEN;
				} else if (adjacent_taken >= 4) {
					input[y][x] = Spot.EMPTY;
				}
			}
		}

	} while(!prev.equal(input));

	return input.joiner.count(Spot.TAKEN);
}


unittest {
	import std.format;
	string layout = q"EOS
L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL
EOS";
	size_t result = parseInput(layout.lineSplitter).part1();
	assert(result == 37, "Result is %d (expected 37)".format(result));
}

size_t part2(Spot[][] input) {
	Spot[][] prev = input.dup;
	do {
		foreach (i, row; input.enumerate) {
			prev[i] = row.dup;
		}
		//prev = input.dup;
		for (int y = 0; y < prev.length; y++) {
			for (int x = 0; x < prev[y].length; x++) {
				if(prev[y][x] == Spot.FLOOR) {
					//debug write('.');
					continue;
				}
				import std.format;

				int adjacent_taken = 0;
				for (int dy = -1; dy <= 1; dy++) {
					for (int dx = -1; dx <= 1; dx++) {
						if (dx == 0 && dy == 0) continue;

						Spot spot;
						int i = 1;
						do {
							int nx = x + i * dx;
							int ny = y + i * dy;
							i++;
							if (ny < 0 || ny >= prev.length || nx < 0 || nx >= prev[ny].length) {
								//debug write("\x1B[41m");
								spot = Spot.EMPTY;
								break;
							}

							spot = prev[ny][nx];
						} while(spot == Spot.FLOOR);

						if (spot == Spot.TAKEN) {
							adjacent_taken++;
						}
					}
				}

				//debug write(adjacent_taken);
				//debug write("\x1B[0m");
				if (adjacent_taken == 0) {
					input[y][x] = Spot.TAKEN;
				} else if (adjacent_taken >= 5) {
					input[y][x] = Spot.EMPTY;
				}
			}
			//debug writeln();
		}
		//debug writeln();

		/+debug {
			void printSpots(Spot[][] flop) {
				foreach(row; flop) {
					foreach(seat; row) {
						write(seat == Spot.TAKEN ? '#' : (seat == Spot.EMPTY ? 'L' : '.'));
					}
					writeln();
				}
			}
			printSpots(input);
		}+/
	} while(!prev.equal(input));

	return input.joiner.count(Spot.TAKEN);
}

unittest {
	import std.format;
	string layout = q"EOS
L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL
EOS";
	size_t result = parseInput(layout.lineSplitter).part2();
	assert(result == 26, "Result is %d (expected 26)".format(result));
}

