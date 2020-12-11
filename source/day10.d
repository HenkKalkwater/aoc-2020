import std.array;
import std.algorithm;
import std.conv;
import std.range;
import std.stdio;
import std.variant;

import dayutil;

Variant run(int part, File input, bool bigboy, string[] args) {
	uint[] numbers = input.byLineCopy.map!(to!uint).array ~ [0u];
	auto sortedNumbers = numbers.sort;

	Variant result = parts!size_t(part,
			() => part1(sortedNumbers),
			() => part2(sortedNumbers));
	return result;
}

size_t part1(T)(SortedRange!(T[]) numbers) {
	size_t gap1 = 0, gap3 = 0;

	foreach(window; numbers.slide!(No.withPartial)(2)) {
		size_t diff = window[1] - window[0];
		if (diff == 3) gap3++;
		if (diff == 1) gap1++;
	}
	// Device adapter is always rated 3 volts higher
	gap3++;
	return gap1 * gap3;
}

unittest {
	uint[] numbers = [28, 33, 18, 42, 31, 14, 46, 20, 48, 47, 24, 23, 49, 45, 19, 38, 39, 11, 1, 32, 
		 25, 35, 8, 17, 7, 9, 4, 2, 34, 10, 3];
	numbers ~= [0u];
	assert(part1(numbers.sort) == 220);
}

size_t part2(T)(SortedRange!(T[]) numbers) {
	auto numbers2 = merge(numbers, [numbers[$ - 1] + 3]).array;
	size_t[] options;
	options.length = numbers2[$ -1] + 1;
	fill(options, 0);
	options[0] = 1;
	
	foreach(int number; numbers2) {
		foreach(int diff; 1..4) {
			if ((number - diff) >= 0) options[number] += options[number - diff];
		}
	}

	size_t result = options[$ - 1];
	return result;
}
unittest {
	uint[] numbers = [28, 33, 18, 42, 31, 14, 46, 20, 48, 47, 24, 23, 49, 45, 19, 38, 39, 11, 1, 32, 
		 25, 35, 8, 17, 7, 9, 4, 2, 34, 10, 3];
	numbers ~= [0u];
	assert(part2(numbers.sort) == 19208);
}
