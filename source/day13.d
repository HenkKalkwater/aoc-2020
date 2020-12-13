import dayutil;

struct ParsedInput {
	int timestamp;
	int[] busses;
}

Variant run(int part, File input, bool bigboy, string[] args) {
	ParsedInput pInput = input.byLineCopy.array.parseInput();
	Variant result = parts!int(part, 
			() => part1(pInput));
	return result;
}

 ParsedInput parseInput(Range)(Range range) if (isInputRange!Range && isSomeString!(ElementType!Range)) {
	import std.conv;
	ParsedInput input;
	input.timestamp = to!int(range[0]);

	input.busses = range[1].splitter(',').filter!(c => c != "x").map!(to!int).array;
	writeln(input);
	return input;
}

int part1(ParsedInput input) {
	import std.math;

	int earliestBus = 0;
	int earliestBusTimestamp = int.max;
	foreach(int bus; input.busses) {
		int closestTimestamp = (input.timestamp / bus + 1 ) * bus;
		writeln(closestTimestamp);
		if (closestTimestamp < earliestBusTimestamp) {
			earliestBusTimestamp = closestTimestamp;
			earliestBus = bus;
		}
	}
	writefln("Bus %d at %d", earliestBus, earliestBusTimestamp);
	return earliestBus * (earliestBusTimestamp - input.timestamp);
}

unittest {
	string[] input = [
		"939",
		"7,13,x,x,59,x,31,19"
	];
	
	ParsedInput pInput = parseInput(input);

	assert(part1(pInput) == 295);
}
