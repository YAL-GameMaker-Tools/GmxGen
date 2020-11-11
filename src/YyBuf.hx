package;
import haxe.DynamicAccess;
import haxe.Json;

/**
 * ...
 * @author YellowAfterlife
 */
class YyBuf extends StringBuf {
	public var newLine:String = "\r\n";
	public var depth:Int = 0;
	public var sep:Array<Bool> = [false];
	public var v23:Bool;
	public function new(v23:Bool) {
		super();
		this.v23 = v23;
	}
	public function addLine(d:Int = 0) {
		add(newLine);
		if (d > 0) sep.push(false);
		if (d < 0) sep.pop();
		depth += d;
		if (v23) {
			for (i in 0 ... depth) add("  ");
		} else {
			for (i in 0 ... depth) add("    ");
		}
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
		if (!v23) addSep();
		addChar('"'.code);
		addString(fd);
		addString(v23 ? '":' : '": ');
	}
	public function addFieldEnd() {
		if (v23) addString(",");
	}
	public function addValue(val:Dynamic) {
		if (Std.is(val, Array)) {
			var arr:Array<Dynamic> = val;
			if (v23 && arr.length == 0) {
				addString("[]");
			} else {
				arrayOpen();
				for (v in arr) {
					addSep();
					addValue(v);
				}
				if (v23) add(",");
				arrayClose();
			}
		}
		else if (Std.is(val, String)) {
			var s = Json.stringify(val);
			if (!v23) s = StringTools.replace(s, "/", "\\/"); // off-spec
			addString(s);
		}
		else if (Reflect.isObject(val)) {
			var fields = Reflect.fields(val);
			if (fields.length != 0) {
				objectOpen();
				for (f in fields) {
					addPair(f, Reflect.field(val, f));
				}
				objectClose();
			} else addString("{}");
		}
		else {
			addString(Json.stringify(val));
		}
	}
	public function addPair(fd:String, val:Dynamic) {
		addField(fd);
		addValue(val);
		addFieldEnd();
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
		if (v23) {
			depth++;
		} else addLine(1);
	}
	public function objectClose() {
		if (v23) {
			depth--;
		} else addLine(-1);
		add("}");
	}
}
