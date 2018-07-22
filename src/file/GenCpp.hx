package file;
using GenTools;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GenCpp extends GenFile {
	override public function scan(code:String):Void {
		super.scan(code);
		
		//
		var dllExport = "dllx";
		new EReg('#define (\\w+) extern "C" __declspec(dllexport)[ \t]*\n',
		"g").each(code, function(rx:EReg) {
			dllExport = rx.matched(1);
		});
		
		// `/// doc\nDLLEXPORT double func(double arg)` -> visible
		// `DLLEXPORT char*(some* arg)` -> hidden
		var rxArg = ~/^\s*(double)?.+?(\w+)\s*$/g;
		new EReg("(" // -> hasDoc
				+ "///[ \t]*"
				+ "(?:(\\-\\>.+?):)?" // -> type
				+ "(.*)" // -> doc
			+ "\n)?"
			+ '[ \t]*$dllExport'
			+ '[ \t]+(double|char[ \t]*\\*)' // -> rtype
			+ '[ \t]+(\\w+)' // -> name
			+ "[ \t]*\\(([^\\)]*)\\)" // -> argData
		+ "", "g").each(code, function(rx:EReg) {
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
				if (doc != null) comp += " : " + doc;
				fn.comp = comp;
			}
			functions.push(fn);
		});
		
		// `///\n#define name value`
		new EReg("///.*\n"
			+ "[ \t]*#define"
			+ "[ \t]+(\\w+)" // -> name
			+ "[ \t]+(.+?)" // -> value
			+ "(~)?" // -> hide
		+ "$","gm").each(code, function(rx:EReg) {
			var i = 0;
			var name = rx.matched(++i);
			var value = rx.matched(++i);
			var hide = rx.matched(++i) != null;
			var pos = rx.matchedPos().pos;
			macros.push(new GenMacro(name, value, hide, pos));
		});
		
		var rxEnumCtr = ~/([_a-zA-Z]\w*)(?:\s*=\s*(-?\d+|0x[0-9a-fA-F]+))?\s*(?:,|$)/g;
		// `///\nenum Some { ... }`
		new EReg("///.*(~)?" // -> hide
			+ "\nenum\\s+(\\w+)" // -> name
			+ "\\s+\\{(^\x7d)\\}" // -> items
		+ "", "g").each(code, function(rx:EReg) {
			var i = 0;
			var hide = rx.matched(++i) != null;
			var ename = rx.matched(++i);
			var edata = rx.matched(++i).stripComments();
			var start = rx.matchedPos().pos;
			var next = 0;
			rxEnumCtr.each(edata, function(rc:EReg) {
				var name = rc.matched(1);
				var value = rc.matched(2);
				var curr = value != null ? Std.parseInt(value) : next;
				macros.push(new GenMacro(name, "" + curr, hide, start + rc.matchedPos().pos));
				next = curr + 1;
			});
		});
	}
}
