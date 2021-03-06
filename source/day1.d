import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.format;
import std.functional;
import std.range;
import std.stdio;
import std.variant;

import dayutil;

immutable string progName = "aoc-2020";

Variant run(int part, File input, bool bigboy, string[] args) {

	/* For each line on stdin, copy it, map it to an integer and sort it.
	   Sorting a range makes it a SortedRange and functions like contains(range, elem)
	   will make use of optimised implementations, in the case of contains(range, elem)
	   it will use a binary search instead of a linear search */
	auto numbers = input.byLineCopy.map!(a => to!int(a)).array.sort;
	int target = 2020;
	if(bigboy) target = 2020;

	Variant solution = parts!int(part, 
			() => part1(numbers, target), 
			() => part2(numbers, target));
	enforce(solution >= 0, "No solutions found");
	return solution;
}

int part1(SortedRange!(int[]) numbers, int target) {
	int result = -1;

	foreach (ref int a; numbers) {
		int b = target - a;
		if (numbers.contains(b)) {
			result = b * a;
			break;
		}
	}
	return result;
}

unittest {
	auto numbers = [1721, 979, 366, 299, 675, 1456].sort;
	assert(part1(numbers, 2020) == 514579);
}

int part2(SortedRange!(int[]) numbers, int target) {
	int result = -1;
	foreach (ref int a; numbers) {
		foreach (ref int b; numbers) {
			int c = target - b - a;
			if (numbers.contains(c)) {
				result = c * b * a;
				goto exit;
			}
		}
	}
exit:
	return result;
}

unittest {
	auto numbers = [1721, 979, 366, 299, 675, 1456].sort;
	assert(part2(numbers, 2020) == 241861950);
}
