package tools;
import haxe.macro.Expr;

/**
 * ...
 * @author YellowAfterlife
 */
class ERegGen {
	public static macro function run(expr:Expr) {
		trace(expr);
		return macro null;
	}
}