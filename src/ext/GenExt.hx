package ext;
import ext.IGenFileSys;
import file.GenFile;
import file.*;
import haxe.io.Path;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GenExt {
	public var fname:String;
	public var fs:IGenFileSys;
	public var files:Array<GenFile> = [];
	public function new(fname:String, fs:IGenFileSys) {
		this.fname = fname;
		this.fs = fs;
	}
	
	public function addFile(rel:String, full:String) {
		
	}
	public function proc(filter:Array<String>) {
		
	}
	public function flush():Void {
		//
	}
	
	public function createFile(fname:String, path:String) {
		var out:GenFile;
		var origPath = path;
		switch (Path.extension(fname).toLowerCase()) {
			case "dll", "dylib", "so": {
				var tp:String;
				if (fs.exists(tp = Path.withExtension(path, "cpp"))) {
					path = tp;
					out = new GenCpp();
				} else if (fs.exists(tp = Path.withExtension(path, "h"))) {
					path = tp;
					out = new GenCpp();
				} else if (fs.exists(tp = Path.withExtension(path, "c"))) {
					path = tp;
					out = new GenCpp();
				} else if (fs.exists(tp = Path.withExtension(path, "cs"))) {
					path = tp;
					out = new GenCs();
				} else return null;
			};
			case "gml": {
				var tp:String;
				if (fs.exists(tp = path + ".dummy")) {
					path = tp;
					out = new GenDummies();
				} else out = new GenGml();
			};
			case "js": {
				if (Path.withoutExtension(fname).endsWith("_wasm")) {
					// myext_wasm.js -> myext.cpp
					var pt = new Path(path);
					pt.ext = "cpp";
					pt.file = pt.file.substring(0, pt.file.length - 5);
					path = pt.toString();
					out = new GenWasm();
				} else out = new GenJS();
			};
			default: return null;
		}
		if (path == null || !fs.exists(path)) return null;
		out.fname = fname;
		out.relPath = path;
		out.ext = this;
		return out;
	}
	public function createIgnoreFile(fname:String, path:String) {
		var out = new GenFile();
		out.ignore = true;
		out.fname = fname;
		out.relPath = path;
		out.ext = this;
		return out;
	}
}
