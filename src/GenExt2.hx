package;
import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import file.*;
import YyExtension;

/**
 * ...
 * @author YellowAfterlife
 */
class GenExt2 extends GenExt {
	public var json:String;
	public var yyExt:YyExtension;
	public var v23:Bool;
	public function new(path:String) {
		super(path);
		if (FileSystem.exists(path + ".base")) {
			json = File.getContent(path + ".base");
		} else json = File.getContent(path);
		v23 = json.indexOf('"resourceType": "GMExtension"') >= 0;
		GenGml.version = v23 ? 2.3 : 2.2;
	}
	override public function proc(filter:Array<String>) {
		var dir = Path.directory(path);
		// GMS2 uses non-spec int64s in extensions JSON
		json = ~/("copyToTargets":\s*)(\d{12,32})/g.replace(json, '$1"$2"');
		//
		yyExt = YyJsonParser.parse(json);
		for (file in yyExt.files) {
			var q:GenFile;
			var filePath = Path.join([dir, file.filename]);
			if (filter == null || filter.indexOf(file.filename) >= 0) {
				q = GenFile.create(file.filename, filePath);
			} else q = null;
			//
			if (q == null) {
				q = GenFile.createIgnore(file.filename, filePath);
				for (yf in file.functions) {
					var gf = new GenFunc(yf.name, 0);
					gf.argCount = yf.argCount;
					for (arg in yf.args) gf.argTypes.push(arg);
					gf.retType = yf.returnType;
					gf.comp = yf.hidden ? null : yf.help;
					q.functions.push(gf);
				}
				for (ym in file.constants) {
					var ymName = ym.name;
					if (ymName == null) ymName = ym.constantName;
					var gm = new GenMacro(ymName, ym.value, ym.hidden, 0);
					q.macros.push(gm);
				}
			}
			//
			q.data = file;
			files.push(q);
		}
	}
	function flush22(out:YyBuf):Void {
		for (q in files) {
			out.addSep();
			out.objectOpen();
			var d:YyExtensionFile = q.data;
			//
			var fm = new Map(); for (f in d.functions) fm.set(f.name, f.id);
			var mm = new Map(); for (m in d.constants) mm.set(m.constantName, m.id);
			d.functions.resize(0);
			d.constants.resize(0);
			//
			out.addPair("id", d.id);
			out.addPair("modelName", d.modelName);
			out.addPair("mvc", d.mvc);
			out.addPair("ProxyFiles", d.ProxyFiles);
			//
			out.addField("constants");
			out.arrayOpen();
			var order = [];
			for (qm in q.macros) {
				var id = mm[qm.name];
				if (id == null) id = new YyGUID();
				order.push(id);
				out.addSep();
				out.objectOpen();
				out.addPair("id", id);
				out.addPair("modelName", "GMExtensionConstant");
				out.addPair("mvc", d.mvc);
				out.addPair("constantName", qm.name);
				out.addPair("hidden", qm.hide);
				out.addPair("value", qm.value);
				out.objectClose();
			}
			out.arrayClose();
			//
			out.addPair("copyToTargets", d.copyToTargets);
			out.addPair("filename", d.filename);
			out.addPair("final", Reflect.field(d, "final"));
			//
			out.addField("functions");
			out.arrayOpen();
			var fkin = q.funcKind;
			for (qf in q.functions) {
				var id = fm[qf.name];
				if (id == null) id = new YyGUID();
				out.addSep();
				out.objectOpen();
				out.addPair("id", id);
				out.addPair("modelName", "GMExtensionFunction");
				out.addPair("mvc", "1.0");
				out.addPair("argCount", qf.argCount);
				out.addPair("args", qf.argTypes);
				out.addPair("externalName", qf.extName);
				out.addPair("help", qf.comp != null ? qf.comp : "");
				out.addPair("hidden", qf.comp == null);
				out.addPair("kind", qf.comp == null ? 11 : fkin);
				out.addPair("name", qf.name);
				out.addPair("returnType", qf.retType);
				out.objectClose();
			}
			out.arrayClose();
			out.addPair("init", d.init);
			out.addPair("kind", d.kind);
			out.addPair("order", d.order);
			out.addPair("origname", d.origname);
			out.addPair("uncompress", d.uncompress);
			out.objectClose();
		}
	}
	function flush23(out:YyBuf):Void {
		var extName:String = yyExt.name;
		var extPath = 'extensions/$extName/$extName.yy';
		var fileSep = false;
		for (q in files) {
			if (fileSep) out.addLine(); else fileSep = true;
			out.objectOpen();
			var d:YyExtensionFile = q.data;
			out.addPair("filename", d.filename);
			out.addPair("origname", d.origname);
			out.addPair("init", d.init);
			out.addPair("final", Reflect.field(d, "final"));
			out.addPair("kind", d.kind);
			out.addPair("uncompress", d.uncompress);
			//
			out.addField("functions");
			out.arrayOpen();
			var fkin = q.funcKind;
			var funcSep = false;
			for (qf in q.functions) {
				if (funcSep) out.addLine(); else funcSep = true;
				out.objectOpen();
				out.addPair("externalName", qf.extName);
				out.addPair("kind", qf.comp == null ? 11 : fkin);
				out.addPair("help", qf.comp != null ? qf.comp : "");
				out.addPair("hidden", qf.comp == null);
				out.addPair("returnType", qf.retType);
				out.addPair("argCount", qf.argCount);
				out.addPair("args", qf.argTypes);
				out.addPair("resourceVersion", "1.0");
				out.addPair("name", qf.name);
				out.addPair("tags", []);
				out.addPair("resourceType", "GMExtensionFunction");
				out.objectClose();
				out.add(",");
			}
			out.arrayClose();
			out.addFieldEnd();
			//
			out.addField("constants");
			out.arrayOpen();
			var macroSep = false;
			for (qm in q.macros) {
				if (macroSep) out.addLine(); else macroSep = true;
				out.objectOpen();
				out.addPair("value", qm.value);
				out.addPair("hidden", qm.hide);
				out.addPair("resourceVersion", "1.0");
				out.addPair("name", qm.name);
				out.addPair("tags", []);
				out.addPair("resourceType", "GMExtensionConstant");
				out.objectClose();
				out.add(",");
			}
			out.arrayClose();
			out.addFieldEnd();
			//
			out.addPair("ProxyFiles", d.ProxyFiles);
			out.addPair("copyToTargets", d.copyToTargets);
			//
			out.addField("order");
			out.arrayOpen();
			var orderSep = false;
			for (qf in q.functions) {
				if (orderSep) out.addLine(); else orderSep = true;
				out.objectOpen();
				out.addPair("name", qf.name);
				out.addPair("path", extPath);
				out.objectClose();
				out.add(",");
			}
			out.arrayClose();
			out.addFieldEnd();
			//
			out.addPair("resourceVersion", "1.0");
			out.addPair("name", "");
			out.addPair("tags", []);
			out.addPair("resourceType", "GMExtensionFile");
			//
			out.objectClose();
			out.addFieldEnd();
		}
	}
	override public function flush():Void {
		var out = new YyBuf(v23);
		var filesStartStr = '"files": [';
		var filesStart = json.indexOf(filesStartStr);
		if (filesStart < 0) throw "Your extension doesn't have an array of files in it.";
		//
		if (json.indexOf("\r\n") < 0) out.newLine = "\n";
		out.addString(json.substring(0, filesStart + filesStartStr.length));
		out.depth = 2;
		out.addLine(0);
		//
		if (v23) {
			flush23(out);
		} else flush22(out);
		//
		var filesEnd = json.indexOf(v23 ? '\n  ],' : '\n    ],', filesStart);
		if (filesEnd < 0) throw "Your extension doesn't have a well-balanced end of files array in it. It might be malformed.";
		out.addString(json.substring(filesEnd));
		json = out.toString();
		json = ~/("copyToTargets":\s*)"([^"]+)"/g.replace(json, '$1$2');
		File.saveContent(path, json);
	}
}
