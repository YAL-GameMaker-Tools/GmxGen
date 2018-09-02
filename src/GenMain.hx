package;
import haxe.io.Path;
import sys.FileSystem;

/**
 * ...
 * @author YellowAfterlife
 */
class GenMain {
	public static var v2:Bool = false;
	public static function proc(filter:Array<String>, path:String) {
		var ext:GenExt = switch (Path.extension(path).toLowerCase()) {
			case "yy": v2 = true; new GenExt2(path);
			default: v2 = false; new GenExt1(path);
		};
		ext.proc(filter.length > 0 ? filter : null);
		var paths = [path];
		for (file in ext.files) {
			file.proc();
			paths.push(file.path);
		}
		ext.flush();
		return paths;
	}
	public static function main() {
		var args = Sys.args();
		var watch = args.remove("--watch");
		var path = args.shift();
		if (path == null) {
			Sys.println("Use: gmxgen [path to .gmx|.yy]");
			Sys.println("Opt: --watch to auto-build on changes");
			Sys.println("Opt: list of filenames to update");
			return;
		}
		if (!FileSystem.exists(path) || FileSystem.isDirectory(path)) {
			if (FileSystem.exists(path + ".extension.gmx")) {
				path += ".extension.gmx";
			} else if (FileSystem.exists(path + ".yy")) {
				path += ".yy";
			} else {
				Sys.println("Can't find " + path);
				return;
			}
		}
		//
		var paths = proc(args, path);
		var mtime = FileSystem.stat(path).mtime.getTime();
		if (watch) Sys.println("Watching for changes...");
		if (watch) while (true) {
			Sys.sleep(1);
			try {
				var upd = false;
				for (path in paths) {
					if (FileSystem.stat(path).mtime.getTime() > mtime) {
						upd = true; break;
					}
				}
				if (!upd) continue;
				Sys.println("[" + Date.now().toString() + "] Update");
				paths = proc(args, path);
				mtime = FileSystem.stat(path).mtime.getTime();
			} catch (x:Dynamic) {
				Sys.println(x);
			}
		}
	}
}
