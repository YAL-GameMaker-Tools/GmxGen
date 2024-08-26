package file;
import file.GenCpp;
import tools.StringWithFlag;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GenGmlAutofix {
	static function pair(from:String, to:String):GenGmlAutofixPair {
		return { from: from, to: to };
	}
	static var gpu2draw:Array<GenGmlAutofixPair> = [
		pair("gpu_set_blendmode", "draw_set_blend_mode"),
		pair("gpu_set_blendmode_ext", "draw_set_blend_mode_ext"),
	];
	public static function procGMK(sf:StringWithFlag) {
		// `var a = argument0, b = argument1` -> `var a, b; a = ...; b = ...`
		var rsEqu = "\\s*\\:?=\\s*";
		var rxCommaArg = new EReg("^,\\s*"
			+ "(\\w+)" + rsEqu + "(argument" + "(?:\\d+|\\[\\d+\\])" + ")"
			+ "(.*)"
		+ "", "");
		sf.str = new EReg("var (\\w+)" + rsEqu + "argument0(,.+)", "g").map(sf.str, function(rx) {
			var args = [{
				name: rx.matched(1),
				value: "argument0",
			}];
			var rest = rx.matched(2);
			for (i in 0 ... 64) {
				if (!rxCommaArg.match(rest)) break;
				
				args.push({
					name: rxCommaArg.matched(1),
					value: rxCommaArg.matched(2),
				});
				rest = rxCommaArg.matched(3);
			}
			sf.flag = true;
			return "var " + args.map(a -> a.name).join(", ")
				+ "; " + args.map(a -> a.name + " = " + a.value).join("; ");
		});
		
		// `var a = b` -> `var a; a = b`
		sf.str = new EReg("(\\b" + "var (\\w+))(" + rsEqu + ")", "g").map(sf.str, function(rx) {
			var pos = rx.matchedPos().pos;
			if (pos > 0) {
				var c = sf.str.charCodeAt(pos - 1);
				switch (c) {
					case " ".code, "\t".code, "\n".code: {}; // OK!
					default: return rx.matched(0);
				}
			}
			sf.flag = true;
			var snip = rx.matched(1) + "; " + rx.matched(2) + rx.matched(3);
			return snip;
		});
		
		// `undefined` -> `chr(0)`
		sf.str = new EReg("\\b" + "undefined" + "\\b", "g").map(sf.str, function(rx) {
			sf.flag = true;
			return "chr(0)";
		});
	}
	public static function proc(sf:StringWithFlag) {
		if (GenGml.version < 1) procGMK(sf);
		// tabs act weird in GM:S and GM8.1 editors:
		if (GenGml.version < 2 && sf.str.contains("\t")) {
			sf.str = sf.str.replace("\t", "    ");
			sf.flag = true;
		}
		// GPU->draw
		if (GenGml.version < 2) {
			for (pair in gpu2draw) {
				var rx = new EReg("\\b" + pair.from + "\\b", "g");
				sf.str = rx.map(sf.str, function(rx) {
					sf.flag = true;
					return pair.to;
				});
			}
		}
	}
}
typedef GenGmlAutofixPair = { from:String, to:String };
