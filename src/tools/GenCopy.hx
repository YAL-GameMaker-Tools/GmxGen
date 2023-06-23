package tools ;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author YellowAfterlife
 */
class GenCopy {
	static var items:Array<GenCopyItem> = [];
	public static function add(from:String, to:String) {
		items.push(new GenCopyItem(from, to));
	}
	public static function ready(dir:String) {
		var rxArch = ~/^(.+):(\w+)$/;
		var rxRxEsc = new EReg("([.+?^${}()|[\\]\\/\\\\])", 'g'); // no *
		for (item in items) {
			var to = item.to;
			// process `:arch` suffix in $to:
			if (rxArch.match(to)) {
				var tp = new Path(rxArch.matched(1));
				var arch = rxArch.matched(2);
				if (arch != "x86") {
					tp.file += "_" + arch;
					item.isNonX86 = true;
				}
				to = tp.toString();
			}
			
			// relative paths in $to:
			var tp = new Path(to);
			if (tp.dir == null) tp.dir = dir;
			item.to = tp.toString();
			
			// wildcards in $from:
			if (item.from.indexOf("*") >= 0) {
				var fp:Path = new Path(item.from);
				item.fromDir = fp.dir;
				fp.dir = null;
				var rs = rxRxEsc.replace(fp.toString(), "\\$1");
				rs = StringTools.replace(rs, "*", "(.*?)");
				item.fromRs = "^" + rs + "$";
				item.fromRx = new EReg(item.fromRs, "");
				item.toParts = item.to.split("*");
			}
		}
		update();
	}
	
	static var mtimes:Map<String, Float> = new Map();
	static function check(from:String, nonX86:Bool) {
		var t0 = mtimes[from];
		var t1 = GenMain.mtimeOf(from);
		if (t0 == null || t0 < t1) {
			mtimes[from] = t1;
			// avoid copying x64 DLLs to pre-2.3 projects:
			//trace(from, nonX86, Path.extension(from), file.GenGml.version);
			if (nonX86 && Path.extension(from).toLowerCase() == "dll" && file.GenGml.version < 2.3) return false;
			return true;
		} else return false;
	}
	
	static function copy(from:String, to:String) {
		try {
			File.copy(from, to);
			Sys.println('Copied "$from"');
			Sys.println('    to "$to"');
		} catch (x:Dynamic) {
			Sys.println('Failed to copy "$from"');
			Sys.println('            to "$to"');
			Sys.println('        reason: $x');
		}
	}
	
	public static function update() {
		for (item in items) {
			var frx = item.fromRx;
			if (frx == null) {
				if (check(item.from, item.isNonX86)) copy(item.from, item.to);
				continue;
			}
			var dir = item.fromDir;
			var found = 0;
			for (rel in FileSystem.readDirectory(dir)) {
				if (!frx.match(rel)) continue;
				var full = Path.join([dir, rel]);
				found += 1;
				if (!check(full, item.isNonX86)) continue;
				var tb = new StringBuf();
				var idx = -1;
				for (part in item.toParts) {
					if (++idx > 0) tb.add(frx.matched(idx));
					tb.add(part);
				}
				var tp = tb.toString();
				copy(full, tp);
			}
			if (found == 0) Sys.println('No matches for ${item.fromRs}');
		}
	}
}
class GenCopyItem {
	public var from:String;
	public var fromDir:String = null;
	public var fromRx:EReg = null;
	public var fromRs:String = null;
	public var to:String;
	public var toParts:Array<String> = [];
	public var isNonX86:Bool = false;
	public function new(from:String, to:String) {
		this.from = from;
		this.to = to;
	}
}