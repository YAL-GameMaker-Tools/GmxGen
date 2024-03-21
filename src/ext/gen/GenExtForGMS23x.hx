package ext.gen;
import yy.YyBuf;
import yy.YyExtension;

/**
 * For GameMaker Studio 2.3.x (2020-2021 releases)
 * @author YellowAfterlife
 */
class GenExtForGMS23x extends GenExtYY {
	/** In GM2022, resourceType goes first and there are no tags[] */
	public var frontMeta = false;
	public var usesTags = true;
	public var usesOrder = true;
	override function postNew():Void {
		if (indent == null) indent = "  ";
		version = 2.3;
	}
	function printYyMeta(out:YyBuf, type:String, name:String = "") {
		out.addPair("resourceVersion", "1.0");
		out.addPair("name", name);
		out.addPair("tags", []);
		out.addPair("resourceType", type);
	}
	override function flushFileList(out:YyBuf):Void {
		var extName:String = yyExt.name;
		var extPath = 'extensions/$extName/$extName.yy';
		var fileSep = false;
		for (q in files) {
			if (fileSep) out.addLine(); else fileSep = true;
			out.objectOpen();
			var d:YyExtensionFile = q.data;
			
			inline function addFileMeta() {
				printYyMeta(out, "GMExtensionFile");
			}
			
			//
			if (frontMeta) addFileMeta();
			out.addPair("filename", d.filename);
			out.addPair("origname", d.origname);
			out.addPair("init", q.initFunction);
			out.addPair("final", q.finalFunction);
			out.addPair("kind", d.kind);
			out.addPair("uncompress", d.uncompress);
			
			//
			if (q.functionList.length > 0) {
				out.addFieldStart("functions");
				out.arrayOpen();
				var fkin = q.funcKind;
				var funcSep = false;
				for (qf in q.functionList) {
					inline function addFuncMeta() {
						printYyMeta(out, "GMExtensionFunction", qf.name);
					}
					//
					if (funcSep) out.addLine(); else funcSep = true;
					out.objectOpen();
					if (frontMeta) addFuncMeta();
					out.addPair("externalName", qf.extName);
					out.addPair("kind", qf.comp == null ? 11 : fkin);
					out.addPair("help", qf.comp != null ? qf.comp : "");
					out.addPair("hidden", qf.comp == null);
					out.addPair("returnType", qf.retType);
					out.addPair("argCount", qf.argCount);
					out.addPair("args", qf.argTypes);
					if (!frontMeta) addFuncMeta();
					out.objectClose();
					out.add(",");
				}
				out.arrayClose();
				out.addFieldEnd();
			} else out.addPair("functions", []);
			
			//
			if (q.macroList.length > 0) {
				out.addFieldStart("constants");
				out.arrayOpen();
				var macroSep = false;
				for (qm in q.macroList) {
					inline function addMacroMeta() {
						printYyMeta(out, "GMExtensionConstant", qm.name);
					}
					//
					if (macroSep) out.addLine(); else macroSep = true;
					out.objectOpen();
					if (frontMeta) addMacroMeta();
					out.addPair("value", qm.value);
					out.addPair("hidden", qm.hide);
					if (!frontMeta) addMacroMeta();
					out.objectClose();
					out.add(",");
				}
				out.arrayClose();
				out.addFieldEnd();
			} else out.addPair("constants", []);
			
			//
			out.addPair("ProxyFiles", d.ProxyFiles);
			out.addPair("copyToTargets", d.copyToTargets);
			
			// the "order" field has been phased out in later 2.3.x releases,
			// but I'm not sure when exactly
			if (usesOrder) {
				out.addFieldStart("order");
				out.arrayOpen();
				var orderSep = false;
				for (qf in q.functionList) {
					if (orderSep) out.addLine(); else orderSep = true;
					out.objectOpen();
					out.addPair("name", qf.name);
					out.addPair("path", extPath);
					out.objectClose();
					out.add(",");
				}
				out.arrayClose();
				out.addFieldEnd();
			} else out.addPair("order", []);
			
			if (!frontMeta) addFileMeta();
			
			//
			out.objectClose();
			out.addFieldEnd();
		}
	}
}
class YyResourceMeta {
	public var type:String;
	public var version:String;
	public function new(type:String, version:String) {
		this.type = type;
		this.version = version;
	}
}