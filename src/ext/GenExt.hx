package ext;
import file.GenFile;

/**
 * ...
 * @author YellowAfterlife
 */
class GenExt {
	public var path:String;
	public var files:Array<file.GenFile> = [];
	public function new(path:String) {
		this.path = path;
	}
	public function addFile(rel:String, full:String) {
		
	}
	public function proc(filter:Array<String>) {
		
	}
	public function flush():Void {
		//
	}
}
