import std.array;
import std.algorithm;
import std.conv;
import std.range;
import std.stdio;
import std.string;
import std.traits;
import std.variant;

import dayutil;

Variant run(int part, File input, bool bigboy, string[] args) {
	Instruction[] instructions = readInput(input.byLine);

	Variant result = parts!int(part,
			() => part1(instructions),
			() => part2(instructions));

	return result;
}

enum Memomic {
	NOP,
	ACC,
	JMP
}

struct Instruction {
	Memomic memomic;
	int arg;
}

Instruction[] readInput(R)(R range) if (isInputRange!R && isSomeString!(ElementType!R)) {
	return range.map!((text) {
		Instruction instruction;
		switch(text[0..3]) {
		case "nop":
			instruction.memomic = Memomic.NOP;
			break;
		case "acc":
			instruction.memomic = Memomic.ACC;
			break;
		case "jmp":
			instruction.memomic = Memomic.JMP;
			break;
		default: 
			writeln("unknown instruction: ", text[0..3]);
			break;
		}
		//int sign = text[4] == '+' ? 1 : -1;
		// to!int correctly handles + and -
		instruction.arg = to!int(text[4..$]);
		return instruction;
	}).array;
}

int part1(ref Instruction[] instrs) {
	int acc = 0;
	int pc = 0;
	int[] visited;

	while(!visited.canFind(pc)) {
		Instruction curInstr = instrs[pc];
		visited ~= [pc];
		switch(curInstr.memomic) {
		case Memomic.NOP:
			pc += 1;
			break;
		case Memomic.ACC:
			pc += 1;
			acc += curInstr.arg;
			break;
		case Memomic.JMP:
			pc += curInstr.arg;
			break;
		default: 
			break;
		}
	}

	return acc;
}

unittest {
	string input = q"EOS
nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6
EOS";
	auto instrs = readInput(input.lineSplitter);
	assert(part1(instrs) == 5);
}

int part2(ref Instruction[] instrs) {
	bool finishes(ref Instruction[] instrs, out int acc) {
		int pc = 0;
		int[] visited;

		while(!visited.canFind(pc)) {
			Instruction curInstr = instrs[pc];
			visited ~= [pc];
			switch(curInstr.memomic) {
			case Memomic.NOP:
				pc += 1;
				break;
			case Memomic.ACC:
				pc += 1;
				acc += curInstr.arg;
				break;
			case Memomic.JMP:
				pc += curInstr.arg;
				break;
			default: 
				break;
			}
			if (pc == instrs.length) return true;
		}
		return false;
	}
	
	int acc;
	// O(n^2) go brrr
	for(size_t i = 0; i < instrs.length; i++) {
		if (instrs[i].memomic == Memomic.ACC) continue;
		Instruction[] dup = instrs.dup;
		dup[i].memomic = dup[i].memomic == Memomic.NOP ? Memomic.JMP : Memomic.NOP;
		if (finishes(dup, acc)) return acc;
	}
	return -1;
}

unittest {
	string input = q"EOS
nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6
EOS";
	auto instrs = readInput(input.lineSplitter);
	assert(part2(instrs) == 8);
}
