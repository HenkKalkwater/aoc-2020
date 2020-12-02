import std.algorithm;
import std.format;
import std.stdio;


import dayutil;

bool isPasswordValid(T)(T line) {
	int min, max;
	char c;
	string password;
	line.formattedRead("%d-%d %c: %s", min, max, c, password);
	ulong charCount = password.count(c);
	return min <= charCount && charCount <= max;
}

void run(string[] args) {
	ulong count = stdin.byLine
		.count!(l => isPasswordValid(l));
	writeln(count);
}

unittest {
	assert(isPasswordValid("1-3 a: abcde") == true);
	assert(isPasswordValid("1-3 b: cdefg") == false);
	assert(isPasswordValid("2-9 c: ccccccccc") == true);
}
