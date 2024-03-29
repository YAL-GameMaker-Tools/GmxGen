package ext.gen;
import ext.GenMacro;
import ext.IGenFileSys;
import file.GenGml;
import haxe.io.Path;
import file.GenFile;
import yy.SfGmx;

/**
 * ...
 * @author YellowAfterlife
 */
class GenExtGMX extends GenExt {
	public var root:SfGmx;
	public function new(path:String, fs:IGenFileSys) {
		super(path, fs);
		GenGml.version = 1.4;
	}
	override public function proc(filter:Array<String>) {
		var extName = Path.withoutExtension(Path.withoutExtension(fname));
		
		var gmxText:String;
		if (fs.exists(fname + ".base")) {
			gmxText = fs.getContent(fname + ".base");
		} else gmxText = fs.getContent(fname);
		
		var dir = extName;
		root = SfGmx.parse(gmxText);
		for (fileRoot in root.findAll("files"))
		for (file in fileRoot.findAll("file")) {
			var rel = file.findText("filename");
			var q:GenFile;
			var filePath = Path.join([dir, rel]);
			//
			if (filter == null || filter.indexOf(rel) >= 0) {
				q = createFile(rel, filePath);
			} else q = null;
			//
			if (q == null) {
				q = createIgnoreFile(rel, filePath);
				for (xf in file.find("functions").findAll("function")) {
					var gf = new ext.GenFunc(xf.findText("name"), 0);
					gf.argCount = xf.findInt("argCount");
					for (xa in xf.find("args").findAll("arg")) {
						gf.argTypes.push(xa.textAsInt);
					}
					gf.retType = xf.findInt("returnType");
					gf.comp = xf.findText("help");
					if (gf.comp == "") gf.comp = null;
					q.addFunction(gf);
				}
				for (xm in file.find("constants").findAll("constant")) {
					var gm = new ext.GenMacro(xm.findText("name"), xm.findText("value"),
						xm.findInt("hidden") != 0, 0);
					q.addMacro(gm);
				}
			}
			q.initFunction = file.findText("init");
			q.finalFunction = file.findText("final");
			//
			q.data = file;
			files.push(q);
		}
	}
	override public function flush():Void {
		for (q in files) {
			var gfile:SfGmx = q.data;
			gfile.find("init").text = q.initFunction;
			gfile.find("final").text = q.finalFunction;
			//
			var gmacros = gfile.find("constants");
			gmacros.children.resize(0);
			for (qm in q.macroList) {
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
			for (qf in q.functionList) {
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
		fs.setContent(fname, root.toGmxString());
	}
}
