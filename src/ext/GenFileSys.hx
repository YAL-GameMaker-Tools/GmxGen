package ext;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author YellowAfterlife
 */
class GenFileSys implements IGenFileSys {
	public var dir:String;
	public function new(dir:String) {
		this.dir = dir;
	}
	
	public function exists(rel:String):Bool {
		return FileSystem.exists(dir + "/" + rel);
	}
	
	public function getContent(rel:String):String {
		return File.getContent(dir + "/" + rel);
	}
	
	public function setContent(rel:String, text:String):Void {
		File.saveContent(dir + "/" + rel, text);
	}
	
}