package;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author YellowAfterlife
 */
class GenMain {
	public static var v2:Bool = false;
	public static var remaps:Array<GenRemap> = [];
	public static var extension:GenExt;
	public static var helperPrefix:String = null;
	public static function procStart(path:String) {
		extension = switch (Path.extension(path).toLowerCase()) {
			case "yy": v2 = true; new GenExt2(path);
			default: v2 = false; new GenExt1(path);
		};
	}
	public static function proc(filter:Array<String>, path:String) {
		var ext = extension;
		ext.proc(filter.length > 0 ? filter : null);
		var paths = [path];
		var rms:Array<GenRemap> = remaps;
		for (file in ext.files) {
			file.proc();
			paths.push(file.path);
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
	public static function mtimeOf(path:String):Float {
		try {
			return FileSystem.stat(path).mtime.getTime();
		} catch (x:Dynamic) {
			return 0;
		}
	}
	public static function mainImpl(args:Array<String>) {
		var watch = args.remove("--watch");
		//
		inline function procRemap(arr:Array<GenRemap>, from:String, to:String):Void {
			try {
				arr.push({rx:new EReg(from, "g"), rs:to});
			} catch (x:Dynamic) {
				Sys.println("Couldn't process remap: " + x);
			}
		}
		var i = 0;
		while (i < args.length) {
			var del = switch (args[i]) {
				case "--remap": procRemap(remaps, args[i + 1], args[i + 2]); 3;
				case "--copy": GenCopy.add(args[i + 1], args[i + 2]); 3;
				case "--helper-prefix": helperPrefix = args[i + 1]; 2;
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
		var mtime = mtimeOf(path);
		if (watch) Sys.println("Watching for changes...");
		if (watch) while (true) {
			Sys.sleep(1);
			try {
				var upd = false;
				for (path in paths) {
					if (mtimeOf(path) > mtime) {
						upd = true; break;
					}
				}
				GenCopy.update();
				if (!upd) continue;
				Sys.println("[" + Date.now().toString() + "] Update");
				paths = proc(args, path);
				mtime = mtimeOf(path);
			} catch (x:Dynamic) {
				Sys.println(x);
			}
		}
	}
	public static function main() {
		try {
			mainImpl(Sys.args());
		} catch (x:Dynamic) {
			Sys.println(Path.withoutDirectory(extension.path) + ": error 1: " + x);
			Sys.exit(1);
		}
	}
}
typedef GenRemap = { rx:EReg, rs:String };
