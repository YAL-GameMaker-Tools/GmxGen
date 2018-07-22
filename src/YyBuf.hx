package;
import haxe.Json;

/**
 * ...
 * @author YellowAfterlife
 */
class YyBuf extends StringBuf {
	public var depth:Int = 0;
	public var sep:Array<Bool> = [false];
	public function addLine(d:Int = 0) {
		add("\r\n");
		if (d > 0) sep.push(false);
		if (d < 0) sep.pop();
		depth += d;
		for (i in 0 ... depth) add("    ");
	}
	//
	public inline function addString(s:String) {
		add(s);
	}
	public function addSep() {
		var i = sep.length - 1;
		if (sep[i]) {
			add(",");
			addLine();
		} else sep[i] = true;
	}
	public function addField(fd:String) {
		addSep();
		addChar('"'.code);
		addString(fd);
		addString('": ');
	}
	public function addValue(val:Dynamic) {
		if (Std.is(val, Array)) {
			var arr:Array<Dynamic> = val;
			arrayOpen();
			for (v in arr) {
				addSep();
				addValue(v);
			}
			arrayClose();
		} else {
			addString(Json.stringify(val));
		}
	}
	public function addPair(fd:String, val:Dynamic) {
		addField(fd);
		addValue(val);
	}
	//
	public function arrayOpen() {
		add("[");
		addLine(1);
	}
	public function arrayClose() {
		addLine(-1);
		add("]");
	}
	//
	public function objectOpen() {
		add("{");
		addLine(1);
	}
	public function objectClose() {
		addLine(-1);
		add("}");
	}
}
