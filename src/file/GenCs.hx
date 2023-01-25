package file;
import haxe.io.Path;
import sys.io.File;
using GenTools;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GenCs extends GenFile {
	override public function scan(code:String):Void {
		super.scan(code);
		var sp = "[ \t]";
		
		var rxArg = ~/^\s*(double)?.+?(\w+)\s*$/g; // 1: is non-pointer, 2: name
		new EReg("(" // -> hasDoc
				+ '///$sp*'
				+ "(?:(\\-\\>.+?)(?:$|:))?" // -> type
				+ "(.*)" // -> doc
			+ "\n\\s+)?"
			+ "\\[DllExport(?:\\("
				+ '$sp*"(\\w+)"' + '.*?' // -> name override
			+ "\\))?\\]\\s*"
			+ "(?:(?:public|private|protected|internal|static)\\s+)*"
			+ '(void|double|string)\\s+' // -> return type
			+ '(\\w+)\\s*' // -> name
			+ '\\(' + '(.*?)' + '\\)' // -> arguments
		+ '', "gm").each(code, function(rx:EReg) {
			var rxi = 0;
			var hasDoc = rx.matched(++rxi) != null;
			var docType = rx.matched(++rxi);
			var docText = rx.matched(++rxi);
			var nameOverride = rx.matched(++rxi);
			var retType = rx.matched(++rxi);
			var name = rx.matched(++rxi);
			var argData = rx.matched(++rxi).trim();
			//
			if (nameOverride != null) name = nameOverride;
			//
			var fn = new GenFunc(name, rx.matchedPos().pos);
			fn.retType = retType != "string" ? GenType.Value : GenType.Pointer;
			var comp = hasDoc ? '$name(' : null;
			if (argData != "") {
				var argParts = argData.split(",");
				for (i => argPart in argParts) {
					if (rxArg.match(argPart)) {
						if (hasDoc) {
							if (i > 0) comp += ", ";
							comp += rxArg.matched(2);
						}
						fn.argTypes.push(rxArg.matched(1) != null
							? GenType.Value : GenType.Pointer);
					} else throw 'Can\'t match argument `$argPart` in function $name';
				}
				fn.argCount = argParts.length;
			} else fn.argCount = 0;
			
			if (hasDoc) {
				comp += ")";
				if (docType != null) comp += docType;
				if (docText != null) {
					docText = docText.trim();
					if (docText != "") comp += " : " + docText;
				}
				fn.comp = comp;
			}
			addFunction(fn);
		});
	}
}