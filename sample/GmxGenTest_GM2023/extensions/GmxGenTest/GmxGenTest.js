// GmxGen also works for JS extensions.

// For JS, only functions with a `///` comment will be exported.
///
function ggt_js_add(a, b) {
    return a + b;
}

// This is allowed too:
///
window.ggt_js_add_2 = function(a, b) {
    return a + b;
}

// If you want to (likely) hide a function from the end user,
// add a `~` at the end of your comment.
///~
function ggt_js_hidden_add(a, b) {
    return a + b;
}

// You can override the displayed function signature like so:
/// (value, ...values)
function ggt_js_add_many() {
    var result = arguments[0];
    for (var i = 1; i < arguments.length; i++) {
        result += arguments[i];
    }
    return result;
}
