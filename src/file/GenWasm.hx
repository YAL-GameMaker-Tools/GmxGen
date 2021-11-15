package file;
import haxe.io.Path;
import sys.io.File;
import tools.GenBuf;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GenWasm extends GenCpp {
	var wrap:GenBuf;
	override public function scan(code:String):Void {
		var pfx = GenMain.helperPrefix;
		if (pfx == null) throw "Should set --helper-prefix <name> for WASM";
		wrap = new GenBuf();
		wrap.addFormat('function %(s)_wasm_autowrap() %{', pfx);
		super.scan(code);
		wrap.addFormat('%-}');
		File.saveContent(Path.withoutExtension(origPath) + "_autogen.js", wrap.toString());
	}
	static var rxIsString:EReg = ~/^\s*(const\s+)?char\s*\*/;
	static var rxInOut:EReg = ~/^_*([iI]n_*)?([oO]ut)?[_A-Z]/i;
	override public function procCppFunc(fn:GenFunc, retType:String, args:Array<{name:String, type:String}>):Void {
		super.procCppFunc(fn, retType, args);
		var fnName = "_" + fn.extName; fn.extName = fnName;
		var pfx = GenMain.helperPrefix;
		
		var wantFunc = false;
		var pre = new GenBuf(); pre.indent = wrap.indent + 2;
		var post = new GenBuf(); post.indent = wrap.indent + 2;
		var funcArgs = [for (i => arg in args) "arg$" + arg.name];
		var callArgs = funcArgs.copy();
		for (i => arg in args) {
			if (arg.type == "double") continue;
			wantFunc = true;
			var arg0 = callArgs[i];
			var arg1 = "ex$" + arg.name;
			if (rxIsString.match(arg.type)) {
				pre.addFormat('%|var %s = allocateUTF8(%s);', arg1, arg0);
				post.addFormat('%|_free(%s)', arg1);
			} else {
				var next = args[i + 1];
				if (next == null || !next.name.startsWith(arg.name) || next.type != "double") {
					throw 'In function ${fn.name}: pointer argument ${arg.name} '
						+ 'should be followed by a numeric "size" argument '
						+ 'with name starting with the pointer argument name '
						+ '(e.g. `uint8_t* buf, double buf_size`)';
				}
				var _in = true, _out = false;
				if (rxInOut.match(arg.name)) {
					_in = rxInOut.matched(1) != null;
					_out = rxInOut.matched(2) != null;
					if (_out == false) _in = true;
				}
				var sizeArg = funcArgs[i + 1];
				if (_in) {
					pre.addFormat('%|var %s = %(s)_wasm_alloc(%s, %s);', arg1, pfx, sizeArg, arg0);
				} else pre.addFormat('%|var %s = %(s)_wasm_alloc(%s);', arg1, pfx, sizeArg);
				if (_out) {
					post.addFormat('%|%(s)_wasm_free(%s, %s, %s);', pfx, arg1, arg0, sizeArg);
				} else post.addFormat('%|%(s)_wasm_free(%s);', pfx, arg1);
			}
			callArgs[i] = arg1;
		}
		if (!wantFunc) return;
		wrap.addFormat('%|window.$fnName = (function() %{');
		wrap.addFormat('%|var wfn = Module.$fnName;');
		wrap.addFormat('%|return function(%s) %{', funcArgs.join(", "));
		wrap.add(pre);
		wrap.addFormat('%|var result = wfn(%s);', callArgs.join(", "));
		wrap.add(post);
		wrap.addFormat('%|return result;');
		wrap.addFormat('%-}');
		wrap.addFormat('%-})();');
	}
}