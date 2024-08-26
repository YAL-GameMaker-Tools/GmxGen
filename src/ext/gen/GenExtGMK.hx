package ext.gen;

import file.GenGmlUnused;
import ext.GenExt;
import ext.GenLog;
import ext.IGenFileSys;
import file.GenGml;
import haxe.io.Path;
import sys.io.File;
import tools.GenBuf;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GenExtGMK extends GenExt {
	public function new(fname:String, fs:IGenFileSys) {
		super(fname, fs);
		GenGml.version = 0.81;
	}
	public var funcFilePath:String = null;
	public var constFilePath:String = null;
	override public function proc(filter:Array<String>):Void {
		super.proc(filter);
		
		var list = fs.getContent(fname).replace("\r", "").split("\n");
		for (fname in list) {
			fname = fname.trim();
			if (fname.startsWith(">")) {
				fname = fname.substr(1);
				switch (Path.extension(fname).toLowerCase()) {
					case "gml": funcFilePath = fname;
					case "txt": constFilePath = fname;
					default: Sys.println('Not sure what to output into "$fname" '
						+ '(supported file types are TXT for constants, GML for code)'
					);
				}
				continue;
			}
			//
			var file = createFile(fname, fname);
			if (file == null) continue;
			files.push(file);
		}
	}
	override public function flush():Void {
		var init = new GenBuf();
		var impl = new GenBuf();
		var const = new GenBuf();
		var globalvars = [];
		if (funcFilePath != null) {
			var initName = GenOpt.gmkLoader;
			if (initName == null) {
				initName = Path.withoutExtension(funcFilePath);
				initName = ~/\W+/g.replace(initName, "");
			}
			init.addFormat("#define %s%|", initName);
			init.addFormat('/// %s(?path_prefix)%|', initName);
		}
		// collect macros:
		for (file in files) {
			for (mcr in file.macroList) {
				if (mcr.value == "global.g_" + mcr.name) {
					globalvars.push(mcr.name);
				} else const.addFormat("%s=%s%|", mcr.name, mcr.value);
			}
		}
		// collect functions:
		var hasHeader = false;
		function ensureHeader() {
			if (hasHeader) return;
			hasHeader = true;
			init.addFormat("var _path, _dir;%|");
			init.addFormat("if (argument_count > 0) {%+");
				init.addFormat('_dir = argument[0];%-');
			init.addFormat('} else _dir = "";%|');
			if (globalvars.length > 0) {
				init.addFormat("globalvar %s;%|", globalvars.join(", "));
			}
		}
		for (file in files) {
			if (Path.extension(file.fname).toLowerCase() != "dll") continue;
			var hasPath = false;
			var gmkiList = file.gmkiFunctionList;
			for (list in [file.functionList, gmkiList])
			for (func in list) {
				if (!hasPath) {
					hasPath = true;
					ensureHeader();
					init.addFormat('%|_path = _dir + "%s";%|', file.fname);
				}
				//init.addFormat('trace("Loading %s:%s");%|', file.fname, func.extName);
				init.addFormat("global.f_%s = external_define(_path, ", func.name);
				init.addFormat('"%s", ', func.extName); // external name
				init.addFormat('dll_cdecl, '); // call convention
				init.addFormat('%s, ', func.retType.toTy()); // return type
				init.addFormat('%d', func.argCount);
				for (arg in func.argTypes) {
					init.addFormat(', %s', arg.toTy());
				}
				init.addFormat(");%|");
				//
				if (list == gmkiList) continue;
				// could maybe hide auto-generated functions later
				if (func.comp == null
					&& func.name.endsWith("_raw")
					&& !GenGmlUnused.usedMap.exists(func.name)
				) continue;
				//
				impl.addFormat("%|#define %s%|", func.name);
				if (func.comp != null) impl.addFormat('/// %s%|', func.comp);
				impl.addFormat("return external_call(global.f_%s", func.name);
				for (i in 0 ... func.argCount) {
					impl.addFormat(', argument%d', i);
				}
				impl.addFormat(");%|");
			}
		} // for file in files
		// add inits:
		for (file in files) {
			if (file.initFunction != null && file.initFunction != "") {
				ensureHeader();
				init.addFormat("%s();%|", file.initFunction);
			}
		}
		// add other GML files:
		for (file in files) {
			if (Path.extension(file.fname).toLowerCase() != "gml") continue;
			ensureHeader();
			init.addFormat("%|%s", fs.getContent(file.relPath));
		}
		
		init.addBuffer(impl);
		if (funcFilePath != null) {
			var gml = init.toString();
			gml = gml.replace("\r", "").replace("\n", "\r\n");
			fs.setContent(funcFilePath, gml);
		} else if (init.length > 0) {
			GenLog.warn('GmxGen: warning #: Extension contains external functions, but no >.gml file has been specified.');
		}
		if (constFilePath != null) {
			fs.setContent(constFilePath, const.toString());
		} else if (const.length > 0) {
			GenLog.warn('Extension contains macros, but no >.txt file has been specified.');
		}
	}
}