/// @author YellowAfterlife

#include "stdafx.h"
#include <string>

// GmxGen will add signatures for functions that are tagged with a `dllx` "attribute".
// You can use your own tag if it's defined in the same file, like so:

#if defined(WIN32)
#define dllx extern "C" __declspec(dllexport)
#elif defined(GNUC)
#define dllx extern "C" __attribute__ ((visibility("default"))) 
#else
#define dllx extern "C"
#endif

// For unmangled functions, GameMaker supports functions that:
// 1. Take `double` or pointer-based (`const char*` strings, `void*`, etc.) arguments.
// 2. Feature no more than 4 arguments if pointer-based arguments are used.
// 3. Return `double`, or `const char*`

static double ggt_stored_number = 0;
// Functions are marked as hidden by default.
// This is well-respected in GMS1 and not very well-respected in GMS2.

dllx void ggt_cpp_reset_number() {
	// technically GM will be getting undefined value as a number back,
	// but you can't crash a program with a bad floating-point number
	ggt_stored_number = 0;
}

// To mark a function as visible, prepend it by a `///` comment.
// The contents might be shown in the IDE as a suffix after the function signature.

///
dllx void ggt_cpp_set_number(double v) {
	ggt_stored_number = v;
}

// You can also have ->type
/// ->int
dllx double ggt_cpp_get_number() {
	return ggt_stored_number;
}

// You can add some macros for GML like so:
//#macro ggt_cpp_number ggt_cpp_get_number()

// You can also export existing macros by adding a `///` comment next to them.
// Note that this will copy the value to GM extension literally, so it's mostly good for numbers or strings.
///
#define ggt_cpp_number_zero 0

// You can also export enums if they are using constant values:
///
enum class ggt_cpp_number {
	one = 1,
	two,
	three,
};

// Flat enums are also supported:
///
enum ggt_cpp_number_alt {
	ggt_cpp_number_three = 3,
	ggt_cpp_number_four,
	ggt_cpp_number_five,
};

///
dllx double ggt_cpp_add_numbers(double a, double b) {
	return a + b;
}

///
dllx const char* ggt_cpp_add_strings(const char* a, const char* b) {
	// GameMaker will make a copy of a string upon receiving it,
	// so make sure that it's still valid upon exiting your function
	// A static std::string is by far the easiest way around this.
	static std::string result{};
	result = a;
	result += b;
	return result.c_str();
}

///
dllx const char* ggt_cpp_add_mixed(const char* a, double b) {
	static std::string result{};
	result = a;
	result += std::to_string(b);
	return result.c_str();
}

///
dllx void ggt_cpp_fill_bytes(uint8_t* buf) {
	// buffer_get_address() gives you a pointer to the buffer, which you can pass to C++
	// you can mark the argument as a pointer to whatever you'd like - it's just memory after all
	buf[0] = 1;
	buf[1] = 2;
}