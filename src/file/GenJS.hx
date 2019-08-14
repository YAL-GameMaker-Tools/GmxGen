package file;
using GenTools;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GenJS extends GenFile {
	public function new() {
		super();
		funcKind = 5;
	}
	override public function scan(code:String):Void {
		super.scan(code);
		var rxDoc:EReg = new EReg("^"
			+ "(?:\\w+)?" // name
			+ "[ \t]*(?:\\(([^\x29]*)\\))?" // -> argData
			+ "(.*?)" // -> desc
			+ "(~)?" // -> hide
		+ "", "g");
		var rxNosp = ~/^[-:]/g;
		(new EReg("(?:///[ \t]*(.*)\n)?" // -> doc
			+ "(?:window.(\\w+)[ \t]*=[ \t]*)?" // -> wname
			+ "function(?:[ \t]+(\\w+))?" // -> fname
			+ "[ \t]*\\(([^\x29]*)\\)" // -> argData
		+ "", "g")).each(code, function(rx:EReg) {
			var prec = StringTools.fastCodeAt(code, rx.matchedPos().pos - 1);
			if (prec == " ".code || prec == "\t".code) return;
			var i = 0;
			var doc = rx.matched(++i);
			var wname = rx.matched(++i);
			var name = rx.matched(++i);
			if (name == null) name = wname;
			if (name == null) return;
			var fn = new GenFunc(name, rx.matchedPos().pos);
			var argData = rx.matched(++i);
			var comp:String = null;
			var docDesc = null;
			var docHide = false;
			if (doc != null && rxDoc.match(doc)) {
				var docComp = rxDoc.matched(0);
				i = 0;
				var docArgs = rxDoc.matched(++i);
				docDesc = rxDoc.matched(++i);
				docHide = rxDoc.matched(++i) != null;
				if (docArgs != null) {
					argData = docArgs;
					if (docDesc != null) comp = name + docComp;
				}
			}
			if (comp == null && !docHide) {
				comp = name + "(" + argData + ")";
				if (docDesc != "" && docDesc != null) {
					if (!rxNosp.match(docDesc)) comp += " : ";
					comp += docDesc;
				}
			};
			fn.comp = comp;
			argData = argData.trim();
			if (argData != "") {
				if (!argData.hasVarArg()) {
					var n = argData.split(",").length;
					fn.argCount = n;
					for (i in 0 ... n) fn.argTypes.push(GenType.Value);
				} else fn.argCount = -1;
			} else fn.argCount = 0;
			functions.push(fn);
		});
	}
}
