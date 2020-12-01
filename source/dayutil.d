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
 *     args = Reference to string with arguments, usually from main.
 *     dgs = list of delegates. Which one will be called depends on args[0]
 */
R parts(R)(ref string[] args, R delegate()[] dgs ...) {
	ulong len = dgs.length;
	enforce!ArgumentException(args.length >= 1, "Please provide a part to run as a command line argument");
	int part = to!int(args[0]);
	enforce!ArgumentException(part > 0 &&  part <= len, "This day supports parts %d to %d".format(1, len));

	// Remove the first argument
	args = args[1..$];
	
	return dgs[part - 1]();
}
