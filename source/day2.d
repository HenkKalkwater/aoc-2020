import std.algorithm;
import std.format;
import std.functional;
import std.stdio;
import std.variant;

import dayutil;

Variant run(int day, File input, string[] args) {
	auto lines = input.byLine;
	Variant count = parts!ulong(day,
			() => lines.count!(l => isPasswordValid1(l)),
			() => lines.count!(l => isPasswordValid2(l)));
	return count;
}

/// Part 1
bool isPasswordValid1(T)(T line) {
	int min, max;
	char c;
	string password;
	line.formattedRead("%d-%d %c: %s", min, max, c, password);
	ulong charCount = password.count(c);
	return min <= charCount && charCount <= max;
}

unittest {
	assert(isPasswordValid1("1-3 a: abcde") == true);
	assert(isPasswordValid1("1-3 b: cdefg") == false);
	assert(isPasswordValid1("2-9 c: ccccccccc") == true);
}

/// Part 2
bool isPasswordValid2(T)(T line) {
	int min, max;
	char c;
	string password;
	line.formattedRead("%d-%d %c: %s", min, max, c, password);
	// 1 2 | R
	// T T | F
	// T F | T
	// F T | T
	// F F | F
	return (password[min - 1] == c) != (password[max - 1] == c);
}

unittest {
	assert(isPasswordValid2("1-3 a: abcde") == true);
	assert(isPasswordValid2("1-3 b: cdefg") == false);
	assert(isPasswordValid2("2-9 c: ccccccccc") == false);
}
