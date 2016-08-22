package;

import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;

/**
 * ...
 * @author YellowAfterlife
 */
class GmxGen {
	
	static function error(s:String) {
		Sys.println(s);
		Sys.exit(0);
	}
	
	/** <par><node x></par>, "node" -> <node x> */
	static function xmlFind(xml:Xml, name:String):Xml {
		var iter = xml.elementsNamed(name);
		if (iter.hasNext()) {
			return iter.next();
		} else {
			error('Could not find <$name> in the GMX.');
			return null;
		}
	}
	
	/** <node>text</node> -> "text" */
	static function xmlRead(xml:Xml):String {
		return xml.firstChild().toString();
	}
	
	static inline var lbz:String = "\r\n      ";
	static inline var lb0:String = "\r\n        ";
	static inline var lb1:String = "\r\n          ";
	static inline var lb2:String = "\r\n            ";
	
	/** Adds text to a node. */
	static inline function addText(xml:Xml, text:String):Void {
		xml.addChild(Xml.createPCData(text));
	}
	
	/** Adds a `<name/>` to Xml.*/
	static function addNode(xml:Xml, name:String):Xml {
		// add a linebreak+indent:
		xml.addChild(Xml.createPCData(lb0));
		// create and add the actual node:
		var addParNode = Xml.createElement(name);
		xml.addChild(addParNode);
		return addParNode;
	}
	
	/** Adds a `<name>text</name>` to Xml. */
	static function addParam(xml:Xml, name:String, ?text:String):Xml {
		// add a linebreak+indent:
		xml.addChild(Xml.createPCData(lb1));
		// create and add the actual node:
		var addParNode = Xml.createElement(name);
		if (text != null) addParNode.addChild(Xml.createPCData(text));
		xml.addChild(addParNode);
		return addParNode;
	}
	
	static function addMacro(extMacro:Xml, name:String, value:String, doc:String) {
		var mcrNode = addNode(extMacro, "constant");
		addParam(mcrNode, "name", name);
		addParam(mcrNode, "value", value);
		addParam(mcrNode, "hidden", doc == null ? "-1" : "0");
		addText(mcrNode, lb0);
		// additional documentation node:
		if (doc != null && doc != "") {
			mcrNode = addNode(extMacro, "constant");
			addParam(mcrNode, "name", name + ' /* $doc */');
			addParam(mcrNode, "value", value);
			addParam(mcrNode, "hidden", "0");
			addText(mcrNode, lb0);
		}
	}
	
	static function addFunc(extFuncs:Xml, func:GmxFunc) {
		var argc:Int = func.argc;
		var funNode = addNode(extFuncs, "function");
		addParam(funNode, "name", func.name);
		addParam(funNode, "externalName", func.name);
		addParam(funNode, "kind", "11"); // doesn't matter for GML scripts
		var doc:String;
		if (func.fulldoc != null) {
			doc = func.fulldoc;
		} else if (func.doc != null) {
			doc = func.name + "(";
			var trail = false;
			for (arg in func.args) {
				if (trail) doc += ", "; else trail = true;
				doc += arg.name;
			}
			doc += ")";
			if (func.doc != "") {
				doc += " : " + func.doc;
			}
		} else doc = "";
		addParam(funNode, "help", doc);
		addParam(funNode, "returnType", Std.string(func.ret));
		addParam(funNode, "argCount", Std.string(argc));
		var funArgs = addParam(funNode, "args");
		if (argc > 0) {
			for (arg in func.args) {
				addText(funArgs, lb2);
				var funArg = Xml.createElement("arg");
				addText(funArg, Std.string(arg.type));
				funArgs.addChild(funArg);
			}
			addText(funArgs, lb1);
		}
		addText(funNode, lb0);
	}
	
	static var appliedTo:Map<String, Bool>;
	static function apply(basePath:String, fileNode:Xml, ?fileName:String) {
		if (fileName == null) fileName = xmlRead(xmlFind(fileNode, "filename"));
		var filePath:String = basePath + "/" + fileName;
		var fileExt = Path.extension(fileName).toLowerCase();
		// for binary files, expect a .cpp near the file.
		switch (fileExt) {
			case "gml", "js": { };
			case "dll", "dylib", "so": {
				filePath = Path.withoutExtension(filePath) + ".cpp";
			};
			default: return;
		}
		// retrieve the contents of the file:
		if (!FileSystem.exists(filePath)) {
			Sys.println("Could not find " + filePath);
			return;
		}
		var code:String, codePos:Int;
		try {
			code = File.getContent(filePath);
			code = StringTools.replace(code, "\r\n", "\n");
		} catch (error:Dynamic) {
			Sys.println("Could not read " + filePath + ":");
			Sys.println(Std.string(error));
			return;
		}
		//
		Sys.println("Indexing " + filePath + "...");
		var dup:Bool = false;
		if (appliedTo[filePath]) {
			dup = true;
		} else appliedTo[filePath] = true;
		//
		var nextPos_ofs;
		inline function nextPos(rx:EReg):Int {
			nextPos_ofs = rx.matchedPos();
			return nextPos_ofs.pos + nextPos_ofs.len;
		}
		//
		var extFuncs:Xml = Xml.createElement("functions");
		var extMacro:Xml = Xml.createElement("constants");
		var fileExtLq = fileExt.toLowerCase();
		switch (fileExtLq) {
			case "gml", "js": {
				// `/// func(a, b) : doc`:
				var rxArg = ~/([\w_]+)/g;
				for (iter in (fileExtLq == "js" ? 0 : -1) ... (fileExtLq == "js" ? 3 : 1)) {
					var rxData:{ rx:EReg, name:Int, args:Int, doc:Int } = switch (iter) {
						case -1: { // `#define name\n/// `(...)`? ` : doc`?`
							rx: ~/#define\s+([\w_]+)\n\/\/\/\s*(\(([^\)]*)\))?(\s*:\s*([^\n]*))?[^\n]*/,
							name: 1, args: 3, doc: 5,
						};
						case 1: { // `/// `(...)`? ` : doc`?\nfunction name`
							rx: ~/\/\/\/\s*\(([^\)]*)\)(\s*:\s*([^\n]*))?([^\n:]*)?\n[ \t]*function\s+([\w_]+)/g,
							name: 5, args: 1, doc: 3,
						};
						case 2: { // `/// ` : doc`?\nfunction name(...)`
							rx: ~/\/\/\/\s*(\s*:\s*([^\n]*))?([^\n:]*)?\n[ \t]*function\s+([\w_]+)\(([^\)]*)\)/g,
							name: 4, args: 5, doc: 2,
						};
						default: { // `/// name(...) ` : doc`?`
							rx: ~/\/\/\/\s*([\w_]+)\(([^\)]*)\)(\s*:\s*([^\n]*))?([^\n:]*)?/g,
							name: 1, args: 2, doc: 4,
						};
					};
					//
					var rxFunc = rxData.rx;
					var riName = rxData.name;
					var riArgs = rxData.args;
					var riDoc = rxData.doc;
					//
					codePos = 0;
					while (rxFunc.matchSub(code, codePos)) {
						var argv:String = rxFunc.matched(riArgs);
						if (argv == null) argv = "";
						var argm:Array<String> = argv != "" ? argv.split(",") : [];
						var args = [];
						for (arg in argm) {
							var argName = rxArg.match(arg)
								? rxArg.matched(1)
								: "arg" + (args.length + 1);
							args.push({ name: argName, type: 2 });
						}
						var argc = argm.length;
						// signs of variable argument count:
						if (argv.indexOf("...") >= 0
						|| argv.indexOf("=") >= 0
						|| argv.indexOf("?") >= 0) argc = -1;
						var doc = rxFunc.matched(riDoc);
						var name = rxFunc.matched(riName);
						var fdoc = null;
						if (doc != null) {
							fdoc = name + "(" + argv + ")";
							if (doc != "") fdoc += " : " + doc;
						}
						addFunc(extFuncs, {
							name: name,
							doc: doc,
							fulldoc: fdoc,
							argc: argc,
							args: args,
							ret: 2,
						});
						codePos = nextPos(rxFunc);
					} // while (rxFunc.matchSub)
				} // for (iter)
				// `/// name = expr : Description`:
				var rxMacro = ~/\/\/\/\s*([\w_]+)\s*=\s*([^:\n]+)(\s*:\s*([^\n]+))?/g;
				codePos = 0;
				while (rxMacro.matchSub(code, codePos)) {
					var name = rxMacro.matched(1);
					var value = StringTools.trim(rxMacro.matched(2));
					var doc = rxMacro.matched(4);
					if (doc != null) doc = StringTools.trim(doc);
					addMacro(extMacro, name, value, doc);
					codePos = nextPos(rxMacro);
				}
			};
			case "dll", "dylib", "so": {
				// `/// doc` [optional]
				// `dllx type func(type arg1, type arg2)`
				var rxFunc = ~/(\/\/\/ *([^\n]*)\n)?\s*dllx\s+(double|char *\*)\s+([\w_]+)\(([^\)]*)\)/g;
				var rxArg = ~/(double|char *\*)\s+([\w_]+)/g;
				codePos = 0;
				while (rxFunc.matchSub(code, codePos)) {
					var argv = rxFunc.matched(5);
					var args = [];
					var argvPos = 0;
					while (rxArg.matchSub(argv, argvPos)) {
						args.push({
							type: rxArg.matched(1) == "double" ? 2 : 1,
							name: rxArg.matched(2),
						});
						argvPos = nextPos(rxArg);
					}
					addFunc(extFuncs, {
						name: rxFunc.matched(4),
						doc: dup ? null : rxFunc.matched(2),
						ret: rxFunc.matched(3) == "double" ? 2 : 1,
						argc: args.length,
						args: args,
					});
					codePos = nextPos(rxFunc);
				}
				// `/// Description\n#define name expr`
				var rxConst = ~/\/\/\/\s*([^\n]*)\n\s*#define\s+([\w_]+)\s+([^\n]+)\n/g;
				codePos = 0;
				while (rxConst.matchSub(code, codePos)) {
					addMacro(extMacro, rxConst.matched(2), rxConst.matched(3),
						dup ? null : rxConst.matched(1));
					codePos = nextPos(rxConst);
				}
				// `/// name = expr : Description`
				var rxMacro = ~/\/\/\/\s*([\w_]+)\s*=\s*([^:\n]+)(\s*:\s*([^\n]+))?/g;
				codePos = 0;
				while (rxMacro.matchSub(code, codePos)) {
					var name = rxMacro.matched(1);
					var value = StringTools.trim(rxMacro.matched(2));
					var doc = rxMacro.matched(4);
					if (doc != null) doc = StringTools.trim(doc);
					addMacro(extMacro, name, value, dup ? null : doc);
					codePos = nextPos(rxMacro);
				}
			};
			default:
		}
		if (extFuncs.firstChild() != null) addText(extFuncs, lbz);
		if (extMacro.firstChild() != null) addText(extMacro, lbz);
		// Replace <functions> and <constants> nodes with the new ones:
		var extFuncsOld:Xml = xmlFind(fileNode, "functions");
		var extMacroOld:Xml = xmlFind(fileNode, "constants");
		var extNodes = 0;
		for (node in fileNode) {
			if (node == extFuncsOld) {
				fileNode.insertChild(extFuncs, extNodes);
				fileNode.removeChild(extFuncsOld);
			} else if (node == extMacroOld) {
				fileNode.insertChild(extMacro, extNodes);
				fileNode.removeChild(extMacroOld);
			}
			extNodes += 1;
		}
	}
	
	static function main() {
		var args = Sys.args();
		if (args.length < 1) {
			Sys.println("Usage: .../some.extension.gmx [...file.ext]");
			return;
		}
		//
		var xmlPath = args[0];
		var files = args.slice(1);
		var text:String = File.getContent(xmlPath);
		var xmlRoot:Xml = haxe.xml.Parser.parse(text);
		var extNode:Xml = xmlFind(xmlRoot, "extension");
		var extName:String = xmlRead(xmlFind(extNode, "name"));
		var extFiles:Xml = xmlFind(extNode, "files");
		var extDir:String = Path.directory(xmlPath) + "/" + extName;
		appliedTo = new Map();
		if (files.length == 0) {
			for (fileNode in extFiles.elementsNamed("file")) apply(extDir, fileNode);
		} else for (fileName in files) {
			var fileNode:Xml = null;
			for (node in extFiles.elementsNamed("file")) {
				if (xmlRead(xmlFind(node, "filename")) == fileName) {
					fileNode = node;
					break;
				}
			}
			if (fileNode == null) {
				error('Could not find <file> with <filename> $fileName in the GMX.');
			}
			apply(extDir, fileNode, fileName);
		}
		File.saveContent(xmlPath, xmlRoot.toString());
	}
	
}

typedef GmxMacro = {
	name:String,
	?doc:String,
	value:String,
}

typedef GmxArg = {
	name:String,
	type:Int,
}

typedef GmxFunc = {
	name:String,
	?doc:String,
	?fulldoc:String,
	ret:Int,
	args:Array<GmxArg>,
	?argc:Int,
}
