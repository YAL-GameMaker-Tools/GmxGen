# GmxGen
This small program takes a .extension.gmx (GMS1) or .yy (GMS2) file and updates it's included files with accordance with the functions and macros defined inside.

So, instead of tinkering with the little pop-up menus for defining functions and macros per extension file, you can hint them in your files

## Building
Neko VM (note: if you didn't install it together with Haxe, get it from [the website](https://nekovm.org/)):
```
haxe build-neko.hxml
nekotools boot bin/GmxGen.n
```

## Usage
```
gmxgen .../some.extension.gmx
-- OR --
gmxgen .../some.yy
```
To index and update all compatible files in the extension. Or,
```
gmxgen .../some.extension.gmx file1.gml file2.dll
```
To only index and update particular files in the extension.

Add `--watch` to stay around and watch files for changes, e.g.
```
gmxgen .../some.yy file1.gml --watch
```

---

Below are listed the formats for hinting function and macros definitions per language.

## Macros
`#macro` definitions inside extensions are not visible to the game code so a comment-based syntax is used instead
```
#!javascript
//#macro name value
// -> normal macro

//#macro name value~
// -> hidden macro

//#macro name value : notes
// -> macro with notes (old format)
```

## GameMaker Language
GML files inside extensions consist of series of scripts delimited by `#define <name>`.

If the `#define` line is followed by one or more `/// comment` lines, they will be used to determine the number of arguments and help-line. Otherwise the number of arguments will be determined based on `argument[K]` / `argumentK` use and the script will be hidden from auto-completion.

Optional arguments are denoted as `?argName`.

Ability to add an arbitrary number of trailing arguments (such as with `ds_list_add`, for example) is denoted as `...argNames`.

### GMS1-style documentation syntax (preferred):
```cpp
#define scr_add
/// (num1, num2)

#define scr_add
/// (num1, num2)->number

#define scr_add
/// (num1, num2) : adds numbers

#define scr_add
/// (num1, num2)->number : adds numbers

#define scr_print
/// (tag, ...values)

#define scr_hidden
/// (a, b, c)~
```
### GMS2-style documentation syntax:
```cpp
#define scr_add
/// @param num1
/// @param num2
// would show as scr_add(num1, num2)

#define scr_print
/// @param tag
/// @param ...values
// would show as scr_print(tag, ...values)

#define scr_hidden
/// @param a
/// @param b
/// @param c
/// @hide
```

### Global variables
You can define global variables as
```js
//#global name
//#global name2~
```
which is shorthand for
```js
//#macro name global.g_name
//#macro name2 global.g_name2~
```
(see Macros) to save a bit of typing.

## JavaScript
Things are much akin to GML except with documentation-comment in front of the definition,
```js
///~
function add(a, b) { ... } // 2-argument, hidden

/// : adds numbers
function add(a, b) { ... } // 2-argument, visible

/// (tag, ...values)
function print(tag, rest) { ... } // variable argument count

/// : adds numbers
window.add = function(a, b) { ... } // alternate syntax (if you use closures)
```
## C++ (DLL, DyLib, SO)
For the C++ binaries, a .cpp file (named same as the binary file) should be placed in the same directory with the binary file. It doesn't have to be valid C++ (just have the definitions in the right format), so you can safely concat multiple files into a single one if needed.

### Functions
```cpp
/// adds numbers
dllx double add(double a, double b) { ... }

///
dllx char* greet(char* name) { ... }

///
dllx double measure(int* items) { ... } // treats a buffer_get_address as an array of integers
```

where `dllx` is a C++ macro name auto-detected from a line in format
```cpp
#define dllx extern "C" __declspec(dllexport)
```

### Macros
Aside of the usual `//#macro` syntax, you can also define macros in a way that is visible to both C++ and GM,
```cpp
///
#define version 101

///~
#define format 3
// ^ hidden
```

### Enums

Classic "flat" enums can be automatically converted to macros,
```cpp
enum some {
	e_A,
	e_B,
	e_C = 4
};
```
would expose macros `e_A`, `e_B`, and `e_C` equal to `0`, `1`, and `4` accordingly.

## Author and license
Author: Vadim "YellowAfterlife" Dyachenko

License: GNU GPL v3 https://www.gnu.org/licenses/gpl-3.0

- - -

Have fun*!*
