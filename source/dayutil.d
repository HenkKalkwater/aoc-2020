public import std.array;
public import std.algorithm;
public import std.range;
public import std.string;
public import std.stdio;
public import std.traits;
public import std.variant;

import std.conv;
import std.exception;
import std.format;

class ArgumentException : Exception{
	mixin basicExceptionCtors;
}

/**
 * Helper function for implementing 
 *
 * Looks at the first argument string, and calls the delegate dgs[i + 1], while making sure nothing
   goes out bounds.
 *
 * Params:
 *     part = The part to run.
 *     dgs = list of delegates. Which one will be called depends on args[0]
 */
R parts(R)(int part, R delegate()[] dgs ...) {
	ulong len = dgs.length;
	enforce!ArgumentException(part > 0 &&  part <= len, "This day supports parts %d to %d".format(1, len));
	
	return dgs[part - 1]();
}
