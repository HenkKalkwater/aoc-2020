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
				() => part1(numbers)));
}

T part1(Range, T = ElementType!Range)(Range range, int preambleSize = 25) 
	if (isForwardRange!Range && isNumeric!T) {
	foreach(window; range.slide!(No.withPartial)(preambleSize + 1)) {
		if(!window[0..preambleSize].any!(e => window.canFind!(x => e + x == window[preambleSize]))) {
			return window[preambleSize];
		}
	}
	return -1;
}

unittest {
	int[] numbers = [35, 20, 15, 25, 47, 40, 62, 55, 65, 95, 102, 117, 150, 182, 127, 219, 299, 
		277, 309, 576];
	assert(part1(numbers, 5) == 127);
}
