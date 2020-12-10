import core.stdc.stdlib;

import std.conv;
import std.exception;
import std.format;
import std.getopt;
import std.range;
import std.stdio;
import std.variant;

import day1;
import day2;
import day3;
import day4;
import day5;
import day6;
import day7;
import day8;
import day9;
import dayutil;

immutable string progName = "aoc-2020";

version(Unix) {
	extern(C) int isatty(int);
}

Variant function(int, File, bool, string[])[] programs = [
	&day1.run,
	&day2.run,
	&day3.run,
	&day4.run,
	&day5.run,
	&day6.run,
	&day7.run,
	&day8.run,
	&day9.run,
];

void printUsage(string message = null) {
	import core.runtime;
	string name = Runtime.args[0];
	stderr.writeln("USAGE: %s [OPTIONS...] DAY PART [INPUT_FILE] (to run a specific day)".format(name));
	stderr.writeln("   OR: %s [OPTIONS...] all                   (to run each day)".format(name));
	stderr.writeln();
	stderr.writeln("       DAY             = int between 1 and 25 (inclusive), specifiying the day to run");
	stderr.writeln("       PART            = int between 1 and 2  (inclusive), specifiying the part to run");
	stderr.writeln("       INPUT_FILE      = file to read from. '-' for stdin. If not specified, use in/[DAY].txt");
	stderr.writeln();
	stderr.writeln("OPTIONS:");
	stderr.writeln("       --bigboy, -B    = use bigboy challenges");
	stderr.writeln("       --benchmark, -b = record time it took to execute ");
	if (message != null) {
		stderr.writeln();
		stderr.writeln(message);
	}
	exit(-1);
}

File getDefaultFile(int day, bool bigboy) {
	if (bigboy) {
		return File("in/bigboy/%d.txt".format(day), "rb");
	} else {
		return File("in/%d.txt".format(day), "rb");
	}
}

void main(string[] args) {
	bool bigboy = false;
	bool benchmark = false;

	try {
		auto opts = getopt(args,
			"bigboy|B", &bigboy,
			"benchmark|b", &benchmark);
		if (opts.helpWanted) {
			printUsage();
		}
	} catch (GetOptException e) {
		printUsage(e.msg);
	}
	if (args.length < 2) {
		printUsage();
	}

	bool runAll = false;
	if (args[1] == "all") {
		/+version(Posix) {
			bool tty = cast(bool) isatty(stdout.fileNo);
		} else {+/
			bool tty = false;
		//}
		runAll = true;
		writeln(tty);
		writeln("STATUS\tDAY\tPART\tRESULT");
		foreach (dayNo, day; programs.enumerate(1)) {
			File file = getDefaultFile(dayNo, bigboy);
			foreach(part; 1..3) {
				if (tty) {
					write("RUNNING\t%d\t%d\t...\r".format(dayNo, part));
					stdout.flush();
				}
				Variant result = day(part, file, bigboy, []);
				writeln("DONE   \t%d\t%d\t%s   ".format(dayNo, part, std.conv.to!string(result)));
				file.rewind();
			}
		}
	} else {
		if (args.length < 3) {
			printUsage();
		}

		int day;
		try {
			day = to!int(args[1]);
		} catch (ConvException e) {
			printUsage("DAY is not an integer");
		}

		if (day <= 0 || day > programs.length) {
			printUsage("DAY must be between 1 and %d".format(programs.length));
		}

		int part;
		try {
			part = to!int(args[2]);
		} catch (ConvException e) {
			printUsage("PART is not an integer");
		}

		File file;
		try {
			if (args.length < 4)  {
				file = getDefaultFile(day, bigboy);
			} else if(args[3] == "-") {
				file = stdin;
			} else {
				file = File(args[3], "rb");
			}
		} catch (ErrnoException e) {
			printUsage("Error %d while opening input file: %s".format(e.errno, e.message));

		}
		try {
			Variant result = programs[day - 1](part, file, bigboy, args[3..$]);
			writeln(result);
		} catch(ArgumentException e) {
			printUsage(e.msg);
		} catch(Exception e) {
			stderr.writeln("Fatal error occurred: " ~ e.msg);
			exit(-1);
		}
	}
}
