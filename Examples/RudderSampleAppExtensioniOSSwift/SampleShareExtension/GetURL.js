var GetURL = function() {};
GetURL.prototype = {
run: function(arguments) {
    arguments.completionFunction({"URL": document.URL, "selectedText": document.getSelection().toString(),
        "title": document.title, "comment": document.URL});
}
};
var ExtensionPreprocessingJS = new GetURL;
