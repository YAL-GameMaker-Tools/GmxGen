package ext.gen;

import yy.YyBuf;
import yy.YyExtension;

/**
 * For GameMaker 2023-2024 releases.
 * The fields are now sorted alphabetically, which is generally good news.
 * @author YellowAfterlife
 */
class GenExtForGM2023x extends GenExtForGMS23x {
	override function postNew():Void {
		super.postNew();
		version = 2024.0;
	}
	override function flushFileList(out:YyBuf):Void {
		var sep = false;
		var hasDollarType = version >= 2024;
		var yyVersion = hasDollarType ? "2.0" : "1.0";
		for (file in files) {
			if (sep) out.addLine(); else sep = true;
			var extFile:YyExtensionFile = file.data;
			var hasResourceType = extFile.resourceType != null;
			//
			extFile.functions.resize(0);
			for (fun in file.functionList) {
				var extFunc:YyExtensionFunc = {
					hidden: fun.isHidden,
					externalName: fun.extName,
					help: fun.isHidden ? "" : fun.comp,
					kind: fun.isHidden ? 11 : file.funcKind,
					argCount: fun.argCount,
					args: fun.argTypes,
					returnType: fun.retType,
					documentation: "",
				};
				if (hasDollarType) {
					Reflect.setField(extFunc, "$GMExtensionFunction", "");
					Reflect.setField(extFunc, "%Name", fun.name);
				}
				if (hasResourceType) {
					extFunc.resourceType = "GMExtensionFunction";
					extFunc.resourceVersion = yyVersion;
					extFunc.name = fun.name;
				}
				extFile.functions.push(extFunc);
			}
			//
			var fields = Reflect.fields(extFile);
			out.sortFields(fields);
			out.objectOpen();
			for (field in fields) {
				if (field == "$hxOrder") continue;
				var value = Reflect.field(extFile, field);
				if (value is Array) {
					out.addFieldStart(field);
					var arr:Array<Any> = value;
					if (arr.length > 0) {
						out.addString("[");
						out.depth++;
						for (item in arr) {
							out.addLine();
							out.addValue(item);
							out.addString(",");
						}
						out.addLine(-1);
						out.addString("]");
					} else out.addString("[]");
					out.addFieldEnd();
				} else {
					out.addPair(field, value);
				}
			}
			out.objectClose();
			out.addString(",");
		}
	}
}