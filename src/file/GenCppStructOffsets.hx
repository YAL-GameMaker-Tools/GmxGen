package file;
import ext.GenMacro;
using tools.GenTools;
using StringTools;

/**
 * Generates macros for field offsets in a struct.
 * GenCppExtFunctions does a better job at this and also handles alignment.
 * @author YellowAfterlife
 */
class GenCppStructOffsets {
	public static var sizeofs:Map<String, Int> = [
		"char" => 1, "byte" => 1, "uint8" => 1, "int8" => 1,
		"short" => 2, "int16" => 2, "uint16" => 2,
		"int" => 4, "int32" => 4, "uint32" => 4,
		"float" => 4, "double" => 8,
	];
	static var cppTypeToGmlBufferType:Map<String, String> = [
		"char" => "s8", "int8_t" => "s8",
		"unsigned char" => "u8", "uint8_t" => "u8", "byte" => "u8",
		"int" => "s32", "int32_t" => "s32",
		"unsigned int" => "u32", "uint32_t" => "u32",
		"float" => "f32", "double" => "f64",
	];
	public static function scanStructOffsets(file:GenCpp, code:String):Void {
		var rxStructField = new EReg(''
			+ '(?:unsigned[ \t]+)?' // we don't care if it's unsigned for offsets
			+ '([_a-zA-Z]\\w*.*?)' // -> type
			+ '[ \t]*('
				+ '[_a-zA-Z]\\w*'
				+ '(?:[ \t]*,[ \t]*[_a-zA-Z]\\w*)*'
			+ ')' // -> name(s)
		+ '[ \t]*;', 'g');
		var rxStructFieldName = ~/([_a-zA-Z]\w*)/g;
		
		// `///\nstruct Some { ... }`
		new EReg("///.*?(~)?" // -> hide
			+ "\nstruct\\s+(\\w+)" // -> name
			+ "\\s+\\{([^\x7d]*)\\}" // -> items (x7d=cubclose)
		+ "", "g").each(code, function(rx:EReg) {
			var i = 0;
			var hide = rx.matched(++i) != null;
			var sname = rx.matched(++i);
			var edata = rx.matched(++i).stripComments();
			var start = rx.matchedPos().pos;
			var offset = 0;
			rxStructField.each(edata, function(rc:EReg) {
				if (offset == -1) return;
				var type = rc.matched(1);
				var names = rc.matched(2);
				var size = sizeofs[type];
				if (size == null) {
					Sys.println('Size of $type is not known.');
					offset = -1;
					return;
				}
				rxStructFieldName.each(names, function(rn:EReg) {
					var name = rn.matched(1);
					file.addMacro(new GenMacro(
						sname + "_" + name, "" + offset,
						hide, start + rc.matchedPos().pos
					));
					offset += size;
				});
			});
		});
	}
}