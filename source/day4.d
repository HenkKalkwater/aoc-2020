import std.algorithm;
import std.array;
import std.functional;
import std.range;
import std.stdio;
import std.traits;
import std.variant;

import dayutil;

bool inbetween(T)(T value, T min, T max) {
	return min <= value && value <= max;
}

struct SerName { string name; };
struct Passport {
	@SerName("byr") short birthYear = -1;
	@SerName("cid") string countryId = "";
	@SerName("ecl") string eyeColour = "";
	@SerName("eyr") short expireYear = -1;
	@SerName("hcl") string hairColour = "";
	@SerName("hgt") string height = "";
	@SerName("iyr") short issueYear = -1;
	@SerName("pid") string passwordId = "";

	
	bool isValid() {
		import std.ascii;
		import std.conv;
		return birthYear.inbetween!short(1920, 2002)
			&& issueYear.inbetween!short(2010, 2020)
			&& expireYear.inbetween!short(2020, 2030)
			&& (height.endsWith("cm")
					? to!int(height[0..$-2]).inbetween(150, 193)
					: height.endsWith("in")
						? to!int(height[0..$-2]).inbetween(59, 76)
						: false)
			&& hairColour.startsWith("#") && hairColour.length == 7 
			&& hairColour[1..6].all!(c => c <= 'f' && c >= '0' && (c <= '9' || c >= 'a'))
			&& eyeColour.among("amb", "blu", "brn", "gry", "grn", "hzl", "oth")
			&& passwordId.length == 9 && passwordId.all!isDigit;
	}

	bool hasAllFields() {
		return birthYear >= 0 && issueYear >= 0 && expireYear >= 0 
			&& height.length > 0 && hairColour.length > 0 && eyeColour.length > 0 
			&& eyeColour.length > 0 && passwordId.length > 0;
	}
}
Variant run(int part, File input, bool bigboy, string[] args) {
	auto lines = input.byLineCopy.array;
	Variant result = parts!size_t(part, 
			() => part1(lines),
			() => part2(lines));
	return result;
}

size_t part1(Range)(Range range) if (isInputRange!Range) {
	return range.tokenize()
		.map!(x => x.deserialize!Passport)
		.filter!(x => x.hasAllFields)
		.count;
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

size_t part2(Range)(Range range) if (isInputRange!Range) {
	return range.tokenize()
		.map!(x => x.deserialize!Passport)
		.filter!(x => x.isValid)
		.count;
}

unittest {
	import std.string;
string invalid = q"EOF
eyr:1972 cid:100
hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

iyr:2019
hcl:#602927 eyr:1967 hgt:170cm
ecl:grn pid:012533040 byr:1946

hcl:dab227 iyr:2012
ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

hgt:59cm ecl:zzz
eyr:2038 hcl:74454a iyr:2023 pid:3556412378 byr:2007
EOF";
	
	assert(invalid.lineSplitter.part2 == 0);
}

unittest {
	import std.string;
string invalid = q"EOF
pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
hcl:#623a2f

eyr:2029 ecl:blu cid:129 byr:1989
iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

hcl:#888785
hgt:164cm byr:2001 iyr:2015 cid:88
pid:545766238 ecl:hzl
eyr:2022

iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
EOF";
	
	assert(invalid.lineSplitter.part2 == 4);
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

