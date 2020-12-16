import std.conv;

import dayutil; 

struct Range {
	this(int start, int end) { this.start = start; this.end = end; }
	int start;
	int end;
}

Variant run(int part, File input, bool bigboy, string[] args) {
	auto sections = input.byLineCopy.array.splitter!empty.array;
	Range[][string] fields = parseFields(sections[0]);

	int[][] tickets = sections[2].drop(1).map!(x => x.splitter(",").array.map!(to!int).array).array;

	return Variant(parts!int(part, 
				() => part1(fields.byValue.joiner.array, tickets)));
}

Range[][string] parseFields(R)(R input) if (isInputRange!R && isSomeString!(ElementType!R)) {
	Range[][string] result;

	foreach(line; input) {
		auto split1 = line.splitter(": ").array;

		Range[] ranges = split1[1].splitter(" or ").map!((e) {
			int[] parts = e.splitter("-").array.map!(to!int).array;
			return Range(parts[0], parts[1]);
		}).array;

		result[split1[0]] = ranges;
	}

	return result;
}

int part1(Range[] allowedValues, int[][] tickets) {
	int errorRate = 0;

	foreach(number; tickets.joiner()) {
		if (!allowedValues.canFind!((element, needle) => element.start <= needle && needle <= element.end)(number)) {
			errorRate += number;
		}
		
	}
	return errorRate;
}

unittest {
	string input = q"EOS
class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12
EOS";

	auto sections = input.lineSplitter.splitter!empty.array;
	Range[][string] fields = parseFields(sections[0]);

	assert(fields["class"] == [Range(1,3), Range(5,7)]);

	int[][] tickets = sections[2].drop(1).map!(x => x.splitter(",").array.map!(to!int).array).array;
	assert(part1(fields.byValue.joiner.array, tickets) == 71);
}

