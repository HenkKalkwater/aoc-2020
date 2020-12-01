import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.format;
import std.range;
import std.stdio;

immutable string progName = "aoc-2020";

void run(string[] args) {
	enforce(args.length == 1, "Please provide a part to run %s 1 [part]".format(progName));
	int part = to!int(args[0]);
	enforce(part > 0 &&  part <= 2, "Parts %d to %d supported".format(1, 2));

	auto numbers = stdin.byLineCopy.map!(a => to!int(a)).array.sort;

	auto fun = part == 1 ? &part1 : &part2;
	writeln(fun(numbers));
}

int part1(SortedRange!(int[]) numbers) {
	int result = -1;

	foreach (ref int a; numbers) {
		int b = 2020 - a;
		if (numbers.contains(b)) {
			result = b * a;
			break;
		}
	}
	return result;
}

unittest {
	auto numbers = [1721, 979, 366, 299, 675, 1456].sort;
	assert(part1(numbers) == 514579);
}

int part2(SortedRange!(int[]) numbers) {
	int result = -1;
	foreach (ref int a; numbers) {
		foreach (ref int b; numbers) {
			int c = 2020 - b - a;
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
	assert(part2(numbers) == 241861950);
}
