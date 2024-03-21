package ext.gen;
import yy.YyBuf;
import yy.YyExtension;
import yy.YyGUID;

/**
 * For GameMaker Studio 2.2.x (2018-2020 releases)
 * May also work for 2.0.x / 2.1.x (2016-2018), but there are very few reasons to use those.
 * @author YellowAfterlife
 */
class GenExtForGMS22x extends GenExtYY {
	override function postNew():Void {
		if (indent == null) indent = "    ";
		version = 2.2;
	}
	override function createYyBuf():YyBuf {
		var out = super.createYyBuf();
		out.compactArrays = false;
		out.compactObjects = false;
		return out;
	}
	override function flushFileList(out:YyBuf):Void {
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
			out.addFieldStart("constants");
			out.arrayOpen();
			var order = [];
			for (qm in q.macroList) {
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
			out.addPair("final", q.finalFunction);
			//
			out.addFieldStart("functions");
			out.arrayOpen();
			var fkin = q.funcKind;
			for (qf in q.functionList) {
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
			out.addPair("init", q.initFunction);
			out.addPair("kind", d.kind);
			out.addPair("order", d.order);
			out.addPair("origname", d.origname);
			out.addPair("uncompress", d.uncompress);
			out.objectClose();
		}
	}
}