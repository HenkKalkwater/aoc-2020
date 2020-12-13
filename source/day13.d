import dayutil;

struct ParsedInput {
	int timestamp;
	int[] busses;
}

Variant run(int part, File input, bool bigboy, string[] args) {
	ParsedInput pInput = input.byLineCopy.array.parseInput();
	Variant result = parts!long(part, 
			() => part1(pInput),
			() => part2(pInput, 100000000000000));
	return result;
}

 ParsedInput parseInput(Range)(Range range) if (isInputRange!Range && isSomeString!(ElementType!Range)) {
	import std.conv;
	ParsedInput input;
	input.timestamp = to!int(range[0]);

	input.busses = range[1].splitter(',').map!(c => c == "x" ? -1 : c.to!int).array;
	writeln(input);
	return input;
}

int part1(ParsedInput input) {
	int earliestBus = 0;
	int earliestBusTimestamp = int.max;
	foreach(int bus; input.busses.filter!(x => x != -1)) {
		int closestTimestamp = (input.timestamp / bus + 1 ) * bus;
		writeln(closestTimestamp);
		if (closestTimestamp < earliestBusTimestamp) {
			earliestBusTimestamp = closestTimestamp;
			earliestBus = bus;
		}
	}
	// debug writefln("Bus %d at %d", earliestBus, earliestBusTimestamp);
	return earliestBus * (earliestBusTimestamp - input.timestamp);
}

long part2(ParsedInput input) {
	long result = 0;

	long startI = startFrom == 0 ? 0 : startFrom / input.busses[0];

	for (long i = startI; result == 0; i++) {
		long offset = i * input.busses[0];
		bool fail = false;

		foreach(j, subsequentBus; input.busses[1..$].enumerate(1)) {
			if (subsequentBus == -1) continue;

			if ((offset + j) % subsequentBus != 0) {
				fail = true;
				break;
			}
		}

		if (!fail) {
			result = offset;
		}

		debug {
			if (i % 10000 == 0) {
				writef("\rAt %d", offset);
				stdout.flush();
			}
		}

	}
	debug writeln();

	return result;
}

unittest {
	string[] input = [
		"939",
		"7,13,x,x,59,x,31,19"
	];
	
	ParsedInput pInput = parseInput(input);

	assert(part1(pInput) == 295);
	assert(part2(pInput) == 1068781);
}
