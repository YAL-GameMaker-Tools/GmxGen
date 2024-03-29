package file;
import ext.GenFunc;
import file.GenFile;
using tools.GenTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GenDummies extends GenFile {
	public function new() {
		super();
		funcKind = 2;
	}
	override public function scan(code:String) {
		~/^((\w+).+)/gm.each(code, function(rx:EReg) {
			var help = rx.matched(1);
			var name = rx.matched(2);
			var fn = new ext.GenFunc(name, rx.matchedPos().pos);
			fn.argCount = -1;
			fn.comp = help;
			addFunction(fn);
		});
	}
}