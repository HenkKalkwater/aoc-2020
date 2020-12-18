import std.format;

import dayutil;
version(unittest) import fluent.asserts;

immutable char[26] letters = "xyzwvutsrqpomnlkjihgfedcba";

/**
 * A point with 'dim' dimensions.
 */ 
struct Point(size_t dim) {
	int[dim] elements;

	int opIndex(size_t index) {
		return elements[index];
	}

	void opIndexAssign(T : int) (T value, size_t index) {
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

///
unittest {
	Point!4 p = Point!4(5,2,3);
	p.x.should.equal(p[0]);
	p.x.should.equal(5);

	p.x = 9;
	p[0].should.equal(9);

	p[0] = 1;
	p.x.should.equal(1);

	assert(p.w == 0);
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

/*
 * Generates code for the nested loops within part2
 * Params:
 *     dim: The amount of dimensions the pocket dimensions has
 * Returns: the generated code as a string
 */
string GenLoops(size_t dim)() {
	string code = ""; // The generated code
	string xyz = ""; // Generates the string x, y, z, w, ...
	string dxyz = ""; // Genereates the string dx, dy, dz, dw, ...
	static foreach(j; 0..dim) {
		xyz ~= [letters[j]];
		dxyz ~= "d" ~ [letters[j]];

		if (j != dim - 1) {
			xyz ~= ", ";
			dxyz ~= ", ";
		}
	}

	// Generate outer loop to go over each point
	static foreach(j; 0..dim) {
		code ~= "foreach(%1$s; min[%2$s]..max[%2$s]) {\n".format(letters[j], j);
	}
	code ~= "bool active = prev.get(DPoint(" ~ xyz ~ "), false);\n";
	code ~= "int neighboursActive = 0;\n";

	// Generate code to loop over the neighbours
	static foreach(j; 0..dim) {
		code ~= "foreach(d%1$s; %1$s-1..%1$s+2) {\n".format(letters[j]);
	}

	// Skip if the current coördinate is not a neighbour, but our current node itself.
	code ~= "if (";
	static foreach(j; 0..dim) {
		code ~= "%1s == d%1$s".format(letters[j]);
		if (j != dim - 1) code ~= " && ";
	}
	code ~= ") continue;\n";

	// Increment the activeNeighbours count if the neighbour we're visiting is active
	code ~= "if (prev.get(DPoint(" ~ dxyz ~ "), false)) neighboursActive++;\n";

	// Generate closing brackers for the inner loop
	static foreach(j; 0..dim) {
		code ~= "}\n";
	}

	// Check if the current point should stay active.
	code ~= "if (active && (neighboursActive < 2 || neighboursActive > 3)) {";
	code ~= "	newState[DPoint(" ~ xyz ~ ")] = false;";
	code ~= "} else if (!active && neighboursActive == 3) {";
	code ~= "	newState[DPoint(" ~ xyz ~ ")] = true;";
	code ~= "}\n";

	// Generate closing brackers for the outer loop
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
			// Determine the bounds for each dimension
			static foreach(j; 0..dim) {
				if (e[j] < min[j]) min[j] = e[j];
				if (e[j] > max[j]) max[j] = e[j];
			}
		}
		static foreach(j; 0..dim) {
			min[j] -= 1;
			max[j] += 2;
		}

		//debug writeln(GenLoops!(dim));

		// Sadly, the only way I am a ware of to generate dim amount of nested loops
		// is by using mixins
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
