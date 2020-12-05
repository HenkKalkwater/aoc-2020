import std.algorithm;
import std.array;
import std.format;
import std.range;
import std.stdio;
import std.traits;
import std.uni;
import std.variant;

import dayutil;

Variant run(int part, File input, string[] args) {
	auto inputData = stdin.byLineCopy.array;
	Variant count = parts!size_t(part,
			() => inputData.countTrees1,
			() => [[1,1], [3,1], [5,1], [7,1], [1,2]]
				.map!(x => inputData.save.enumerate.countTrees2(x[0], x[1]))
				.fold!((x, y) => x * y));
	return count;
}

ulong countTrees1(Range)(Range lines) if (isInputRange!Range && isSomeString!(ElementType!Range)) {
	return lines.enumerate.filter!(x => (x.value[x.index * 3 % x.value.length] == '#')).count;
}

unittest {
	string[] field = [
		"..##.......",
		"#...#...#..",
		".#....#..#.",
		"..#.#...#.#",
		".#...##..#.",
		"..#.##.....",
		".#.#.#....#",
		".#........#",
		"#.##...#...",
		"#...##....#",
		".#..#...#.#"
	];
	assert(field.countTrees1 == 7);
}

// Screw proper template type checking, ain't got time for that.
ulong countTrees2(Range)(Range lines, int advanceX, int advanceY) if (isInputRange!Range)
	in (advanceX > 0)
	in (advanceY > 0)
	out (r; r >= 0) {
		return lines.enumerate.filter!(x => {
			char c = x.value.value[(x.value.index * advanceX) / advanceY % x.value.value.length];
			return (x.index % advanceY) == 0 && c == '#';
		}()).count;
}

unittest {
	string[] field = [
		"..##.......",
		"#...#...#..",
		".#....#..#.",
		"..#.#...#.#",
		".#...##..#.",
		"..#.##.....",
		".#.#.#....#",
		".#........#",
		"#.##...#...",
		"#...##....#",
		".#..#...#.#"
	];
	assert(field.enumerate.countTrees2(1, 1) == 2);
	assert(field.enumerate.countTrees2(3, 1) == 7);
	assert(field.enumerate.countTrees2(5, 1) == 3);
	assert(field.enumerate.countTrees2(7, 1) == 4);
	assert(field.enumerate.countTrees2(1, 2) == 2, "Expected 2, got %d".format(field.enumerate.countTrees2(1,2)));
}
