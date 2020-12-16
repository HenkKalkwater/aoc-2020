import std.conv;
import std.typecons;

import dayutil; 

struct Range {
	this(int start, int end) { this.start = start; this.end = end; }
	int start;
	int end;
}

Variant run(int part, File input, bool bigboy, string[] args) {
	auto sections = input.byLineCopy.array.splitter!empty.array;
	auto tmp = parseFields(sections[0]);
	Range[][] fields = tmp[0];
	string[] fieldNames = tmp[1];

	/*debug foreach(field, name; zip(fields, fieldNames)) {
		writeln(name, ": ", field);
	}*/

	int[] myTicket = sections[1][1].splitter(",").array.map!(to!int).array;
	// debug writeln(myTicket);
	int[][] tickets = sections[2].drop(1).map!(x => x.splitter(",").array.map!(to!int).array).array;

	return Variant(parts!long(part, 
				() => part1(fields.joiner.array, tickets),
				() => part2(fields, fieldNames, myTicket, tickets)));
}

Tuple!(Range[][], string[]) parseFields(R)(R input) if (isInputRange!R && isSomeString!(ElementType!R)) {
	string[] fieldNames;
	Range[][] result;

	foreach(line; input) {
		auto split1 = line.splitter(": ").array;

		Range[] ranges = split1[1].splitter(" or ").map!((e) {
			int[] parts = e.splitter("-").array.map!(to!int).array;
			return Range(parts[0], parts[1]);
		}).array;

		fieldNames ~= [split1[0]];
		result ~= ranges;
	}

	return tuple(result, fieldNames);
}

int part1(Range[] allowedValues, int[][] tickets) {
	int errorRate = 0;

	foreach(number; tickets.joiner) {
		if (!allowedValues.canFind!((element, needle) => element.start <= needle && needle <= element.end)(number)) {
			errorRate += number;
		}
		
	}
	return errorRate;
}
long part2(Range[][] allowedValues, string[] fieldNames, int[] myTicket, int[][] tickets) {
	auto flatValues = allowedValues.joiner.array;
	// discard invalid tickets
	// debug writeln("Ticket count: ", tickets.length);
	int[][] validTickets = tickets.filter!((ticket) {
		foreach(number; ticket) {
			if (!flatValues.canFind!((element, needle) => element.start <= needle && needle <= element.end)(number)) {
				return false;
			}
		}
		return true;
	}).array;
	validTickets ~= myTicket;
	import std.format;

	// debug writeln("Valid ticket count: ", validTickets.length);

	int[][] candidatesPerField;
	candidatesPerField.reserve(fieldNames.length);

	foreach(field; 0..fieldNames.length) {
		//debug write("Matching ", fieldNames[field], " with: ");
		int[] candidates = iota(0, cast(int) fieldNames.length).filter!((column) {
			bool result = validTickets.all!(
					(ticket) => allowedValues[column]
									.canFind!((range, needle) => range.start <= needle 
							                      && needle <= range.end)(ticket[field]));
			//debug write(validTickets.map!((t) => t[column]), " (", result, "); ");
			return result;
		}).array;
		//debug writeln();
		candidatesPerField ~= [candidates];
	}

	long result = 1;
	
	immutable string pred = "a.value.length < b.value.length";
	auto sortedCandidates = candidatesPerField.enumerate.array.sort!pred;
	//debug writeln("Candidates: ", sortedCandidates);

	Tuple!(int, string)[] values;
	values.reserve(6);
	while (sortedCandidates.length > 0) {
		ulong index = sortedCandidates.front.index;
		int[] candidates = sortedCandidates.front.value;
		assert(candidates.length == 1, "Cannot solve this");

		int bestCandidate = candidates[0];

		// debug writeln(index, " maps to ", fieldNames[bestCandidate]);
		if (fieldNames[bestCandidate].startsWith("departure ")) {
			result *= myTicket[index];
			values ~= tuple(myTicket[index], fieldNames[bestCandidate]);
			//debug writeln("Taking ", myTicket[index], "; (result: ", result, ")");
		}

		sortedCandidates.popFront();
		sortedCandidates = sortedCandidates.map!((x) { 
			x.value = x.value.filter!(y => y != bestCandidate).array;
			return x;
		}).array.sort!pred;
	}
	// debug writeln(values);

	return result;
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
	auto tmp = parseFields(sections[0]);
	Range[][] fields = tmp[0];
	string[] fieldNames = tmp[1];

	assert(fields[0] == [Range(1,3), Range(5,7)]);

	int[] myTicket = sections[1].array[1].splitter(",").array.map!(to!int).array;
	int[][] tickets = sections[2].drop(1).map!(x => x.splitter(",").array.map!(to!int).array).array;
	assert(part1(fields.joiner.array, tickets) == 71);

	part2(fields, fieldNames, myTicket, tickets);
}

