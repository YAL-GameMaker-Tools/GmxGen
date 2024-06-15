package file;
import ext.GenFunc;
import ext.GenMacro;
import ext.GenType;
import file.GenFile;
import file.GenGmlAutofix;
import file.GenGmlUnused;
import tools.CharCode;
import tools.GenReader;
import tools.StringWithFlag;
using tools.GenTools;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GenGml extends GenFile {
	/** Generally 1.4, 2.2, or 2.3 */
	public static var version:Float = 2.3;
	public function new() {
		super();
		funcKind = 2;
	}
	// This changes bits like
	//  // GMS >= 2.3:
	//  code for newer versions
	//  /*/
	//  code for older versions
	//  //*/
	// to match the current target
	override public function patch(_code:String):String {
		var sf = new StringWithFlag(_code);
		var rsOp = "\\s*(==|!=|\\>=|\\>|\\<=|\\<)";
		var rsVer = "\\s*(\\d+(?:\\.[\\d*])?)";
		var stripCC = GenOpt.stripCC;
		var regex = (""
			+ "/([/*])(" // -> prefix, line without prefix
			+ "(?:\\s*\\()?" // opt. (
			+ "\\s*GMS"
			+ rsOp // -> operator
			+ rsVer // -> version
			+ "(?:"
				+ "\\s*(\\&\\&|\\|\\|)" // -> and/or
				+ "\\s*GMS"
				+ rsOp // -> operator2
				+ rsVer // -> version2
			+ ")?"
			+ "(?:\\s*\\))?" // opt. )
			+ ":)" // trailing `:` (required!)
		);
		if (stripCC) {
			regex += ("\\s*"
				+ "([\\s\\S]*?)"
				+ "\\*/(\\s*)"
			);
		}
		sf.str = (new EReg(regex, "g")).map(sf.str, function(rx:EReg) {
			var gr = 0;
			var pre = rx.matched(++gr);
			var line = rx.matched(++gr);
			//
			var op1 = rx.matched(++gr);
			var verStr1 = rx.matched(++gr);
			var ver1 = Std.parseFloat(verStr1);
			//
			var boolOp = rx.matched(++gr);
			var op2 = rx.matched(++gr);
			var verStr2 = rx.matched(++gr);
			//
			var inner = stripCC ? rx.matched(++gr) : null;
			var post = stripCC ? rx.matched(++gr) : null;
			//
			if (Math.isNaN(ver1)) return rx.matched(0);
			function check(v:Float, op:String) {
				return switch (op) {
					case "==": version == v;
					case "!=": version != v;
					case ">=": version >= v;
					case "<=": version <= v;
					case ">": version > v;
					case "<": version < v;
					default: false;
				};
			}
			
			var active;
			if (boolOp != null) {
				var ver2 = verStr2 != null ? Std.parseFloat(verStr2) : null;
				if (Math.isNaN(ver2)) return rx.matched(0);
				var a1 = check(ver1, op1);
				var a2 = check(ver2, op2);
				active = switch (boolOp) {
					case "&&": a1 && a2;
					case "||": a1 || a2;
					default: false;
				}
			} else {
				active = check(ver1, op1);
			}
			
			if (stripCC) {
				sf.flag = true;
				if (!active) return "";
				inner = inner.rtrim();
				if (inner.endsWith("//")) {
					inner = inner.substring(0, inner.length - 2).rtrim();
				} else if (inner.endsWith("/")) {
					inner = inner.substring(0, inner.length - 1).rtrim() + "/*//";
				}
				return inner + post;
			}
			
			var np = (active ? "//" : "/*");
			if (np != pre) {
				sf.flag = true;
				return np + line;
			} else return rx.matched(0);
		});
		
		if (stripCC && sf.flag) {
			var blockStart = "/*//";
			var blockStartL = blockStart.length;
			for (_ in 0 ... 1024) {
				var pos = sf.str.indexOf(blockStart);
				if (pos < 0) break;
				var end = sf.str.indexOf("*/", pos + blockStartL);
				if (end < 0) break;
				sf.str = sf.str.substring(0, pos).rtrim()
					+ sf.str.substring(end + 2);
			}
			
			var blockEnd = "//*/";
			var blockEndL = blockEnd.length;
			for (_ in 0 ... 1024) {
				var pos = sf.str.indexOf(blockEnd);
				if (pos < 0) break;
				sf.str = sf.str.substring(0, pos).rtrim()
					+ sf.str.substring(pos + blockEndL);
			}
		}
		
		GenGmlUnused.patch(sf);
		GenGmlAutofix.proc(sf);
		
		return sf.flag ? sf.str : null;
	}
	override public function scan(code:String) {
		super.scan(code);
		var rxDoc = ~/^[ \t]*\/\/\/[ \t]*(.+)$/gm; // `/// <text>`
		var rxRename = ~/^@rename[ \t]+(\w+)/;
		var rxParam:EReg = new EReg("^@(?:arg|param|argument)"
			+ "[ \t]+(\\S+)" // -> name
			+ "[ \t]*(.*)" // -> value
		+ "$", "g");
		// func_name(...args)->type : doc
		var rsRet = "->(?:\\S*)?";
		var rxIsGMDoc = ~/^(?:(\w+)\s*)?\((.*)/g;
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
				else if (rxIsGMDoc.match(trail)) {
					foundFull = true;
					var dspName = rxIsGMDoc.matched(1);
					if (dspName == null) dspName = fn.name;
					var q = new GenReader(rxIsGMDoc.matched(2), "gmdoc");
					// argData:
					var argCount = 1;
					var varArg = false;
					q.skipSpaces();
					if (q.skipIfEqu(")".code)) {
						argCount = 0;
					} else {
						var wantArg = true;
						var depth = 1;
						var argsStart = q.pos;
						while (q.loop) {
							if (wantArg) {
								wantArg = false;
								q.skipSpaces();
								if (q.skipIfEqu("?".code) || q.skipIfEqu("[".code)) {
									varArg = true;
								} else if (q.peekn(3) == "...") {
									q.skip(3);
									varArg = true;
								}
							}
							switch (q.read()) {
								case "(".code: depth++;
								case ")".code: if (--depth <= 0) break;
								case ",".code if (depth == 1):
									argCount += 1;
									wantArg = true;
							}
						}
						if (depth > 0) return;
						if (q.substring(argsStart, q.pos - 1).indexOf("=") >= 0) varArg = true;
					}
					fn.argTypes.resize(0);
					if (varArg) {
						fn.argCount = -1;
					} else {
						fn.argCount = argCount;
						for (_ in 0 ... argCount) fn.argTypes.push(GenType.Value);
					}
					fn.argCount = varArg ? -1 : argCount;
					var argData = q.substring(0, q.pos - 1);
					
					//
					q.skipSpaces();
					if (q.peekn(2) == "->") do { // once
						q.skip(2);
						q.skipSpaces();
						var c:CharCode = q.peek();
						if (c.isIdent0()) {
							while (q.loop && q.peek().isIdent1()) q.skip();
							q.skipSpaces();
							c = q.peek();
						}
						inline function isOpen(c:CharCode) {
							return switch (c) {
								case "[".code, "{".code, "(".code, "<".code: true;
								default: false;
							}
						}
						var depth = 0;
						if (isOpen(c)) { q.skip(); depth = 1; }
						while (q.loop && depth > 0) {
							c = q.read();
							if (isOpen(c)) {
								depth++;
							} else switch (c) {
								case "]".code, "}".code, ")".code, ">".code:
									depth--;
									q.skipSpaces();
									if (isOpen(q.peek())) {
										depth++;
										q.skip();
									}
							}
						}
					} while (false); // ->
					
					//
					var rest = q.substring(q.pos, q.len).rtrim();
					if (rest.endsWith("~")) {
						foundHide = true;
					} else fn.comp = dspName + "(" + q.str;
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
			addFunction(fn);
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
			addMacro(new GenMacro(name, "global.g_" + name, hide, rx.matchedPos().pos));
		});
	}
}
