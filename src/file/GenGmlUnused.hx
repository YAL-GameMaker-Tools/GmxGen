package file;
import tools.CharCode;
import tools.GenReader;
import tools.GenBuf;
import tools.StringWithFlag;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GenGmlUnused {
	public static var usedMap:Map<String, Bool> = new Map();
	public static function patch(snip:StringWithFlag){
		if (GenGml.version >= 1) return;
		var code = snip.str;
		var changed = false;
		var q = new GenReader(code, "");
		//
		var scriptStart = 0;
		var scriptName = "";
		var badList = [];
		var badMap = new Map();
		var start = 0;
		var out = new GenBuf();
		var ok = true;
		function proc(till:Int) {
			if (!ok) {
				while (till > 0 && (code.unsafeCodeAt(till - 1):CharCode).isSpace()) till--;
				out.addString(code.substring(start, scriptStart));
				out.addFormat('show_error("%s is unavailable'
					+ ' because the following aren\'t present in this GameMaker version:',
					scriptName
				);
				for (name in badList) {
					out.addFormat("%|%s", name);
				}
				out.addFormat('%|", true);%|');
				out.addString("/*");
				var snip = code.substring(scriptStart, till);
				snip = snip.replace("*/", "*\\/");
				out.addString(snip);
				out.addString("*/");
				badList = [];
				badMap = new Map();
				start = till;
				changed = true;
			}
		}
		//
		while (q.loop) {
			var p = q.pos;
			var c = q.read();
			var c1 = q.loop ? q.peek() : 0;
			switch (c) {
				case "#".code if (c1.isIdent0()):
					var kw = q.readIdent();
					if (kw != "define") continue;
					
					q.skipLineSpaces();
					var name = q.readIdent();
					q.skipSpaces();
					if (q.peekn(2) == "//") {
						q.skipUntil("\n".code);
						q.skipSpaces();
					}
					proc(p);
					scriptStart = q.pos;
					scriptName = name;
					ok = true;
				case "/".code if (c1 == "/".code):
					q.skipUntil("\n".code);
				case "/".code if (c1 == "*".code):
					q.skipUntilStr("*/");
				case '"'.code:
					q.skipUntil('"'.code);
				case "'".code:
					q.skipUntil("'".code);
				case _ if (c.isIdent0()):
					var word = q.readIdent(true);
					if (word.startsWith("buffer_")) {
						// todo: an actual lookup (fnames diff?)
						if (!badMap.exists(word)) {
							badMap[word] = true;
							badList.push(word);
						}
						ok = false;
					} else {
						q.skipLineSpaces();
						if (q.peek() == "(".code) {
							if (!usedMap.exists(word)) usedMap[word] = true;
						}
					}
			}
		}
		proc(q.len);
		if (!changed) return;
		snip.flag = true;
		out.addString(code.substring(start));
		snip.str = out.toString();
	}
}