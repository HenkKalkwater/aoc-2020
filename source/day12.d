import dayutil;

enum Direction {
	NORTH,
	EAST,
	SOUTH,
	WEST,
	LEFT,
	RIGHT,
	FORWARD
}

struct Move {
	Direction direction;
	int amount;
}

Variant run(int part, File input, bool bigboy, string[] args) {
	auto parsedInput = parseInput(input.byLine);
	return Variant(parts!int(part,
				() => part1(parsedInput)));
}

auto parseInput(Range)(Range range) if (isInputRange!Range && isSomeString!(ElementType!Range)) {
	return range.map!((line) {
		Move move;

		switch(line[0]) {
		case 'N':
			move.direction = Direction.NORTH;
			break;
		case 'S':
			move.direction = Direction.SOUTH;
			break;
		case 'E':
			move.direction = Direction.EAST;
			break;
		case 'W':
			move.direction = Direction.WEST;
			break;
		case 'L':
			move.direction = Direction.LEFT;
			break;
		case 'R':
			move.direction = Direction.RIGHT;
			break;
		case 'F':
			move.direction = Direction.FORWARD;
			break;
		default:
			assert(false, "Parse error");
		}

		import std.conv;
		move.amount = to!int(line[1..$]);
		return move;
	});
}

int part1(Range)(Range range) if (isInputRange!Range && is(ElementType!Range == Move)) {
	int x, y;
	Direction direction = Direction.EAST;

	void applyWithDirection(Direction direction, int amount) {
		switch(direction) {
		case Direction.NORTH:
			y += amount;
			break;
		case Direction.SOUTH:
			y -= amount;
			break;
		case Direction.WEST:
			x += amount;
			break;
		case Direction.EAST:
			x -= amount;
			break;
		default:
			import std.format;
			assert(false, "Move called with wrong arguments (%s)".format(direction));
		}
	}

	int betterModulus(int number, int divisor) pure {
		int tmp = number % divisor;
		if (tmp < 0) tmp += divisor;
		return tmp;
	}

	foreach(move; range) {
		writefln("Facing %s (%d,%d)", direction, x, y);
		final switch(move.direction) {
		case Direction.NORTH:
		case Direction.SOUTH:
		case Direction.WEST:
		case Direction.EAST:
			applyWithDirection(move.direction, move.amount);
			break;
		case Direction.LEFT:
			direction = cast(Direction) betterModulus((cast(int) direction - move.amount / 90), 4);
			break;
		case Direction.RIGHT:
			direction = cast(Direction) betterModulus((cast(int) direction + move.amount / 90), 4);
			break;
		case Direction.FORWARD:
			applyWithDirection(direction, move.amount);
			break;
		}
	}

	import std.math;
	return abs(x) + abs(y);
}

unittest {
	string input = q"EOS
F10
N3
F7
R90
F11
EOS";

	assert(parseInput(input.lineSplitter).part1() == 25);
}
