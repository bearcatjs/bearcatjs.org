title: markdown-editor
type: examples
order: 1
---

<iframe width="100%" height="500" src="bearcat-examples/browserify-markdown-editor/index.html" allowfullscreen="allowfullscreen" frameborder="0"></iframe> 

Browserify lets you require('modules') in the browser by bundling up all of your dependencies. Therefore, it is easy to resolve a library using browserify by simply call `require('library')`. However, browserify bundles up all files, debug and edit files may meet up some problems. You should watch files and build up bundle file whenever code files changes, moreover when build errored, the error message should show up in the browser to make developer know what happened. For better debugger, developers should know how to use [source-map](http://thlorenz.com/blog/browserify-sourcemaps).  
With bearcat, browserify will simply be a role of `library resolver`, developers write magic javaScript objects, and if want to use a library, use browserify to resolve it.  

This example shows how to use browserify with bearcat.  

First, you should write a javaScript object named `requireUtil` for example as a bridge between bearcat and browserify.  
This file will be bundled into browserify, and it can see `require` to resolve library. Then when some other files need to use a library from browserify, just inject `requireUtil` into it, that's it.  

requireUtil.js
``` js
var RequireUtil = function() {
    this.$id = "requireUtil";
    this.$init = "init";
    this.brace = null;
}
  
RequireUtil.prototype.init = function() {
    this.brace = require('brace');
}
  
bearcat.module(RequireUtil, typeof module !== 'undefined' ? module : {});
```

in your controller javaScript file, inject `requireUtil` with magic attribute `$requireUtil`  

markDownController.js
``` js
var MarkDownController = function() {
    this.$id = "markDownController";
    this.$requireUtil = null; // requireUtil is ready for you to use
}
  
bearcat.module(MarkDownController, typeof module !== 'undefined' ? module : {});
```

then add your code logic  

markDownController.js
``` js
var MarkDownController = function() {
    this.$id = "markDownController";
    this.$requireUtil = null; // requireUtil is ready for you to use
}
  
MarkDownController.prototype.initBrace = function(md) {
    var ace = this.$requireUtil.brace;
    var editor = ace.edit('editor');
    editor.getSession().setMode('ace/mode/markdown');
    editor.setTheme('ace/theme/monokai');
    editor.setValue(md);
    editor.clearSelection();
    return editor;
}
  
bearcat.module(MarkDownController, typeof module !== 'undefined' ? module : {});
```

because `markDownController` file is asynchronously loaded, you can edit and debug as you like, just enjoy coding...   

the whole sources can be found on [bearcat browserify-markdown-editor](https://github.com/bearcatjs/bearcat-examples/tree/master/browserify-markdown-editor)  
this exmaple is originally cloned from [thlorenz browserify-markdown-editor](https://github.com/thlorenz/browserify-markdown-editor), you can make a comparison  