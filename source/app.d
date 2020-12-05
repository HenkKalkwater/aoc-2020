import core.stdc.stdlib;

import std.conv;
import std.format;
import std.stdio;
import std.getopt;
import std.variant;

import day1;
import day2;
import day3;
import day4;
import day5;
import dayutil;

immutable string progName = "aoc-2020";

Variant function(int, File, string[])[] programs = [
	&day1.run,
	&day2.run,
	&day3.run,
	&day4.run,
	&day5.run,
];

void printUsage(string name) {
	printUsage(name, null);
}

void printUsage(string name, string message) {
	stderr.writeln("USAGE: %s [day] [part]".format(name));
	if (message != null) {
		stderr.writeln(message);
	}
	exit(-1);
}

void main(string[] args) {
	int day;
	if (args.length < 3) {
		printUsage(args[0]);
	}
	try {
		day = to!int(args[1]);
	} catch (ConvException e) {
		printUsage(args[0], "[day] is not an integer");
	}

	if (day <= 0 || day > programs.length) {
		printUsage(args[0], "[day] must be between 1 and %d".format(programs.length - 1));
	}

	int part;
	try {
		part = to!int(args[2]);
	} catch (ConvException e) {
		printUsage(args[0], "[part] is not an integer");
	}
	
	try {
		Variant result = programs[day - 1](part, stdin, args[3..$]);
		writeln(result);
	} catch(ArgumentException e) {
		printUsage(args[0], e.msg);
	} 

}
