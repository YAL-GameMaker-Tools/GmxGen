package ext.gen;
import ext.GenMacro;
import ext.IGenFileSys;
import ext.gen.*;
import haxe.Json;
import haxe.io.Path;
import file.*;
import yy.YyExtension;
import yy.YyBuf;
import yy.YyGUID;
import yy.YyJsonParser;

/**
 * ...
 * @author YellowAfterlife
 */
class GenExtYY extends GenExt {
	public var json:String;
	public var yyExt:YyExtension;
	public var v23:Bool;
	public var version:Float = 0;
	//
	public var indent:String = null;
	public var newLine:String;
	//
	public function new(fname:String, fs:IGenFileSys, json:String) {
		super(fname, fs);
		this.json = json;
		//
		newLine = json.indexOf("\r\n") >= 0 ? "\r\n" : "\n";
		var rx = ~/^\{\r?\n([ \t]+)/;
		if (rx.match(json)) {
			indent = rx.matched(1);
		}
		//
		postNew();
		if (version == 0) throw "no version!";
		GenGml.version = version;
	}
	function postNew() {
		//
	}
	public static function create(fname:String, fs:IGenFileSys):GenExtYY {
		var json:String;
		if (fs.exists(fname + ".base")) {
			json = fs.getContent(fname + ".base");
		} else json = fs.getContent(fname);
		if (~/"\$GMExtension"\s*:\s*"/.match(json)) {
			return new GenExtForGM2023x(fname, fs, json);
		}
		if (~/^{\s*\r?\n\s*"resourceType"\s*:/.match(json)) {
			var result = new GenExtForGM2023x(fname, fs, json);
			result.version = 2023.0;
			return result;
		}
		if (~/"resourceType"\s*:/.match(json)) {
			return new GenExtForGMS23x(fname, fs, json);
		}
		return new GenExtForGMS22x(fname, fs, json);
		//v23 = json.indexOf('"resourceType": "GMExtension"') >= 0;
		//GenGml.version = v23 ? 2.3 : 2.2;
	}
	override public function proc(filter:Array<String>) {
		// GMS2 uses non-spec int64s in extensions JSON
		json = ~/("copyToTargets":\s*)(\d{12,32})/g.replace(json, '$1":i64:$2"');
		//
		yyExt = YyJsonParser.parse(json);
		files.resize(0);
		for (file in yyExt.files) {
			var q:GenFile;
			var filePath = file.filename;
			if (filter == null || filter.indexOf(file.filename) >= 0) {
				q = createFile(file.filename, filePath);
			} else q = null;
			//
			if (q == null) {
				q = createIgnoreFile(file.filename, filePath);
				for (yf in file.functions) {
					var gf = new GenFunc(yf.name, 0);
					gf.argCount = yf.argCount;
					for (arg in yf.args) gf.argTypes.push(arg);
					gf.retType = yf.returnType;
					gf.comp = yf.hidden ? null : yf.help;
					q.addFunction(gf);
				}
				for (ym in file.constants) {
					var ymName = ym.name;
					if (ymName == null) ymName = ym.constantName;
					var gm = new GenMacro(ymName, ym.value, ym.hidden, 0);
					q.addMacro(gm);
				}
			}
			q.initFunction = file.init ?? "";
			q.finalFunction = Reflect.field(file, "final") ?? "";
			//
			q.data = file;
			files.push(q);
		}
	}
	function flushFileList(out:YyBuf):Void {
		throw "Not implemented!";
	}
	function createYyBuf():YyBuf {
		if (version == 0) throw "No version!";
		var out = new YyBuf(version);
		out.newLine = newLine;
		out.indent = indent;
		return out;
	}
	override public function flush():Void {
		var out = createYyBuf();
		var filesStartRx = ~/\n[ \t]*"files":[ \t]*\[/;
		if (!filesStartRx.match(json)) {
			trace(json);
			throw "Your extension doesn't seem to have a `files: []` in it.";
		}
		var filesStartPos = filesStartRx.matchedPos();
		var filesStartOfs = filesStartPos.pos + filesStartPos.len;
		out.addString(json.substring(0, filesStartOfs));
		out.depth = 2;
		out.addLine(0);
		//
		flushFileList(out);
		//
		var filesEnd = json.indexOf("\n" + indent + "],", filesStartOfs);
		if (filesEnd < 0) throw "Your extension doesn't have a well-balanced end of files array in it. It might be malformed.";
		out.addString(json.substring(filesEnd));
		json = out.toString();
		json = ~/("copyToTargets":\s*)":i64:([^"]+)"/g.replace(json, '$1$2');
		fs.setContent(fname, json);
	}
}
