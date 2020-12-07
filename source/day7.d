import std.algorithm;
import std.array;
import std.format;
import std.range;
import std.stdio;
import std.string;
import std.traits;
import std.variant;

import dayutil;

alias Colour = size_t;

Variant run(int part, File input, bool bigboy, string[] args) {
	BagNode[][Colour] rules;
	input.byLineCopy.each!(x => x.parseAndAddRule(rules));

	Variant result = parts!size_t(part,
			() => part1(rules),
			() => part2(rules));
	return result;
}

size_t part1(BagNode[][Colour] rules) {
	Colour result = 0;
	foreach(Colour colour; rules.byKey()) {
		if (eventuallyContains(rules, rules[colour], colourCode("shiny gold"))) {
			result++;
		}
	}
	return result;
}

size_t part2(BagNode[][Colour] rules) {
	return countContaining(rules, rules[colourCode("shiny gold")]);
}

size_t[string] colourCodeMap;
size_t index = 0;
size_t colourCode(string colour) {
	return colourCodeMap.require(colour, index++);
}

struct BagNode {
	this(string colour, size_t count) { 
		this.colour = colourCode(colour); 
		this.count = count; 
	}
	Colour colour;
	size_t count = 0;
}

void parseAndAddRule(string rule, ref BagNode[][size_t] ruleMap) {
	auto splitRes = rule.splitter(" bags contain ").array;
	size_t key = colourCode(splitRes[0]);
	BagNode[] value = [];
	if (splitRes[1] != "no other bags.") {
		value = splitRes[1].splitter(", ").map!((x) {
				string colour;
				size_t count;
				x.splitter(" bag").array[0].formattedRead!"%d %s"(count, colour);
				return BagNode(colour, count);
			}).array;
	}
	ruleMap[key] = value;
}

bool eventuallyContains(BagNode[][Colour] colourMap, BagNode[] nodes, Colour colour) {
	foreach(BagNode node; nodes) {
		if (node.colour == colour) {
			return true;
		} else {
			if (eventuallyContains(colourMap, colourMap[node.colour], colour)) {
				return true;
			}
		}
	}
	return false;
}

size_t countContaining(BagNode[][Colour] colourMap, BagNode[] children) {
	size_t total = 0;
	//writeln("Recursing into node with ", children.length, " children");

	foreach(BagNode node; children) {
		total += node.count * (1 + countContaining(colourMap, colourMap[node.colour]));
	}
	return total;
}

unittest {
	string input = q"EOS
light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.
EOS";
	BagNode[][size_t] testRules;
	input.lineSplitter.each!(x => x.parseAndAddRule(testRules));
	assert(testRules[colourCode("light red")] == [BagNode("bright white", 1), BagNode("muted yellow", 2)]);
	assert(part1(testRules) == 4);

	assert(countContaining(testRules, testRules[colourCode("faded blue")]) == 0);
	assert(countContaining(testRules, testRules[colourCode("vibrant plum")]) == 11);
	}

unittest {
	string input = q"EOS
shiny gold bags contain 2 dark red bags.
dark red bags contain 2 dark orange bags.
dark orange bags contain 2 dark yellow bags.
dark yellow bags contain 2 dark green bags.
dark green bags contain 2 dark blue bags.
dark blue bags contain 2 dark violet bags.
dark violet bags contain no other bags.
EOS";

	BagNode[][size_t] testRules;
	input.lineSplitter.each!(x => x.parseAndAddRule(testRules));

	size_t count = part2(testRules);
	assert(count == 126);

}
