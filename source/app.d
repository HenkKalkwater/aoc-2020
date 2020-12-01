import core.stdc.stdlib;

import std.conv;
import std.format;
import std.stdio;
import std.getopt;

import day1;

immutable string progName = "aoc-2020";

void function(string[])[] programs = [
	&day1.run
];

void main(string[] args) {
	int day;
	if (args.length < 2) {
		stderr.writeln("USAGE: %s [day]".format(args[0]));
		exit(-1);
	}
	try {
		day = to!int(args[1]);
	} catch (ConvException e) {
		stderr.writeln("[day] is not an integer");
		exit(-1);
	}

	if (day <= 0 || day > programs.length) {
		stderr.writeln("Day must be between 1 and %d".format(programs.length - 1));
		exit(-1);
	}

	
	programs[day - 1](args[2..$]);

}
