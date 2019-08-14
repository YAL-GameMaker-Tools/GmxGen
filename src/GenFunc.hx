package;

/**
 * ...
 * @author YellowAfterlife
 */
class GenFunc {
	public var pos:Int;
	public var name:String;
	public var extName:String;
	
	/** "func(...args)->out : desc" or whatever. null to hide */
	public var comp:String = null;
	
	/** The only time it differs from argTypes.length is when it's -1 for vararg */
	public var argCount:Int = -1;
	
	public var argTypes:Array<GenType> = [];
	
	public var retType:GenType = GenType.Value;
	
	public var funcKind:Int;
	
	public function new(name:String, pos:Int) {
		this.name = name;
		this.extName = name;
		this.pos = pos;
	}
	
}
