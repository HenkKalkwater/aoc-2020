import std.array;
import std.algorithm;
import std.range;
import std.stdio;
import std.traits;
import std.variant;

import dayutil;

Variant run(int part, File input, bool bigboy, string[] args) {
	import std.conv;
	auto numbers = input.byLineCopy.array.map!(to!uint);
	return Variant(parts!uint(part,
				() => part1(numbers),
				() => part2(numbers)));
}

ptrdiff_t indexOfWeakness(Range)(Range range, int preambleSize = 25) 
	if (isForwardRange!Range)
	in (range.length > preambleSize)
	out (r; r >= preambleSize || r == -1)
do {
	foreach(i, window; range.slide!(No.withPartial)(preambleSize + 1).enumerate) {
		if(!window[0..preambleSize].any!(e => window.canFind!(x => e + x == window[preambleSize]))) {
			return preambleSize + i;
		}
	}
	return -1;
}

T part1(Range, T = ElementType!Range)(Range range, int preambleSize = 25)
	if (isForwardRange!Range)
	in (range.length > preambleSize) {
	
	auto index = indexOfWeakness(range, preambleSize);
	assert(index >= 0);
	return range[index];
}

unittest {
	int[] numbers = [35, 20, 15, 25, 47, 40, 62, 55, 65, 95, 102, 117, 150, 182, 127, 219, 299, 
		277, 309, 576];
	assert(part1(numbers, 5) == 127);
}

T part2(Range, T = ElementType!Range)(Range range, int preambleSize = 25)
	if (isForwardRange!Range)
	in (range.length > preambleSize)
do {
	
	T num = part1(range, preambleSize);

	for (size_t offset = 0; offset <= range.length; offset++) {
		T min = T.max;
		T max = T.min;

		size_t offset_offset = 0;
		T sum = 0;
		for(; sum < num && offset + offset_offset < range.length; sum += range[offset + offset_offset++]) {
			T curNumber = range[offset + offset_offset];
			if (curNumber < min) min = curNumber;
			if (curNumber > max) max = curNumber;
		}

		if (sum == num) {
			return min + max;
		}
	}

	return -1;
}

unittest {
	int[] numbers = [35, 20, 15, 25, 47, 40, 62, 55, 65, 95, 102, 117, 150, 182, 127, 219, 299, 
		277, 309, 576];
	assert(part2(numbers, 5) == 62);
}
