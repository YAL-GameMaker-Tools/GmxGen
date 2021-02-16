package file;
using GenTools;

/**
 * If a .cpp file has a `/// @autostruct <file name>` comment in it,
 * we will generate 
 * @author YellowAfterlife
 */
class GenCppAutoStruct {
	public static function proc(cpp:String, gml:String):String {
		var rxStructField = new EReg(''
			+ '('  // -> type
				+ '(?:unsigned[ \t]+)?'
				+ '[_a-zA-Z]\\w*.*?'
			+ ')'
			+ '[ \t]*('
				+ '[_a-zA-Z]\\w*'
				+ '(?:[ \t]*,[ \t]*[_a-zA-Z]\\w*)*'
			+ ')' // -> name(s)
		+ '[ \t]*;', 'g');
		var rxStructFieldName = ~/([_a-zA-Z]\w*)/g;
		var newLine = gml.indexOf("\r") >= 0 ? "\r\n" : "\n";
		
		// `///\nstruct Some { ... }`
		new EReg("///.*"
			+ "\nstruct\\s+(\\w+)" // -> name
			+ "\\s+\\{([^\x7d]*)\\}" // -> items (x7d=cubclose)
		+ "", "g").each(cpp, function(rx:EReg) {
			var i = 0;
			var structName = rx.matched(++i);
			var structInner = rx.matched(++i).stripComments();
			var args = new StringBuf();
			var hints = new StringBuf();
			var macros = new StringBuf();
			var fieldIndex = 0;
			var sep = false;
			rxStructField.each(structInner, function(rc:EReg) {
				var type = rc.matched(1);
				var names = rc.matched(2);
				var tp = GenStructType.map[type];
				if (tp == null) {
					Sys.println('GML type of $type is not known.');
					return;
				}
				rxStructFieldName.each(names, function(rn:EReg) {
					if (sep) {
						args.add(", ");
					} else sep = true;
					var fieldName = rn.matched(1);
					args.add('"$fieldName", ' + tp.bufferType);
					hints.add('/// @hint {${tp.docType}} $structName:$fieldName' + newLine);
					macros.add('//#macro ${structName}_${fieldName} $fieldIndex' + newLine);
					fieldIndex += 1;
				});
			});
			
			// patch `structName = init_func(...args)` with new args:
			var foundCall = false;
			var rs = '(\\b'
				+ '(?:$structName|_$structName|__$structName)' // allow prefixed name for "private"
				+ '\\s*=\\s*\\w+\\()(.*?)(\\))';
			gml = (new EReg(rs, '')).map(gml, function(rx:EReg) {
				foundCall = true;
				return rx.matched(1) + args + rx.matched(3);
			});
			if (!foundCall) Sys.println("Couldn't find assignment line for " + structName + '`$rs`');
			
			// patch @hints:
			var firstHint = true;
			rs = '///\\s*@hint\\b\\s*'
				+ '(?:\\{.+?\\}\\s*)?'
				+ '$structName\\s*:.+(?:\r?\n|$)';
			gml = (new EReg(rs, 'g')).map(gml, function(rx:EReg) {
				if (firstHint) {
					firstHint = false;
					return hints.toString();
				} else return "";
			});
			
			// patch macros:
			var firstMacro = true;
			rs = '//#macro\\s+${structName}_\\w+\\s+.+(?:\r?\n|$)';
			gml = (new EReg(rs, 'g')).map(gml, function(rx:EReg) {
				if (firstMacro) {
					firstMacro = false;
					return macros.toString();
				} else return "";
			});
		});
		return gml;
	}
}
private class GenStructType {
	public var bufferType:String;
	public var docType:String;
	public function new(bufferType:String, docType:String) {
		this.bufferType = "buffer_" + bufferType;
		this.docType = docType;
	}
	
	public static var bool = new GenStructType("bool", "bool");
	public static var u8 = new GenStructType("u8", "int");
	public static var s8 = new GenStructType("s8", "int");
	public static var u16 = new GenStructType("u16", "int");
	public static var s16 = new GenStructType("s16", "int");
	public static var u32 = new GenStructType("u32", "int");
	public static var s32 = new GenStructType("s32", "int");
	public static var u64 = new GenStructType("s32", "int");
	public static var f32 = new GenStructType("f32", "number");
	public static var f64 = new GenStructType("f64", "number");
	public static var map:Map<String, GenStructType> = [
		"bool" => bool,
		"int8_t" => s8, "char" => s8,
		"uint8_t" => u8, "byte" => u8, "unsigned char" => u8,
		"int16_t" => s16, "short" => s16,
		"uint16_t" => u16, "unsigned short" => u16,
		"int32_t" => s32, "int" => s32,
		"uint32_t" => u32, "unsigned int" => u32,
		"float" => f32, "double" => f64,
	];
}