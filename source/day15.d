import std.conv;
import std.typecons;

import dayutil;

immutable size_t TIMES = 2020;
immutable size_t TIMES2 = 30000000;

Variant run(int part, File input, bool bigboy, string[] args) {
	int[] numbers = input.byLineCopy.joiner(",").array.splitter(",").map!(to!int).array;
	return Variant(parts!int(part,
			() => part1(numbers),
			() => part2(numbers)));
}

int part1(int[] startingNumbers) {
	int[] memory;
	memory.reserve(2020);

	memory ~= startingNumbers;

	int previous = startingNumbers[$ - 1];
	foreach(index; memory.length..TIMES) {
		ptrdiff_t last = memory[0..$ - 1].retro.countUntil(previous) + 1;

		previous = cast(int) last;

		memory ~= [previous];
	}

	return previous;
}

int part2(int[] startingNumbers) {
	int[int] memory;

	foreach(idx, num; startingNumbers[0..$ - 1]) {
		memory[num] = cast(int) idx + 1;
	}

	int previousNumber = startingNumbers[$ - 1];

	foreach(index; memory.length..TIMES2 - 1) {
		int lastSpoken = memory.get(previousNumber, 0);
		int newNumber = lastSpoken;

		if (lastSpoken > 0) {
			newNumber = cast(int) index + 1 - lastSpoken;
		}

		memory[previousNumber] = cast(int) index + 1;

		/+if (index < 20 || index == TIMES2 - 2) {
			writeln("i:", index + 1, "; newNumber: ", newNumber, ", lastSpoken: ", lastSpoken, ", prevous: ", previousNumber);
			if (index != TIMES2 - 2) writeln(memory);
		}+/
		previousNumber = newNumber;
	}

	return previousNumber;
}

unittest {
	//assert(part1([0,3,6]) == 12);
	assert(part1([1,3,2]) == 1);
	assert(part1([2,1,3]) == 10);
	assert(part1([1,2,3]) == 27);

	assert(part2([0,3,6]) == 175594);
	assert(part2([1,3,2]) == 2578);
}
