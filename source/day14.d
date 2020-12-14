import std.conv;

import dayutil;

immutable int MEM_SIZE = 36;

enum Operation {
	WRITE_BITMASK,
	WRITE_MEM
}

enum Value {
	ZERO,
	ONE,
	X,
}

struct Instruction {
	Operation op;
	long address;
	Value[] value;
}

Variant run(int part, File input, bool bigboy, string[] args) {
	auto parsed = input.byLineCopy.parseInput;
	writeln(parsed);

	return Variant(parts!long(part,
				() => part1(parsed),
				() => part2(parsed)));
}

Instruction[] parseInput(Range)(Range range) if (isInputRange!Range && isSomeString!(ElementType!Range)) {
	return range.map!((x) {
		Instruction instr;
		if (x.startsWith("mask = ")) {
			instr.op = Operation.WRITE_BITMASK;
			instr.value.reserve(x.length - 8);
			foreach(c; x[7..$]) {
				switch(c) {
				case 'X':
					instr.value ~= [Value.X];
					break;
				case '1':
					instr.value ~= [Value.ONE];
					break;
				case '0':
					instr.value ~= [Value.ZERO];
					break;
				default:
					assert(false, "Invalid input");
				}
			}
		} else {
			instr.op = Operation.WRITE_MEM;
			size_t secondBracket = x.countUntil(']');
			instr.address = to!long(x[4..secondBracket]);
			long tmp = to!long(x[secondBracket + 4..$]);
			instr.value = toStupidBinary(tmp);
		}
		return instr;
	}).array;
}

Value[] toStupidBinary(long val) {
	Value[] result;
	while (val != 0) {
		result ~= [(val & 1) == 1 ? Value.ONE : Value.ZERO];
		val >>= 1;
	}
	result.length = MEM_SIZE;
	return result.reverse;
}

long fromStupidBinary(Value[] val) {
	long result;
	foreach(bit; val) {
		result <<= 1;
		if (bit == Value.ONE) {
			result |= 1;
		}
	}
	return result;
}

long part1(Instruction[] instructions) {
	Value[] bitmask;
	long[long] memory;
	foreach(instruction; instructions) {
	final switch(instruction.op) {
		case Operation.WRITE_BITMASK:
			bitmask = instruction.value;
			break;
		case Operation.WRITE_MEM:
			Value[] tmp = instruction.value;
			foreach(ref bit, mask; lockstep(tmp.retro, bitmask.retro)) {
				final switch(mask) {
					case Value.ZERO:
						bit = Value.ZERO;
						break;
					case Value.ONE:
						bit = Value.ONE;
						break;
					case Value.X: break;
				}
			}
			//writeln(tmp);
			memory[instruction.address] = fromStupidBinary(tmp);
			break;
	}
	}
	long sum = 0;
	foreach(e; memory.byValue()) {
		//writeln(e);
		sum += e;
	}
	return sum;
}

int part2(Range)(Range range) if (isInputRange!Range) {
	
	return 0;
}

unittest {
string input = q"EOS
mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
mem[8] = 11
mem[7] = 101
mem[8] = 0
EOS";
	auto parsed = parseInput(input.lineSplitter);
	writeln(parsed);
	writeln(part1(parsed.save));
	assert(part1(parsed.save) == 165);
}
