package file;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
using GenTools;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GenFile {
	public var rel:String;
	public var path:String;
	public var origPath:String;
	
	public var functionList:Array<GenFunc> = [];
	public var functionMap:Map<String, GenFunc> = new Map();
	public var initFunction:String = null;
	public var finalFunction:String = null;
	public function addFunction(f:GenFunc) {
		var of = functionMap[f.name];
		if (of != null) {
			if (of.comp == null && f.comp != null) {
				functionList.remove(of);
			} else return;
		}
		functionList.push(f);
		functionMap[f.name] = f;
	}
	
	public var macroList:Array<GenMacro> = [];
	public var macroMap:Map<String, GenMacro> = new Map();
	public function addMacro(m:GenMacro) {
		var om = macroMap[m.name];
		if (om != null) {
			if (om.hide && !m.hide) {
				macroList.remove(om);
			} else return;
		}
		macroList.push(m);
		macroMap[m.name] = m;
	}
	
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
		functionList.sort(function(a, b) return a.pos - b.pos);
		macroList.sort(function(a, b) return a.pos - b.pos);
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
			addMacro(new GenMacro(name, value, hide, rx.matchedPos().pos));
		});
		//
		(new EReg("//#(init|final)" // -> kind
			+ "[ \t]+(\\w+)" // -> name
		+ "", "gm")).each(ncCode, function(rx:EReg) {
			var i = 0;
			var kind = rx.matched(++i);
			var name = rx.matched(++i);
			switch (kind) {
				case "init": initFunction = name;
				case "final": finalFunction = name;
			}
		});
	}
	public static function create(rel:String, path:String) {
		var out:GenFile;
		var origPath = path;
		switch (Path.extension(rel).toLowerCase()) {
			case "dll", "dylib", "so": {
				var tp:String;
				if (FileSystem.exists(tp = Path.withExtension(path, "cpp"))) {
					path = tp;
					out = new GenCpp();
				} else if (FileSystem.exists(tp = Path.withExtension(path, "h"))) {
					path = tp;
					out = new GenCpp();
				} else if (FileSystem.exists(tp = Path.withExtension(path, "c"))) {
					path = tp;
					out = new GenCpp();
				} else if (FileSystem.exists(tp = Path.withExtension(path, "cs"))) {
					path = tp;
					out = new GenCs();
				} else return null;
			};
			case "gml": {
				var tp:String;
				if (FileSystem.exists(tp = path + ".dummy")) {
					path = tp;
					out = new GenDummies();
				} else out = new GenGml();
			};
			case "js": {
				if (Path.withoutExtension(rel).endsWith("_wasm")) { // name_wasm.js -> name.cpp
					var pt = new Path(path);
					pt.ext = "cpp";
					pt.file = pt.file.substr(0, pt.file.length - 5);
					path = pt.toString();
					trace(path);
					out = new GenWasm();
				} else out = new GenJS();
			};
			default: return null;
		}
		if (path == null || !FileSystem.exists(path)) return null;
		out.origPath = origPath;
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
