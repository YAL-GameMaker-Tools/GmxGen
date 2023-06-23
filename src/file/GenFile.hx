package file;
import ext.GenFunc;
import ext.GenExt;
import ext.GenMacro;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
using tools.GenTools;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GenFile {
	public var rel:String;
	public var ext:GenExt;
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
		// #init, #final
		(new EReg("//#(init|final)\\b" // -> kind
			+ "[ \t]*(?:(\\w+)|$)" // -> name
		+ "", "gm")).each(ncCode, function(rx:EReg) {
			var i = 0;
			var kind = rx.matched(++i);
			var name = rx.matched(++i);
			if (name == null) name = "";
			switch (kind) {
				case "init": initFunction = name;
				case "final": finalFunction = name;
			}
		});
	}
}
