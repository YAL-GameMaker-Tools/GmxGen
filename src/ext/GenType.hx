package ext;

/**
 * ...
 * @author YellowAfterlife
 */
enum abstract GenType(Int) from Int to Int {
	var Pointer = 1;
	var Value = 2;
	public function toTy() {
		return switch (this) {
			case Pointer: "ty_string";
			default: "ty_real";
		}
	}
}
