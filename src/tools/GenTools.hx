package tools;
import sys.FileSystem;

/**
 * ...
 * @author YellowAfterlife
 */
class GenTools {
	public static function each(rx:EReg, s:String, fn:EReg->Void):Void {
		var rpos = 0;
		while (rx.matchSub(s, rpos)) {
			fn(rx);
			var npos = rx.matchedPos();
			rpos = npos.pos + npos.len;
		}
	}
	public static function hasVarArg(s:String):Bool {
		return s.indexOf("?") >= 0 || s.indexOf("...") >= 0 || s.indexOf("=") >= 0;
	}
	
	static var rxCommentLine = ~/\/\/.*/g;
	static var rxCommentBlock = ~/\/\*[\s\S]*?\*\//g;
	public static function stripComments(s:String):String {
		s = rxCommentLine.replace(s, "");
		s = rxCommentBlock.replace(s, "");
		return s;
	}
	
	public static function mtimeOf(path:String):Float {
		try {
			return FileSystem.stat(path).mtime.getTime();
		} catch (x:Dynamic) {
			return 0;
		}
	}
}
