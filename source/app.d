import core.stdc.stdlib;

import std.conv;
import std.format;
import std.stdio;
import std.getopt;

import day1;
import day2;
import dayutil;

immutable string progName = "aoc-2020";

void function(string[])[] programs = [
	&day1.run,
	&day2.run
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
	if (args.length < 2) {
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

	
	try {
		programs[day - 1](args[2..$]);
	} catch(ArgumentException e) {
		printUsage(args[0], e.msg);
	} 

}
