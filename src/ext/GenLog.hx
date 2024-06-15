package ext;

/**
 * ...
 * @author YellowAfterlife
 */
class GenLog {
	public static function log(message:String){
		Sys.println(message);
	}
	public static function warn(message:String) {
		Sys.println("GmxGen: warning #: " + message);
	}
}