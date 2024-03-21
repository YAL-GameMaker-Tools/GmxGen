package yy;
import haxe.DynamicAccess;
import haxe.Json;

/**
 * ...
 * @author YellowAfterlife
 */
class YyBuf extends StringBuf {
	public var newLine:String = "\r\n";
	public var indent:String = "  ";
	
	/** Object/indentation depth */
	public var depth:Int = 0;
	
	/** Whether the current layer already had a comma separator */
	public var sep:Array<Bool> = [false];
	
	/** No newlines in nested objects */
	public var compactObjects = false;
	
	/** No newlines in nested arrays */
	public var compactArrays = false;
	
	/** [] and {} without an 2.2-style empty spot inside */
	public var compactEmpty = false;
	
	/** `a:1` vs `a: 1` */
	public var compactFields = false;
	
	/** [1,2,3,] instead of [1,2,3] */
	public var trailingCommas = false;
	
	/** alphabetically sorted, case-insensitive */
	public var sortedFields = false;
	
	public var metaFirst = false;
	
	/** "a\/b.yy" instead of "a/b.yy"*/
	public var escapeSlashes = false;
	
	public function new(version:Float) {
		super();
		var v23 = version >= 2.3;
		var v2023 = version >= 2023;
		var v2024 = version >= 2024;
		indent = v23 ? "  " : "    ";
		compactArrays = v2024;
		compactObjects = v23;
		compactEmpty = v23;
		compactFields = v23;
		trailingCommas = v23;
		sortedFields = v2023;
		metaFirst = v2023 && !v2024;
		escapeSlashes = !v23;
	}
	
	public function addLine(d:Int = 0) {
		add(newLine);
		if (d > 0) sep.push(false);
		if (d < 0) sep.pop();
		depth += d;
		for (i in 0 ... depth) add(indent);
	}
	public function pushLayer() {
		depth++;
		sep.push(false);
	}
	public function popLayer() {
		depth--;
		sep.pop();
	}
	//
	public inline function addString(s:String) {
		add(s);
	}
	public function addSep(compact:Bool = false) {
		var i = sep.length - 1;
		if (sep[i]) {
			add(",");
			if (!compact) addLine();
		} else sep[i] = true;
	}
	
	public function addFieldStart(fd:String) {
		if (!trailingCommas) addSep(compactObjects);
		addChar('"'.code);
		addString(fd);
		addString(compactFields ? '":' : '": ');
	}
	public function addFieldEnd() {
		if (trailingCommas) addString(",");
	}
	public function sortFields(fields:Array<String>) {
		fields.sort(stringSort);
		if (metaFirst) {
			inline function moveToFront(field:String) {
				if (fields.remove(field)) fields.unshift(field);
			}
			moveToFront("name");
			moveToFront("resourceVersion");
			moveToFront("resourceType");
		}
	}
	
	public static function stringSort(a:String, b:String) {
		a = a.toLowerCase();
		b = b.toLowerCase();
		if (a < b) return -1;
		if (a > b) return 1;
		return 0;
	}
	public function addValue(val:Dynamic) {
		if (val is Array) {
			var arr:Array<Dynamic> = val;
			if (arr.length == 0 && compactEmpty) {
				addString("[]");
			} else {
				arrayOpen();
				var sep = false;
				for (v in arr) {
					if (sep) {
						addString(",");
						if (!compactArrays) addLine();
					} else sep = true;
					addValue(v);
				}
				if (trailingCommas && sep) add(",");
				arrayClose();
			}
		}
		else if (val is String) {
			var s = Json.stringify(val);
			if (escapeSlashes) s = StringTools.replace(s, "/", "\\/"); // off-spec
			addString(s);
		}
		else if (Reflect.isObject(val)) {
			var fields = Reflect.fields(val);
			var hasOrder = fields.remove("$hxOrder");
			if (sortedFields) {
				sortFields(fields);
			} else if (hasOrder) {
				fields = Reflect.field(val, "$hxOrder");
			}
			if (fields.length == 0 && compactEmpty) {
				addString("{}");
			} else {
				objectOpen();
				var sep = false;
				for (f in fields) {
					if (f == "$hxOrder") continue;
					sep = true;
					addPair(f, Reflect.field(val, f));
				}
				objectClose();
			}
		}
		else {
			addString(Json.stringify(val));
		}
	}
	public function addPair(fd:String, val:Dynamic) {
		addFieldStart(fd);
		addValue(val);
		addFieldEnd();
	}
	//
	public function arrayOpen() {
		add("[");
		if (compactArrays) {
			pushLayer();
		} else addLine(1);
	}
	public function arrayClose() {
		if (compactArrays) {
			popLayer();
		} else addLine( -1);
		add("]");
	}
	//
	public function objectOpen() {
		add("{");
		if (compactObjects) {
			pushLayer();
		} else addLine(1);
	}
	public function objectClose() {
		if (compactObjects) {
			popLayer();
		} else addLine(-1);
		add("}");
	}
}
