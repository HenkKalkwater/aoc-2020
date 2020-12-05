import std.algorithm;
import std.array;
import std.functional;
import std.range;
import std.stdio;
import std.traits;

import dayutil;

struct SerName { string name; };
struct Passport {
	@SerName("byr") string birthYear = "";
	@SerName("cid") string countryId = "";
	@SerName("ecl") string eyeColour = "";
	@SerName("eyr") string expireYear = "";
	@SerName("hcl") string hairColour = "";
	@SerName("hgt") string height = "";
	@SerName("iyr") string issueYear = "";
	@SerName("pid") string passwordId = "";

	bool isValid() {
		return birthYear.length > 0 && issueYear.length > 0 && expireYear.length > 0 
			&& height.length > 0 && hairColour.length > 0 && eyeColour.length > 0 
			&& eyeColour.length > 0 && passwordId.length > 0;
	}
}
void run(string[] args) {
	auto lines = stdin.byLineCopy.array;
	size_t result = parts!size_t(args, 
			() => part1(lines));
	writeln(result);
}

size_t part1(Range)(Range range) if (isInputRange!Range) {
	return range.tokenize()
		.map!(x => x.deserialize!Passport)
		.filter!(x => x.isValid)
		.count;
}

/**
 * Deserializes a type from an array in the form of [[key, value], ...] where key an value are
 * strings.
 *
 * NOTE: THE NAME OF THE FIELDS WITHIN T MUST BE ORDERED ALPHABETICALLY!
 */
T deserialize(T, Range)(Range r) 
	if (isForwardRange!Range && isAggregateType!T) {

	import std.conv;

	T result;
	string fName;
	alias pred = x => to!string(x[0]) == fName;
	static foreach(index, field; T.tupleof) {
		static if (hasUDA!(field, SerName)) {
			fName = getUDAs!(field, SerName)[0].name;
		} else {
			fName = field.stringof;
		}
		if (r.canFind!(pred)) {
			result.tupleof[index] = to!(typeof(field))(r.save.find!(pred)[0][1]);
		}
	}
	return result;
}

unittest {
	struct Example {
		string foo;
		@SerName("baz") int bar;
	}
	Example example = deserialize!Example([["foo", "12"], ["baz", "32"]]);
	assert(example.foo == "12");
	assert(example.bar == 32);
}


/**
 * Takes the input as a range of a array of a string per line
 *
 * returns: [[[key, value], ...], ...]
 */
auto tokenize(Range)(Range range) if (isInputRange!Range) {
	return range.splitter!(x => x.length == 0)
		.map!(records => records.joiner(" "))
		.map!(records => records.array.splitter(' ').map!(record => record.splitter(':').array).array
				.sort!(((a,b) => a[0] < b[0])));
}


unittest {
	import std.string;
	string testdata = q"EOS
ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm

hcl:#cfa07d eyr:2025 pid:166559648
iyr:2011 ecl:brn hgt:59in
EOS";
	assert(testdata
			.lineSplitter.part1 == 2);
}
