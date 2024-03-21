package yy;

/**
 * ...
 * @author YellowAfterlife
 */
typedef YyExtension = {
	>YyBase,
	name:String,
	files:Array<YyExtensionFile>,
}
typedef YyExtensionFile = {
	>YyBase,
	filename:String,
	functions:Array<YyExtensionFunc>,
	constants:Array<YyExtensionMacro>,
	ProxyFiles:Array<Dynamic>,
	copyToTargets:String,
	//final:String,
	init:String,
	kind:Int,
	order:Array<YyGUID>,
	origname:String,
	uncompress:Bool,
}
typedef YyExtensionFunc = {
	>YyBase,
	?name:String,
	externalName:String,
	help:String,
	args:Array<Int>,
	argCount:Int,
	hidden:Bool,
	kind:Int,
	returnType:Int,
	// GM2024
	?documentation:String,
}
typedef YyExtensionMacro = {
	>YyBase,
	?constantName:String,
	?name:String,
	hidden:Bool,
	value:String,
}
typedef YyBase = {
	// 2.2
	?id:YyGUID,
	?modelName:String,
	?mvc:String,
	// 2.3
	?resourceType:String,
	?resourceVersion:String,
};
