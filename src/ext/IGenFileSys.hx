package ext;

/**
 * @author YellowAfterlife
 */
interface IGenFileSys {
	function exists(rel:String):Bool;
	function getContent(rel:String):String;
	function setContent(rel:String, text:String):Void;
}