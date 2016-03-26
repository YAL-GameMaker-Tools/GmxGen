# GmxGen
This small program takes a .extension.gmx file and updates it's included files with accordance with the functions and macros defined inside.

So, instead of tinkering with the little pop-up menus for defining functions and macros per extension file, you can hint them in your files
## Usage
```
gmxgen .../some.extension.gmx
```
To index and update all compatible files in the extension. Or,
```
gmxgen .../some.extension.gmx file1.gml file2.dll
```
To only index and update particular files in the extension.

## Syntax
Below are listed the formats for hinting function and macros definitions per language.

If a definition does not have a description attached, it will be converted into a "hidden" function/macros (usable, but not shown in auto-completion). Definitions with descriptions (even blank descriptions, such as `/// func() :`) will be visible in auto-completion.

### GML & JS
**Function definitions:**
```
#!javascript
/// function_name(argument1, argument2) : Description
```
` : Description` can be omitted.

Optional parameters can be hinted with Haxe-style prefixes and suffixes:
```
#!javascript
/// function_name(req, ?opt1, opt2 = 0)
```
Function definitions with optional parameters will be marked as having variable argument count.

You can also explicitly define variable argument count via `...`, for example:
```
#!javascript
/// trace(...values)
```

**Macros definitions:**
```
#!javascript
/// macro_name = expression
```
Or
```
/// macro_name = expression : Description
```
Expression will be taken "as-is", so use parenthesis, if you must.

### C++ (DLL, DyLib, SO)
For the C++ binaries, a .cpp file (named same as the binary file) should be lying next to the binary file. It doesn't have to be valid C++ (just have the definitions in the right format), so you can safely concat multiple files into a single one if needed.

**Function definitions:**
```
#!cpp
/// Description
dllx type function_name(type argument1, type argument2)
```
`type` can be either `double` or `char*`;

Description-line is optional;

`dllx` is a macro expanding to the export prefix, usually
```
#!cpp
#define dllx extern "C" __declspec(dllexport)
```

**Macros definitions:**

You can use the same syntax as for GML/JS, or hint C++ macro definitions for constants:
```
#!cpp
/// Description
#define name value
```
In this case, the documentation line (even if blank) is required, to avoid exporting everything.

## Author and license
Author: Vadim "YellowAfterlife" Dyachenko

License: GNU GPL v3 https://www.gnu.org/licenses/gpl-3.0

- - -

Have fun*!*
