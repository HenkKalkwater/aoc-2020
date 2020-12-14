import std.algorithm;
import std.typecons;

import dayutil;

struct ParsedInput {
	long timestamp;
	long[] busses;
}

Variant run(int part, File input, bool bigboy, string[] args) {
	ParsedInput pInput = input.byLineCopy.array.parseInput();
	Variant result = parts!long(part, 
			() => part1(pInput),
			() => part2(pInput));
	return result;
}

 ParsedInput parseInput(Range)(Range range) if (isInputRange!Range && isSomeString!(ElementType!Range)) {
	import std.conv;
	ParsedInput input;
	input.timestamp = to!int(range[0]);

	input.busses = range[1].splitter(',').map!(c => c == "x" ? -1 : c.to!long).array;
	return input;
}

long part1(ParsedInput input) {
	long earliestBus = 0;
	long earliestBusTimestamp = long.max;
	foreach(long bus; input.busses.filter!(x => x != -1)) {
		long closestTimestamp = (input.timestamp / bus + 1 ) * bus;
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
	/+long[] remainders;
	long[] divisors;

	// Too much, but we're not short on memory
	remainders.reserve(input.busses.length);
	divisors.reserve(input.busses.length);
	foreach (remainder, divisor; input.busses) {
		if (divisor < 0) continue;
		remainders ~= [remainder % divisor];
		divisors ~= [divisor];
	}

	writeln(remainders);
	writeln(divisors);

	long N = divisors.fold!((a,b) => a * b);
	writeln(N);
	long[] Ns; Ns.length = divisors.length;
	long[] Xs; Xs.length = divisors.length;
	long[] BNXs; BNXs.length = divisors.length;

	foreach(i, divisor; divisors) {
		Ns[i] = N / divisor;
	}

	foreach(ref Xi, Ni, Di; lockstep(Xs, Ns, divisors)) {
		long a = Ni % Di;
		long b;
		for(b = 0; (a * b) % Di != 1; b++) {}
		Xi = b;
	}
	writeln(Xs);

	foreach(ref BNXi, Ri, Ni, Xi; lockstep(BNXs, remainders, Ns, Xs)) {
		BNXi = Ri * Ni * Xi;
	}
	long result = BNXs.sum() % N;+/
	Tuple!(size_t, "index", long, "value")[] busses = input.busses.enumerate.filter!((e) => e.value != -1).array;

	long time = 0;
	long step = busses[0].value;

	foreach(bus; busses[1..$]) {
		for(; (time + bus.index) % bus.value != 0; time += step) {}
		step *= bus.value;
	}
	writeln(time);
	return time;
}

unittest {
	string[] input = [
		"939",
		"7,13,x,x,59,x,31,19"
	];
	
	ParsedInput pInput = parseInput(input);

	assert(part1(pInput) == 295);
	ParsedInput p2;
	p2.busses = [-1, 7, -1, 5, -1, -1, 8];
	//assert(part2(p2) == 78);

	assert(part2(pInput) == 1068781);
}
