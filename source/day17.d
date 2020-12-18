import std.format;

import dayutil;
version(unittest) import fluent.asserts;

immutable char[26] letters = "xyzabcdefghijklmnopqrstuvw";

struct Point(size_t dim) {
	int[dim] elements;

	int opIndex(size_t index) {
		return elements[index];
	}

	void opIndexAssign(size_t index, int value) {
		elements[index] = value;
	}

	mixin template element(string name, size_t index) {
		mixin("@property int %s() const { return elements[%d]; }".format(name, index));
		mixin("@property void %s(int newValue) { elements[%d] = newValue; }".format(name, index));
	}
	static foreach(i; 0..dim) {
		mixin element!([letters[i]], i);
	}

	this(T...)(T args) {
		foreach(idx, arg; args) {
			elements[idx] = arg;
		}
	}
}

Variant run(int part, File input, bool bigboy, string[] args) {
	string[] lines = input.byLineCopy.array;
	return Variant(parts!int(part,
				() {
					bool[Point!3] parsedInput3 = parseInput!3(lines);
					return part1(parsedInput3);
				},
				() { 
					bool[Point!4] parsedInput4 = parseInput!4(lines);
					return part2!4(parsedInput4); 
				}));
}

bool[Point!dim] parseInput(size_t dim, Range)(Range range) if (isInputRange!Range && isSomeString!(ElementType!Range) && dim >= 2){
	bool[Point!dim] result;
	foreach(y, line; range.enumerate) {
		foreach(x, c; line) {
			if (c == '#') {
				result[Point!dim(cast(int) x, cast(int) y)] = true;
			}
		}
	}
	return result;
}

int part1(bool[Point!3] start){
	alias DPoint = Point!3;
	immutable int BOOT_LENGTH = 6;

	bool[DPoint] prev = start.dup;
	foreach(i; 0..BOOT_LENGTH) {
		bool[DPoint] newState = prev.dup;
		assert(newState == prev);

		int minX, minY, minZ, maxX, maxY, maxZ;
		foreach(e; prev.byKey) {
			if (e.x < minX) minX = e.x;
			if (e.y < minY) minY = e.y;
			if (e.z < minZ) minZ = e.z;
			if (e.x > maxX) maxX = e.x;
			if (e.y > maxY) maxY = e.y;
			if (e.z > maxZ) maxZ = e.z;
		}
		DPoint min = DPoint(minX - 1, minY - 1, minZ - 1);
		DPoint max = DPoint(maxX + 2, maxY + 2, maxZ + 2);

		foreach(z; min.z..max.z) {
			// debug writeln("z=", z);
			foreach(y; min.y..max.y) {
				foreach(x; min.x..max.x) {
					// Point
					bool active = prev.get(DPoint(x,y,z), false);

					// debug if (active) { write("\x1B[42m"); }

					//write(active ? '#' : '.');
					int neighboursActive = 0;
					foreach(dx; x-1..x+2) {
						foreach(dy; y-1..y+2) {
							foreach(dz; z-1..z+2) {
								if (dx == x && dy == y && dz == z) continue;
								if (prev.get(DPoint(dx, dy, dz), false)) neighboursActive++;
							}
						}
					}
					/+debug {
						if (neighboursActive > 9) {
							write("+");
						} else {
							write(neighboursActive);
						}
					}+/

					if (active && (neighboursActive < 2 || neighboursActive > 3)) {
						newState[DPoint(x,y,z)] = false;
					} else if (!active && neighboursActive == 3) {
						newState[DPoint(x,y,z)] = true;
					}
					//debug write("\x1B[0m");
				}
				// debug writeln();
			}
			// debug writeln();
		}
		assert(newState != prev);

		// debug writeln("---");
		prev = newState;
	}
	return cast(int) prev.byValue.count!((x) => x);
}

string GenLoops(size_t dim)() {
	string code = "";
	string xyz = "";
	string dxyz = "";
	static foreach(j; 0..dim) {
		xyz ~= [letters[j]];
		dxyz ~= "d" ~ [letters[j]];

		if (j != dim - 1) {
			xyz ~= ", ";
			dxyz ~= ", ";
		}
	}

	static foreach(j; 0..dim) {

		code ~= "foreach(%1$s; min[%2$s]..max[%2$s]) {\n".format(letters[j], j);
	}
	code ~= "bool active = prev.get(DPoint(" ~ xyz ~ "), false);\n";
	code ~= "int neighboursActive = 0;\n";

	static foreach(j; 0..dim) {
		code ~= "foreach(d%1$s; %1$s-1..%1$s+2) {\n".format(letters[j]);
	}

	code ~= "if (";
	static foreach(j; 0..dim) {
		code ~= "%1s == d%1$s".format(letters[j]);
		if (j != dim - 1) code ~= " && ";
	}
	code ~= ") continue;\n";

	code ~= "if (prev.get(DPoint(" ~ dxyz ~ "), false)) neighboursActive++;\n";
	static foreach(j; 0..dim) {
		code ~= "}\n";
	}

	code ~= "if (active && (neighboursActive < 2 || neighboursActive > 3)) {";
	code ~= "	newState[DPoint(" ~ xyz ~ ")] = false;";
	code ~= "} else if (!active && neighboursActive == 3) {";
	code ~= "	newState[DPoint(" ~ xyz ~ ")] = true;";
	code ~= "}\n";

	static foreach(j; 0..dim) {
		code ~= "}\n";
	}
	return code;
}

int part2(size_t dim)(bool[Point!dim] start){
	alias DPoint = Point!dim;
	immutable int BOOT_LENGTH = 6;

	bool[DPoint] prev = start.dup;
	foreach(i; 0..BOOT_LENGTH) {
		bool[DPoint] newState = prev.dup;
		assert(newState == prev);

		int[dim] min;
		int[dim] max;
		foreach(e; prev.byKey) {
			static foreach(j; 0..dim) {
				if (e[j] < min[j]) min[j] = e[j];
				if (e[j] > max[j]) max[j] = e[j];
			}
		}
		static foreach(j; 0..dim) {
			min[j] -= 1;
			max[j] += 2;
		}

		//writeln(GenLoops!(dim));
		mixin(GenLoops!(dim));

		prev = newState;
	}
	return cast(int) prev.byValue.count!((x) => x);
}


unittest {
	string[] input = [
		".#.",
		"..#",
		"###"
	];
	bool[Point!3] parsedInput = parseInput!3(input);
	bool[Point!4] parsedInput4 = parseInput!4(input);
	part1(parsedInput).should.equal(112);
	part2!3(parsedInput).should.equal(112);
	part2!4(parsedInput4).should.equal(848);
}
