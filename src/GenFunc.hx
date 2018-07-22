package;

/**
 * ...
 * @author YellowAfterlife
 */
class GenFunc {
	public var pos:Int;
	public var name:String;
	public var extName:String;
	
	/** func(...args)->out : desc */
	public var comp:String = null;
	
	/** desc */
	public var doc:String = null;
	
	public var argCount:Int = -1;
	
	public var argTypes:Array<GenType> = [];
	
	public var retType:GenType = GenType.Value;
	
	public var guid:String;
	
	public function new(name:String, pos:Int) {
		this.name = name;
		this.extName = name;
		this.pos = pos;
	}
	
}
