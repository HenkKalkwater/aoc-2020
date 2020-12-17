import dayutil;
version(unittest) import fluent.asserts;

struct Point {
	int x, y, z; 

	int opCmp(ref const Point p) const {
		return x - p.x + y - p.y + z - p.z;
	}
}

Variant run(int part, File input, bool bigboy, string[] args) {
	bool[Point] parsedInput = parseInput(input.byLine);
	return Variant(parts!int(part,
				() => part1(parsedInput)));
}

bool[Point] parseInput(Range)(Range range) if (isInputRange!Range && isSomeString!(ElementType!Range)){
	bool[Point] result;
	foreach(y, line; range.enumerate) {
		foreach(x, c; line) {
			if (c == '#') {
				result[Point(cast(int) x, cast(int) y, 0)] = true;
			}
		}
	}
	return result;
}

int part1(bool[Point] start) {
	immutable int BOOT_LENGTH = 6;

	bool[Point] prev = start.dup;
	foreach(i; 0..BOOT_LENGTH) {
		bool[Point] newState = prev.dup;
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
		Point min = Point(minX - 1, minY - 1, minZ - 1);
		Point max = Point(maxX + 2, maxY + 2, maxZ + 2);

		foreach(z; min.z..max.z) {
			writeln("z=", z);
			foreach(y; min.y..max.y) {
				foreach(x; min.x..max.x) {
					// Point
					bool active = prev.get(Point(x,y,z), false);

					if (active) { debug write("\x1B[42m"); }

					//write(active ? '#' : '.');
					int neighboursActive = 0;
					foreach(dx; x-1..x+2) {
						foreach(dy; y-1..y+2) {
							foreach(dz; z-1..z+2) {
								if (dx == x && dy == y && dz == z) continue;
								if (prev.get(Point(dx, dy, dz), false)) neighboursActive++;
							}
						}
					}
					if (neighboursActive > 9) {
						write("+");
					} else {
						write(neighboursActive);
					}

					if (active && (neighboursActive < 2 || neighboursActive > 3)) {
						newState[Point(x,y,z)] = false;
					} else if (!active && neighboursActive == 3) {
						newState[Point(x,y,z)] = true;
					}
					debug write("\x1B[0m");
				}
				writeln();
			}
			writeln();
		}
		assert(newState != prev);

		writeln("---");
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
	bool[Point] parsedInput = parseInput(input);
	part1(parsedInput).should.equal(112);
}
