import core.stdc.stdlib;

import std.conv;
import std.exception;
import std.format;
import std.stdio;
import std.getopt;
import std.variant;

import day1;
import day2;
import day3;
import day4;
import day5;
import day6;
import day7;
import dayutil;

immutable string progName = "aoc-2020";

Variant function(int, File, bool, string[])[] programs = [
	&day1.run,
	&day2.run,
	&day3.run,
	&day4.run,
	&day5.run,
	&day6.run,
	&day7.run,
];

void printUsage(string name) {
	printUsage(name, null);
}

void printUsage(string name, string message) {
	stderr.writeln("USAGE: %s [DAY] [PART] <INPUT_FILE> ".format(name));
	stderr.writeln("       DAY        = int between 1 and 25 (inclusive), specifiying the day to run");
	stderr.writeln("       PART       = int between 1 and 2  (inclusive), specifiying the part to run");
	stderr.writeln("       INPUT_FILE = file to read from. '-' or missing implies stdin");
	if (message != null) {
		stderr.writeln(message);
	}
	exit(-1);
}

void main(string[] args) {
	bool bigboy = false;
	int day;
	getopt(args,
			"bigboy", "Execute the so-named 'biboy' variant of this exercise", &bigboy);
	if (args.length < 3) {
		printUsage(args[0]);
	}
	try {
		day = to!int(args[1]);
	} catch (ConvException e) {
		printUsage(args[0], "[day] is not an integer");
	}

	if (day <= 0 || day > programs.length) {
		printUsage(args[0], "[day] must be between 1 and %d".format(programs.length));
	}

	int part;
	try {
		part = to!int(args[2]);
	} catch (ConvException e) {
		printUsage(args[0], "[part] is not an integer");
	}

	File file;
	if (args.length < 4 || args[3] == "-") {
		file = stdin;
	} else {
		try {
			file = File(args[3], "rb");
		} catch (ErrnoException e) {
			printUsage(args[0], "Error %d while opening input file: %s".format(e.errno, e.message));
		}
	}
	
	try {
		Variant result = programs[day - 1](part, file, bigboy, args[3..$]);
		writeln(result);
	} catch(ArgumentException e) {
		printUsage(args[0], e.msg);
	} 

}
