package;

/**
 * ...
 * @author YellowAfterlife
 */
class GenMacro {
	public var pos:Int;
	public var name:String;
	public var value:String;
	public var hide:Bool;
	public function new(name:String, value:String, hide:Bool, pos:Int) {
		this.value = value;
		this.name = name;
		this.hide = hide;
		this.pos = pos;
	}
	
}
