import std.algorithm;
import std.array;
import std.conv;
import std.range;
import std.stdio;
import std.string;
import std.variant;

import dayutil;

Variant run(int part, File file, string[] args) {
	auto lines = file.byLine;
	Variant result = parts!int(part, 
			() => part1(lines));
	return result;
}

int part1(Range)(Range range) if (isInputRange!Range) {
	return range.map!(x => determineSeat(to!string(x.array))).maxElement;
}

int determineSeat(string code) {
	int result = 0;
	int marker = 0b1000000000;
	foreach(char c; code[0..7]) {
		if (c == 'B') result |= marker;
		marker >>= 1;
	}
	//writeln("ROW: ", result >> 3);
	foreach(char c; code[7..10]) {
		if (c == 'R') result |= marker;
		marker >>= 1;
	}
	//writeln("COL: ", result & 0x7);
	return result;
}

unittest {
	assert(determineSeat("BFFFBBFRRR") == 567);
	assert(determineSeat("FFFBBBFRRR") == 119);
	assert(determineSeat("BBFFBBFRLL") == 820);
}
