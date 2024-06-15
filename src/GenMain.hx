package;
import ext.GenExt;
import ext.gen.GenExtGMK;
import ext.gen.GenExtGMX;
import ext.gen.GenExtYY;
import ext.GenFileSys;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import tools.GenCopy;
import tools.GenTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GenMain {
	public static var v2:Bool = false;
	public static var remaps:Array<GenRemap> = [];
	public static var dryRun = false;
	public static var extension:GenExt;
	public static function procStart(path:String) {
		var pt = new Path(path);
		var ext = pt.ext?.toLowerCase();
		var dir = pt.dir ?? "";
		var fs = new GenFileSys(dir);
		fs.dryRun = dryRun;
		var fname = Path.withoutDirectory(path);
		switch (Path.extension(path).toLowerCase()) {
			case "gmxgen81":
				v2 = false;
				extension = new GenExtGMK(fname, fs);
			case "yy":
				v2 = true;
				extension = GenExtYY.create(fname, fs);
			default:
				v2 = false;
				extension = new GenExtGMX(fname, fs);
		};
	}
	public static function proc(filter:Array<String>, path:String) {
		var ext = extension;
		ext.proc(filter.length > 0 ? filter : null);
		var paths = [path];
		var rms:Array<GenRemap> = remaps;
		for (file in ext.files) {
			paths.push((cast ext.fs:GenFileSys).dir + "/" + file.relPath);
			if (file.ignore) continue;
			Sys.println('Checking "${file.fname}"...');
			file.proc();
			for (rm in rms) {
				var rx = rm.rx, rs = rm.rs;
				for (func in file.functionList) {
					func.name = rx.replace(func.name, rs);
				}
				for (mcr in file.macroList) {
					mcr.name = rx.replace(mcr.name, rs);
				}
			}
		}
		ext.flush();
		return paths;
	}
	public static function mainImpl(args:Array<String>) {
		//
		inline function procRemap(arr:Array<GenRemap>, from:String, to:String):Void {
			try {
				arr.push({rx:new EReg(from, "g"), rs:to});
			} catch (x:Dynamic) {
				Sys.println("Couldn't process remap: " + x);
			}
		}
		//
		var watch = args.remove("--watch");
		GenOpt.stripCC = args.remove("--strip-cc");
		GenOpt.disableIncompatible = args.remove("--disable-incompatible");
		dryRun = args.remove("--dry");
		//
		var i = 0;
		while (i < args.length) {
			var del = switch (args[i]) {
				case "--remap": procRemap(remaps, args[i + 1], args[i + 2]); 3;
				case "--copy": GenCopy.add(args[i + 1], args[i + 2]); 3;
				case "--helper-prefix": GenOpt.helperPrefix = args[i + 1]; 2;
				case "--gmk-loader": GenOpt.gmkLoader = args[i + 1]; 2;
				default: 0;
			}
			if (del > 0) {
				args.splice(i, del);
			} else i += 1;
		}
		//
		var path = args.shift();
		if (path == null) {
			Sys.println("Use: gmxgen [path to .gmx|.yy]");
			Sys.println("Opt: --watch to auto-build on changes");
			Sys.println("Opt: list of filenames to update");
			return;
		}
		if (!FileSystem.exists(path) || FileSystem.isDirectory(path)) {
			if (FileSystem.exists(path + ".base")) {
				// that's OK
			} else if (FileSystem.exists(path + ".extension.gmx")) {
				path += ".extension.gmx";
			} else if (FileSystem.exists(path + ".yy")) {
				path += ".yy";
			} else {
				Sys.println("GmxGen: Error: Can't find " + path);
				Sys.exit(1);
				return;
			}
		}
		var dir:String;
		if (Path.extension(path).toLowerCase() == "gmx") {
			dir = Path.withoutExtension(Path.withoutExtension(path));
		} else dir = Path.directory(path);
		Sys.println('Running GmxGen for "$path"...');
		//
		procStart(path);
		GenCopy.ready(dir);
		//
		var paths = proc(args, path);
		var mtime = GenTools.mtimeOf(path);
		if (watch) Sys.println("Watching for changes...");
		if (watch) while (true) {
			Sys.sleep(1);
			try {
				var upd = false;
				for (path in paths) {
					if (GenTools.mtimeOf(path) > mtime) {
						upd = true; break;
					}
				}
				GenCopy.update();
				if (!upd) continue;
				Sys.println("[" + Date.now().toString() + "] Update");
				paths = proc(args, path);
				mtime = GenTools.mtimeOf(path);
			} catch (x:Dynamic) {
				Sys.println(x);
			}
		}
	}
	public static function main() {
		try {
			mainImpl(Sys.args());
		} catch (x:Dynamic) {
			Sys.println(extension?.fname + ": error 1: " + x
				+ CallStack.toString(CallStack.exceptionStack(true)));
			Sys.exit(1);
		}
	}
}
typedef GenRemap = { rx:EReg, rs:String };
