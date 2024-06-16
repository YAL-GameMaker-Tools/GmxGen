package file;
import ext.GenFunc;
import ext.GenExt;
import ext.GenMacro;
import haxe.io.Path;
using tools.GenTools;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GenFile {
	/** "some.gml" */
	public var fname:String;
	/** relative to extension folder, so "extname/some.gml" in GMS1 */
	public var relPath:String;
	public var ext:GenExt;
	
	public var functionList:Array<GenFunc> = [];
	public var functionMap:Map<String, GenFunc> = new Map();
	
	/** Only used for 8.x interop via external_call, not added to definitions **/
	public var gmkiFunctionList:Array<GenFunc> = [];
	public var gmkiFunctionMap:Map<String, GenFunc> = new Map();
	
	public var initFunction:String = null;
	public var finalFunction:String = null;
	public function addFunction(f:GenFunc) {
		var list = functionList;
		var map = functionMap;
		static var rxGMKB = ~/#gmki\b/;
		if (f.comp != null && rxGMKB.match(f.comp)) {
			list = gmkiFunctionList;
			map = gmkiFunctionMap;
		}
		var of = map[f.name];
		if (of != null) {
			if (of.comp == null && f.comp != null) {
				list.remove(of);
			} else return;
		}
		list.push(f);
		map[f.name] = f;
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
	@:keep public function toString() {
		return Type.getClassName(Type.getClass(this)) + '(rel:"$relPath")';
	}
	
	public function proc():Void {
		if (ignore) return;
		var code:String = ext.fs.getContent(relPath);
		var pcode = patch(code);
		if (pcode != null) {
			code = pcode;
			ext.fs.setContent(relPath, pcode);
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
		var ncCode = ~/\/\*[\s\S]+?\*\//g.replace(code, "");
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
