#define GmxGen
/// GmxGen()
var _path;

_path = "GmxGenTest.dll";
global.f_ggt_cpp_reset_number = external_define(_path, "ggt_cpp_reset_number", dll_cdecl, ty_real, 0);
global.f_ggt_cpp_set_number = external_define(_path, "ggt_cpp_set_number", dll_cdecl, ty_real, 1, ty_real);
global.f_ggt_cpp_get_number = external_define(_path, "ggt_cpp_get_number", dll_cdecl, ty_real, 0);
global.f_ggt_cpp_add_numbers = external_define(_path, "ggt_cpp_add_numbers", dll_cdecl, ty_real, 2, ty_real, ty_real);
global.f_ggt_cpp_add_strings = external_define(_path, "ggt_cpp_add_strings", dll_cdecl, ty_string, 2, ty_string, ty_string);
global.f_ggt_cpp_add_mixed = external_define(_path, "ggt_cpp_add_mixed", dll_cdecl, ty_string, 2, ty_string, ty_real);
global.f_ggt_cpp_fill_bytes = external_define(_path, "ggt_cpp_fill_bytes", dll_cdecl, ty_real, 1, ty_string);

_path = "GmxGenTest-Cs.dll";
global.f_ggt_cs_add_numbers = external_define(_path, "ggt_cs_add_numbers", dll_cdecl, ty_real, 2, ty_real, ty_real);
global.f_ggt_cs_add_strings = external_define(_path, "ggt_cs_add_strings", dll_cdecl, ty_string, 2, ty_string, ty_string);
global.f_ggt_cs_fill_bytes = external_define(_path, "ggt_cs_fill_bytes", dll_cdecl, ty_real, 1, ty_string);
#define ggt_cpp_reset_number
return external_call(global.f_ggt_cpp_reset_number);
#define ggt_cpp_set_number
/// ggt_cpp_set_number(v)
return external_call(global.f_ggt_cpp_set_number, argument0);
#define ggt_cpp_get_number
/// ggt_cpp_get_number()->int
return external_call(global.f_ggt_cpp_get_number);
#define ggt_cpp_add_numbers
/// ggt_cpp_add_numbers(a, b)
return external_call(global.f_ggt_cpp_add_numbers, argument0, argument1);
#define ggt_cpp_add_strings
/// ggt_cpp_add_strings(a, b)
return external_call(global.f_ggt_cpp_add_strings, argument0, argument1);
#define ggt_cpp_add_mixed
/// ggt_cpp_add_mixed(a, b)
return external_call(global.f_ggt_cpp_add_mixed, argument0, argument1);
#define ggt_cpp_fill_bytes
/// ggt_cpp_fill_bytes(buf)
return external_call(global.f_ggt_cpp_fill_bytes, argument0);
#define ggt_cs_add_numbers
/// ggt_cs_add_numbers(a, b)
return external_call(global.f_ggt_cs_add_numbers, argument0, argument1);
#define ggt_cs_add_strings
/// ggt_cs_add_strings(a, b)
return external_call(global.f_ggt_cs_add_strings, argument0, argument1);
#define ggt_cs_fill_bytes
/// ggt_cs_fill_bytes(buf)
return external_call(global.f_ggt_cs_fill_bytes, argument0);
