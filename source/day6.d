import std.algorithm;
import std.array;
import std.range;
import std.string;
import std.stdio;
import std.traits;
import std.variant;

import dayutil;

Variant run(int part, File file, bool bigboy, string[] args) {
	auto lines = file.byLineCopy.array;
	Variant result = parts!size_t(part,
			() => part1(lines),
			() => part2(lines));
	return result;
}

size_t part1(Range)(Range range) if (isInputRange!Range){
	return range.splitter!(x => x.length == 0)
		.map!(x => x.joiner.array.sort.uniq.count).sum;
}

unittest {
	string input = q"EOS
abc

a
b
c

ab
ac

a
a
a
a

b
EOS";
	assert(input.lineSplitter.part1() == 11);
}

size_t part2(Range)(Range range) if (isInputRange!Range){
	return range.splitter!(x => x.length == 0)
		.map!((x) {
			size_t people = x.length;

			return x.joiner.array.sort.group.filter!(x => x[1] == people).count;
		}).sum;
}

unittest {
	string input = q"EOS
abc

a
b
c

ab
ac

a
a
a
a

b
EOS";
	assert(input.lineSplitter.part2() == 6);
}
