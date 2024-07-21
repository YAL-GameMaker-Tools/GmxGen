package file;
import tools.GenReader;
import ext.GenFunc;
import ext.GenMacro;
import ext.GenType;
import file.GenCppAutoStruct;
import file.GenCppStructOffsets;
import haxe.io.Path;
using tools.GenTools;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GenCpp extends GenFile {
	public function procCppFunc(fn:GenFunc, retType:String, args:Array<{ name:String, type:String }>) {
		var hasDoc = fn.comp != null;
		fn.retType = retType == "double" || retType == "void" ? GenType.Value : GenType.Pointer;
		var sep = false;
		for (argp in args) {
			if (hasDoc) {
				if (sep) fn.comp += ", "; else sep = true;
				fn.comp += argp.name;
			}
			fn.argTypes.push(argp.type == "double" ? GenType.Value : GenType.Pointer);
		}
	}
	function scanUnmangled(code:String):Void {
		// `/// doc\nDLLEXPORT double func(double arg)` -> visible
		// `DLLEXPORT char*(some* arg)` -> hidden
		var dllExport = "dllx";
		~/#define\s+(\w+)\s+extern\s+"C"\s+__declspec\(dllexport\)[ \t]*$/gm
		.each(code, function(rx:EReg) {
			dllExport = rx.matched(1);
		});
		
		var rxArg = ~/^\s*(.+?)\s*(\w+)\s*$/g; // 1: is non-pointer, 2: name
		new EReg("(" // -> hasDoc
				+ "///[ \t]*"
				+ "(?:" + "(\\w+)" + "[ \t]*)?" // -> name override (opt.)
				+ "(?:" + "\\(" + ".*?" + "\\)" + ")?" // (args) (discard)
				+ "(?:(\\-\\>.+?)(?:$|:))?" // -> type
				+ "(.*)" // -> doc
			+ "\n)?"
			+ '[ \t]*$dllExport'
			+ '[ \t]+(void|double|(?:const[ \t]+)?char[ \t]*\\*)' // -> rtype
			+ '[ \t]+(\\w+)' // -> name
			+ "[ \t]*\\(([^\\)]*)\\)" // -> argData
		+ "", "gm").each(code, function(rx:EReg) {
			var i = 0;
			var hasDoc = rx.matched(++i) != null;
			var docName = rx.matched(++i);
			var docType = rx.matched(++i);
			var doc = rx.matched(++i);
			var retType = rx.matched(++i);
			var name = rx.matched(++i);
			var argData = rx.matched(++i).trim();
			var fn = new GenFunc(name, rx.matchedPos().pos);
			if (docName != null) fn.name = docName;
			if (hasDoc) fn.comp = fn.name + "(";
			
			var argPairs = [];
			if (argData.trim() != "") {
				var argSplit = argData.split(",");
				for (arg in argSplit) {
					if (rxArg.match(arg)) {
						argPairs.push({
							type: rxArg.matched(1),
							name: rxArg.matched(2),
						});
					} else throw 'Can\'t match argument `$arg` in function $name';
				}
				fn.argCount = argSplit.length;
			} else fn.argCount = 0;
			
			procCppFunc(fn, retType, argPairs);
			
			if (hasDoc) {
				fn.comp += ")";
				if (docType != null) fn.comp += docType;
				if (doc != null && doc != "") fn.comp += " : " + doc;
			}
			
			addFunction(fn);
		});
	}
	function scanMangled(code:String):Void {
		var dllExport2 = "dllm";
		~/#define\s+(\w+)\s+__declspec\(dllexport\)[ \t]*$/gm
		.each(code, function(rx:EReg) {
			dllExport2 = rx.matched(1);
		});
		var argMacro = "dllm_args";
		new EReg("#define\\s+(\\w+)"
			+ "\\s+" + "RValue" + "\\s*" + "[\\*&]" + "\\s*" + "\\w+" + "\\s*," // result
			+ "\\s+" + "CInstance" + "\\s*" + "\\*" + "\\s*" + "\\w+" + "\\s*," // self
			+ "\\s+" + "CInstance" + "\\s*" + "\\*" + "\\s*" + "\\w+" + "\\s*," // other
			+ "\\s+" + "int" + "\\s+" + "\\w+" + "\\s*," // argc
			+ "\\s+" + "RValue" + "\\s*" + "\\*" + "\\s*" + "\\w+" + "\\s*" // argv
		+ "", "gm").each(code, function(rx:EReg) {
			argMacro = rx.matched(1);
		});
		
		new EReg("("
			+ "///[ \t]*"
			+ "(?:(\\w+)[ \t]*)?" // -> name override (opt.)
			+ "\\(" + "(.*?)" + "\\)" // -> argData
			+ "(?:(\\-\\>.+?)(?:$|:))?" // -> type
			+ "(.*)" // -> doc
			+ "\n[ \t]*)?"
			+ dllExport2
			+ "[ \t]*void"
			+ "[ \t]*(\\w+)" // -> name
			+ "[ \t]*\\("
			+ '[ \t]*(?:RValue\\s*[*&]|$argMacro)'
		+ "", "gm").each(code, function(rx:EReg) {
			var rxi = 0;
			var hasDoc = rx.matched(++rxi) != null;
			var displayName = rx.matched(++rxi);
			var argData = rx.matched(++rxi);
			var retType = rx.matched(++rxi);
			var docText = rx.matched(++rxi);
			var nativeName = rx.matched(++rxi);
			if (!hasDoc) {
				argData = "...";
				docText = "";
			}
			
			var fn = new GenFunc(nativeName, rx.matchedPos().pos);
			var comp:String;
			if (displayName != null) {
				fn.name = displayName;
				comp = displayName;
			} else comp = nativeName;
			comp += "(" + argData + ")";
			if (retType != null) comp += retType;
			fn.comp = hasDoc ? comp : null;
			fn.argCount = -1;
			
			addFunction(fn);
		});
	}
	function scanMacros(code:String) {
		// `///\n#define name value`
		new EReg("///.*?(~)?\n" // -> hide
			+ "[ \t]*#define"
			+ "[ \t]+(\\w+)" // -> name
			+ "[ \t]+(.+?)" // -> value
		+ "$","gm").each(code, function(rx:EReg) {
			var i = 0;
			var hide = rx.matched(++i) != null;
			var name = rx.matched(++i);
			var value = rx.matched(++i);
			var pos = rx.matchedPos().pos;
			addMacro(new GenMacro(name, value, hide, pos));
		});
	}
	function scanEnums(code:String) {
		var rxEnumCtr = new EReg(
			"([_a-zA-Z]\\w*)" // -> name
			+ "(?:"
				+ "\\s*=\\s*"
				+ "(-?\\d+|0x[0-9a-fA-F]+)" // -> value
			+ ")?"
			+ "\\s*(?:,|$)"
		, "g");
		//var rxEnumCtr = ~/([_a-zA-Z]\w*)(?:\s*=\s*(-?\d+|0x[0-9a-fA-F]+))?\s*(?:,|$)/g;
		// `///\nenum Some { ... }`
		// `///\nenum class Some : int { ... }`
		new EReg("///.*?(~)?" // -> hide
			+ "\n[ \t]*enum\\b\\s*"
			+ "(?:(class)\\b\\s*)?" // -> class
			+ "(\\w+)\\b\\s*" // -> name
			+ "(?::\\s*\\w+\\b\\s*)?" // type (opt.)
			+ "\\{([\\s\\S]*?)\\}" // -> items
		+ "", "g").each(code, function(rx:EReg) {
			var i = 0;
			var hide = rx.matched(++i) != null;
			var eclass = rx.matched(++i) != null;
			var ename = rx.matched(++i);
			var edata = rx.matched(++i).stripComments();
			var start = rx.matchedPos().pos;
			var next = 0;
			rxEnumCtr.each(edata, function(rc:EReg) {
				var name = rc.matched(1);
				if (eclass) name = ename + "_" + name;
				var value = rc.matched(2);
				var curr = value != null ? Std.parseInt(value) : next;
				addMacro(new GenMacro(name, "" + curr, hide, start + rc.matchedPos().pos));
				next = curr + 1;
			});
		});
	}
	function scanStructs(code:String) {
		var autoStructs = false;
		~/\/\/\/[ \t]*@autostruct\b[ \t]*(.+)/.each(code, function(rx:EReg) {
			autoStructs = true;
			var rel = rx.matched(1);
			var gml0 = ext.fs.getContent(rel);
			var gml1 = GenCppAutoStruct.proc(code, gml0);
			if (gml0 != gml1) {
				Sys.println('Updated $rel with structs');
				ext.fs.setContent(rel, gml1);
			}
		});
		if (!autoStructs) GenCppStructOffsets.scanStructOffsets(this, code);
	}
	function scanBlock(code:String) {
		scanUnmangled(code);
		scanMangled(code);
		scanMacros(code);
		scanEnums(code);
		scanStructs(code);
	}
	function scanOutsideBlockComments(code:String, fn:String->Void) {
		var q = new GenReader(code, "");
		var start = 0;
		inline function flush(till:Int) {
			if (start >= till) return;
			fn(code.substring(start, till));
		}
		while (q.loop) {
			var c = q.read();
			switch (c) {
				case '/'.code: {
					switch (q.peek()) {
						case '/'.code: {
							while (q.loop) {
								if (q.peek() == '\n'.code) break;
								q.skip();
							}
						};
						case '*'.code: {
							q.skip();
							flush(q.pos);
							while (q.loop) {
								if (q.peek() == '*'.code && q.peekAt(1) == '/'.code) {
									q.skip(2);
									start = q.pos;
									break;
								} else q.skip();
							}
						};
					}
				}; // /
				case '"'.code: {
					while (q.loop) {
						c = q.read();
						if (c == '"'.code) break;
						if (c == '\\'.code) q.skip();
					}
				};
			}
		}
		flush(q.pos);
	}
	override public function scan(code:String):Void {
		super.scan(code);
		scanOutsideBlockComments(code, scanBlock);
	}
}
