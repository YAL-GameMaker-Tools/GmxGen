package file;
using GenTools;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GenCpp extends GenFile {
	public static var sizeofs:Map<String, Int> = [
		"char" => 1, "byte" => 1, "uint8" => 1, "int8" => 1,
		"short" => 2, "int16" => 2, "uint16" => 2,
		"int" => 4, "int32" => 4, "uint32" => 4,
		"float" => 4, "double" => 8,
	];
	override public function scan(code:String):Void {
		super.scan(code);
		
		//
		var dllExport = "dllx";
		~/#define\s+(\w+)\s+extern\s+"C"\s+__declspec\(dllexport\)[ \t]*$/gm
		.each(code, function(rx:EReg) {
			dllExport = rx.matched(1);
		});
		
		// `/// doc\nDLLEXPORT double func(double arg)` -> visible
		// `DLLEXPORT char*(some* arg)` -> hidden
		var rxArg = ~/^\s*(double)?.+?(\w+)\s*$/g;
		new EReg("(" // -> hasDoc
				+ "///[ \t]*"
				+ "(?:(\\-\\>.+?)(?:$|:))?" // -> type
				+ "(.*)" // -> doc
			+ "\n)?"
			+ '[ \t]*$dllExport'
			+ '[ \t]+(double|char[ \t]*\\*)' // -> rtype
			+ '[ \t]+(\\w+)' // -> name
			+ "[ \t]*\\(([^\\)]*)\\)" // -> argData
		+ "", "gm").each(code, function(rx:EReg) {
			var i = 0;
			var hasDoc = rx.matched(++i) != null;
			var docType = rx.matched(++i);
			var doc = rx.matched(++i);
			var retType = rx.matched(++i);
			var name = rx.matched(++i);
			var argData = rx.matched(++i).trim();
			var fn = new GenFunc(name, rx.matchedPos().pos);
			fn.retType = retType == "double" ? GenType.Value : GenType.Pointer;
			var comp = hasDoc ? name + "(" : null;
			if (argData != "") {
				var argSplit = argData.split(",");
				var sep = false;
				for (arg in argSplit) {
					if (rxArg.match(arg)) {
						if (hasDoc) {
							if (sep) comp += ", "; else sep = true;
							comp += rxArg.matched(2);
						}
						fn.argTypes.push(rxArg.matched(1) != null
							? GenType.Value : GenType.Pointer);
					} else throw "Can't match " + arg;
				}
				fn.argCount = argSplit.length;
			} else fn.argCount = 0;
			if (hasDoc) {
				comp += ")";
				if (docType != null) comp += " " + docType;
				if (doc != null && doc != "") comp += " : " + doc;
				fn.comp = comp;
			}
			functions.push(fn);
		});
		
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
			macros.push(new GenMacro(name, value, hide, pos));
		});
		
		var rxEnumCtr = ~/([_a-zA-Z]\w*)(?:\s*=\s*(-?\d+|0x[0-9a-fA-F]+))?\s*(?:,|$)/g;
		// `///\nenum Some { ... }`
		new EReg("///.*?(~)?" // -> hide
			+ "\nenum\\s+(?:(class)\\s+)?(\\w+)" // -> name
			+ "\\s+\\{([^\x7d]*)\\}" // -> items (x7d=cubclose)
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
				macros.push(new GenMacro(name, "" + curr, hide, start + rc.matchedPos().pos));
				next = curr + 1;
			});
		});
		
		var rxStructField = ~/(?:unsigned[ \t]+)?([_a-zA-Z]\w*.*?)[ \t]+([_a-zA-Z]\w*);/g;
		// `///\nstruct Some { ... }`
		new EReg("///.*?(~)?" // -> hide
			+ "\nstruct\\s+(\\w+)" // -> name
			+ "\\s+\\{([^\x7d]*)\\}" // -> items (x7d=cubclose)
		+ "", "g").each(code, function(rx:EReg) {
			var i = 0;
			var hide = rx.matched(++i) != null;
			var sname = rx.matched(++i);
			var edata = rx.matched(++i).stripComments();
			var start = rx.matchedPos().pos;
			var offset = 0;
			rxStructField.each(edata, function(rc:EReg) {
				if (offset == -1) return;
				var type = rc.matched(1);
				var name = rc.matched(2);
				var size = sizeofs[type];
				if (size == null) {
					Sys.println('Size of $type is not known.');
					offset = -1;
					return;
				}
				macros.push(new GenMacro(
					sname + "_" + name, "" + offset,
					hide, start + rc.matchedPos().pos));
				offset += size;
			});
		});
	}
}
