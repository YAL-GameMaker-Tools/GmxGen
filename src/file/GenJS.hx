package file;
using tools.GenTools;
using StringTools;
import ext.GenFunc;
import ext.GenMacro;
import ext.GenType;
import tools.GenBuf;

/**
 * ...
 * @author YellowAfterlife
 */
class GenJS extends GenFile {
	public function new() {
		super();
		funcKind = 5;
	}
	static var rxDoc:EReg = new EReg("^[ \t]*"
		+ "(?:(\\w+)[ \t]*)?" // -> name
		+ "(?:" + "\\(" + "(.*?)" + "\\)" + ")?" // -> argData
		+ "(->\\S+)?" // -> retType
		+ "(.*?)" // -> desc
		+ "(~)?" // -> hide
	+ "", "");
	static var rxNosp = ~/^[-:]/g;
	function scan_jsf(name:String, argData:String, doc:String, pos:Int) {
		var fn = new GenFunc(name, pos);
		var docArgs:String = null, docDesc:String = null, docRet:String = null, docHide = false;
		if (doc != null && rxDoc.match(doc)) {
			var i = 0;
			var alias = rxDoc.matched(++i);
			docArgs = rxDoc.matched(++i);
			if (docArgs != null) docArgs = docArgs.trim();
			docRet = rxDoc.matched(++i);
			docDesc = rxDoc.matched(++i);
			docHide = rxDoc.matched(++i) != null;
			if (alias != null) fn.name = alias;
		}
		
		if (!docHide) {
			var cb = new GenBuf();
			cb.addFormat("%s(%s)", fn.name, docArgs != null ? docArgs : argData);
			if (docRet != null) cb.addString(docRet);
			if (docDesc != null && docDesc != "") {
				if (!rxNosp.match(docDesc)) cb.addString(" : ");
				cb.addString(docDesc);
			}
			fn.comp = cb.toString();
		}
		
		if (docArgs != null && docArgs != "") argData = docArgs;
		argData = argData.trim();
		if (argData != "") {
			if (!argData.hasVarArg()) {
				var n = argData.split(",").length;
				fn.argCount = n;
				for (i in 0 ... n) fn.argTypes.push(GenType.Value);
			} else fn.argCount = -1;
		} else fn.argCount = 0;
		addFunction(fn);
	}
	override public function scan(code:String):Void {
		super.scan(code);
		
		var ws = "[ \t]*";
		var docline = '\\/\\/\\/(.*)\\s*';
		
		// window.some = function(...) { ... }
		// function some(...) { ... } // NB! start of line only!
		(new EReg((""
			+ '(?:$docline)?' // -> ?doc
			+ '(?:window\\.(\\w+)$ws=$ws)?' // -> ?wname
			+ 'function\\b$ws'
			+ '(?:(\\w+)$ws)?' // -> ?fname
			+ '\\((.*?)\\)' // -> argData
		), "g")).each(code, function(rx:EReg) {
			var i = 0;
			var doc = rx.matched(++i);
			
			var wname = rx.matched(++i);
			var fname = rx.matched(++i);
			if (wname == null) {
				// if it's not a `window.fn = ...`, we don't want it indented
				// (as that might mean that it's inside a closure)
				var prec = StringTools.fastCodeAt(code, rx.matchedPos().pos - 1);
				if (prec == " ".code || prec == "\t".code) return;
			}
			
			// must contain a `function name` OR a `window.name = `
			var name = wname;
			if (name == null) name = fname;
			if (name == null) return;
			
			var argData = rx.matched(++i);
			scan_jsf(name, argData, doc, rx.matchedPos().pos);
		});
		
		// window.some = (...) => ... // ES6
		(new EReg((""
			+ '(?:$docline)?' // -> ?doc
			+ 'window\\.(\\w+)$ws=$ws' // -> name
			+ '\\((.*?)\\)$ws=>' // -> argData
		), "g")).each(code, function(rx:EReg) {
			var i = 0;
			var doc = rx.matched(++i);
			var name = rx.matched(++i);
			var argData = rx.matched(++i);
			scan_jsf(name, argData, doc, rx.matchedPos().pos);
		});
		
		var constValOpts = [
			'".*?"',
			"'.*?'",
			'(\\-\\s*)?' + "(?:" + [
				'0x[0-9a-fA-F]+',
				'\\d+' + '(?:\\.\\d+)?', // 4, 4.2
			].join("|") + ")",
		].join("|");
		var mcrDecl = '\\w+\\s*=\\s*(?:$constValOpts)';
		var mcrMatch = new EReg('(\\w+)\\s*=\\s*($constValOpts)', 'g');
		var mcrFull = new EReg((""
			+ docline // -> doc
			+ "(?:const|\\/\\*const\\*\\/\\s*var)\\s+"
			+ "(" // -> decls
				+ mcrDecl
				+ '(?:\\s*,\\s*$mcrDecl)*'
			+ ")"
		), "g");
		mcrFull.each(code, function(rx:EReg) {
			mcrMatch.each(rx.matched(2), function(vrx:EReg) {
				var m = new GenMacro(vrx.matched(1), vrx.matched(2), false, vrx.matchedPos().pos);
				addMacro(m);
			});
		});
	}
}
