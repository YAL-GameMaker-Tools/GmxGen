#define ggt_gml_hidden
// GML functions are hidden unless they have a comment inside them
exit;

#define ggt_gml_add
/// (a, b)
// ^ like this
return argument0 + argument1;

// doing #macro inside an extension doesn't work so you can do this:
//#macro ggt_gml_zero 0