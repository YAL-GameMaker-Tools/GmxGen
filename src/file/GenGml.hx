package file;
import file.GenFile;
using GenTools;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GenGml extends file.GenFile {
	/** Generally 1.4, 2.2, or 2.3 */
	public static var version:Float = 2.3;
	public function new() {
		super();
		funcKind = 2;
	}
	override public function patch(code:String):String {
		var changed = false;
		code = (new EReg("/([/*])(" // -> prefix, line without prefix
			+ "(?:\\s*\\()?" // opt. (
			+ "\\s*GMS"
			+ "\\s*(==|!=|>=|>|<=|<)" // -> operator
			+ "\\s*(\\d+(?:\\.[\\d*]))" // -> version
			+ "(?:\\s*\\))?" // opt. )
		+ ":)", "g")).map(code, function(rx:EReg) {
			var gr = 0;
			var pre = rx.matched(++gr);
			var line = rx.matched(++gr);
			var op = rx.matched(++gr);
			var verStr = rx.matched(++gr);
			var ver = Std.parseFloat(verStr);
			if (Math.isNaN(ver)) return rx.matched(0);
			var active = switch (op) {
				case "==": version == ver;
				case "!=": version != ver;
				case ">=": version >= ver;
				case "<=": version <= ver;
				case ">": version > ver;
				case "<": version < ver;
				default: false;
			};
			var np = (active ? "//" : "/*");
			if (np != pre) {
				changed = true;
				return np + line;
			} else return rx.matched(0);
		});
		return changed ? code : null;
	}
	override public function scan(code:String) {
		super.scan(code);
		var rxDoc = ~/^[ \t]*\/\/\/[ \t]*(.+)$/gm;
		var rxRename = ~/^@rename[ \t]+(\w+)/;
		var rxParam:EReg = new EReg("^@(?:arg|param|argument)"
			+ "[ \t]+(\\S+)" // -> name
			+ "[ \t]*(.*)" // -> value
		+ "$", "g");
		// func_name(...args)->type : doc
		var rxGMDoc:EReg = new EReg("^(\\w+)?" // -> display name
			+ "[ \t]*\\(([^\x29]*)\\)" // -> argData
			+ "(?:"
				+ "(?:(\\-\\>.*?)(?:$|:.*?))?" // typehint (`->type`, `->type : doc`)
				+ "|[ \t]*:.*?" // doc (` : doc`)
			+ ")?"
			+ "(~)?" // -> hide?
		+ "$", "g");
		var rxHide = ~/^@hide\b/g;
		var rxArgo = ~/\bargument\b/g;
		var rxArgi = [for (i in 0 ... 16) new EReg("\\bargument" + i + "\\b", "g")];
		(new EReg("^#define[ \t]+(\\w+)[ \t]*$"
			+ "((?:\n[ \t]*(?:///.+|)$)*)"
		+ "", "gm")).each(code, function(rx:EReg) {
			var name = rx.matched(1);
			var docs = rx.matched(2);
			//
			var mtpos = rx.matchedPos();
			var start = mtpos.pos + mtpos.len;
			var end = code.indexOf("\n#define", start);
			if (end < 0) end = code.length;
			//
			var fn = new GenFunc(name, mtpos.pos);
			var foundFull = false;
			var foundParam = false;
			var foundHide = false;
			var acomp = null;
			var asep = false;
			rxDoc.each(docs, function(rd:EReg) {
				var trail = rd.matched(1);
				if (rxRename.match(trail)) {
					var next = rxRename.matched(1);
					if (fn.comp != null && fn.comp.startsWith(fn.name + "(")) {
						fn.comp = next + fn.comp.substring(fn.name.length);
					}
					fn.name = next;
				}
				else if (rxHide.match(trail)) {
					foundHide = true;
				}
				else if (foundFull) {
					// no params/full docs from hereafter
				}
				else if (rxParam.match(trail)) {
					foundParam = true;
					var argName:String = rxParam.matched(1);
					if (asep) {
						acomp += ", ";
					} else {
						asep = true;
						acomp = name + "(";
						fn.argCount = 0;
					}
					if (argName.hasVarArg()) {
						fn.argTypes.resize(0);
						fn.argCount = -1;
					} else if (fn.argCount >= 0) {
						fn.argCount += 1;
						fn.argTypes.push(GenType.Value);
					}
					acomp += argName;
				}
				else if (rxGMDoc.match(trail)) {
					foundFull = true;
					var i = 0;
					var comp = rxGMDoc.matched(i);
					var dspName = rxGMDoc.matched(++i);
					var argData = rxGMDoc.matched(++i).trim();
					var doc = rxGMDoc.matched(++i);
					var hide = rxGMDoc.matched(++i);
					if (dspName == null) comp = fn.name + comp;
					fn.comp = hide == null ? comp : null;
					fn.argTypes.resize(0);
					if (argData != "") {
						if (!argData.hasVarArg()) {
							var n = argData.split(",").length;
							fn.argCount = n;
							for (i in 0 ... n) fn.argTypes.push(GenType.Value);
						} else fn.argCount = -1;
					} else fn.argCount = 0;
				}
			}); // each
			if (acomp != null && fn.comp == null) {
				fn.comp = acomp + ")";
			}
			if (foundHide) fn.comp = null;
			if (!foundFull && !foundParam) {
				var script = code.substring(start, end).stripComments();
				if (rxArgo.match(script)) {
					fn.argCount = -1;
				} else {
					var i = 16;
					while (--i >= 0) if (rxArgi[i].match(script)) break;
					fn.argCount = i + 1;
				}
			}
			functions.push(fn);
		});
		//
		(new EReg("//(#global)" // -> kind
			+ "[ \t]+(\\w+)" // -> name
			+ "(~)?" // -> hide
		+ "$", "gm")).each(code, function(rx:EReg) {
			var i = 0;
			var kind = rx.matched(++i);
			var name = rx.matched(++i);
			var hide = rx.matched(++i) != null;
			macros.push(new GenMacro(name, "global.g_" + name, hide, rx.matchedPos().pos));
		});
	}
}
