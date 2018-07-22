package;
import haxe.io.Path;
import sys.io.File;
import file.GenFile;

/**
 * ...
 * @author YellowAfterlife
 */
class GenExt1 extends GenExt {
	public var root:SfGmx;
	override public function proc(filter:Array<String>) {
		var extName = Path.withoutDirectory(Path.withoutExtension(Path.withoutExtension(path)));
		var dir = Path.join([Path.directory(path), extName]);
		root = SfGmx.parse(File.getContent(path));
		for (fileRoot in root.findAll("files"))
		for (file in fileRoot.findAll("file")) {
			var rel = file.findText("filename");
			if (filter != null && filter.indexOf(rel) < 0) continue;
			var q = GenFile.create(rel, Path.join([dir, rel]));
			if (q != null) {
				q.data = file;
				files.push(q);
			}
		}
	}
	override public function flush():Void {
		for (q in files) {
			var gfile:SfGmx = q.data;
			//
			var gmacros = gfile.find("constants");
			gmacros.children.resize(0);
			for (qm in q.macros) {
				var gm = new SfGmx("constant");
				gm.addChild(new SfGmx("name", qm.name));
				gm.addChild(new SfGmx("value", qm.value));
				gm.addChild(new SfGmx("hidden", qm.hide ? "-1" : "0"));
				gmacros.addChild(gm);
			}
			//
			var fkin = q.funcKind;
			var gfuncs = gfile.find("functions");
			gfuncs.children.resize(0);
			for (qf in q.functions) {
				var gf = new SfGmx("function");
				gf.addChild(new SfGmx("name", qf.name));
				gf.addChild(new SfGmx("externalName", qf.extName));
				gf.addChild(new SfGmx("kind", "" + (qf.comp == null ? 11 : fkin)));
				gf.addChild(new SfGmx("help", qf.comp != null ? qf.comp : ""));
				gf.addChild(new SfGmx("returnType", "" + qf.retType));
				gf.addChild(new SfGmx("argCount", "" + qf.argCount));
				var ga = new SfGmx("args");
				for (qt in qf.argTypes) ga.addChild(new SfGmx("arg", "" + qt));
				gf.addChild(ga);
				gfuncs.addChild(gf);
			}
		} // for (q in files)
		//
		File.saveContent(path, root.toGmxString());
	}
}
