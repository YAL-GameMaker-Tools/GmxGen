package file;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
using GenTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GenFile {
	public var rel:String;
	public var path:String;
	public var functions:Array<GenFunc> = [];
	public var macros:Array<GenMacro> = [];
	public var data:Dynamic;
	public var funcKind:Int = 1;
	public var ignore:Bool = false;
	public function new() {
		
	}
	public function proc():Void {
		if (ignore) return;
		Sys.println('Checking `$rel`...');
		var code:String = File.getContent(path);
		var pcode = patch(code);
		if (pcode != null) {
			code = pcode;
			File.saveContent(path, pcode);
		}
		code = ~/\r\n/g.replace(code, "\n");
		//
		scan(code);
		//
		functions.sort(function(a, b) return a.pos - b.pos);
		macros.sort(function(a, b) return a.pos - b.pos);
	}
	public function patch(code:String):String {
		return null;
	}
	public function scan(code:String):Void {
		// don't process macros inside multi-line comments
		var ncCode = ~/\/\*.+?\*\//g.replace(code, "");
		(new EReg("//(#macro)" // -> kind
			+ "[ \t]+(\\w+)" // -> name
			+ "[ \t]+(.+?)" // -> value
			+ "(:.+?)?" // -> doc
			+ "(~)?" // -> hide
		+ "$", "gm")).each(ncCode, function(rx:EReg) {
			var i = 0;
			var kind = rx.matched(++i);
			var name = rx.matched(++i);
			var value = StringTools.trim(rx.matched(++i));
			var doc = rx.matched(++i);
			var hide = rx.matched(++i) != null;
			macros.push(new GenMacro(name, value, hide, rx.matchedPos().pos));
		});
	}
	public static function create(rel:String, path:String) {
		var out:GenFile;
		switch (Path.extension(rel).toLowerCase()) {
			case "dll", "dylib", "so": {
				path = Path.withoutExtension(path) + ".cpp";
				out = new GenCpp();
			};
			case "gml": out = new GenGml();
			case "js": out = new GenJS();
			default: return null;
		}
		if (!FileSystem.exists(path)) return null;
		out.path = path;
		out.rel = rel;
		return out;
	}
	public static function createIgnore(rel:String, path:String) {
		var out = new GenFile();
		out.ignore = true;
		out.path = path;
		out.rel = rel;
		return out;
	}
}
