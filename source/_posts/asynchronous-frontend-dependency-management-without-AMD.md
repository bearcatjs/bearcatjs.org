title: asynchronous frontend dependency management without AMD
date: 2014-12-24 23:50:05
comments: true
---

## Overview
Frontend dependency management is always the discussion point, people have a lot of to say. The key reason for this is that javaScript language itself does not provide `module` like support, it really sucks developers.  

For years ago, developers used to use `<script>` tag to write code, however when the page codes grows, the maintainability will be harder and harder. Then, with the arise of [nodejs](http://nodejs.org/), [CommonJS](http://wiki.commonjs.org/wiki/CommonJS) brings up using `require`, `exports` to resolve modules. It seems really nice when using in nodejs, however, when it meets browser, it works not quite well. The reason is simply that browser does not support synchronous `require`, it can not load a script from file I/O. Then [AMD](https://github.com/amdjs/amdjs-api/wiki/AMD) comes up a specification used well for browser, as the AMD says:  

<!-- more -->

{% blockquote %}
The Asynchronous Module Definition (AMD) API specifies a mechanism for defining modules such that the module and its dependencies can be asynchronously loaded. This is particularly well suited for the browser environment where synchronous loading of modules incurs performance, usability, debugging, and cross-domain access problems.
{% endblockquote %}

AMD has two main concerns:  
### asynchronous loading script
this works well in browser, and fascinates developers a lot, developers write modular scripts in different files, different modules can be dependent with some others, which makes codes resuable, moreover debug and edit files are quite simple and smooth.  
### use `define` to define a module and its dependecies
to use AMD, the module must use `define` which really makes developers messy.  
when using AMD, it is easy to run into the following road-blocks:  
- want to use Libray X, does it suport AMD ?  
- if it is not, I have to add a shim ? Should I patch the library ?
- if it supports, I'll want to load it from a libs directory
- Where is the root of my application ? Should I write a alias to use it ?
- What about sharing code client/server ? 

AMD especially [requirejs](http://requirejs.org/docs/api.html) has its answers for every question. AMD's answer for `nearly every one of them` is to `add some configuration directivers` or `write a r.js plug-in`.  
Then we write configrutions file with many lines long of obscure directives, and these files are hard to be reused for example, used for the tests.  

So, what about asynchronous loading scripts without using AMD like `define` or writing messy configuration file ?
This is what [bearcat](http://bearcatjs.org) tries to make an effort, which enables developers to write `magic, self-described javaScript objects` and simply register them to bearcat, bearcat will resolve dependencies, asynchronous loading srcipts when needed, ready for you to use. There are no `define`, no `require`, no `bundle file`, everything is simple, easy, and back to javaScript nature.  

## Show me some codes
Let's begin with a dead simple example: 
A simple car must have an engine to startup, so you write two files. 

car.js
``` js
var Car = function() {
}
  
Car.prototype.run = function() { 
    console.log('run car...');
}

```

engine.js
``` js
var Engine = function() {
}
  
Engine.prototype.run = function() {
    console.log('run engine...');
}
```

Car has the dependency of engine, so how to resolve the dependency ? 
In AMD(requirejs), you should do the following:  
* wrap the code with `define`
* in define, resolve `engine` dependency
* setup data-main, then run

so codes may be like this:  

car.js
``` js
define(function(require) {
    var Engine = require('./engine');
  
    var Car = function() {
	    this.engine = new Engine();
    }
  
    Car.prototype.run = function() {
	    this.engine.run();
	    console.log('run car...');
    }
  
    return Car;
});
```

engine.js
``` js
define(function(require) {
    var Engine = function() {}
  
    Engine.prototype.run = function() {
	    console.log('run engine...');
    }
  
    return Engine;
})
```

using `define`, the codes will be hard to be shared for client/server  
using `relative path`, car and engine are tightly coupled, what if the car wants to use another engine to run ?  

In bearcat, it is dead simple and nature.  
Just add some `magic attributes` to javaScript objects, and that's it !

car.js
``` js
var Car = function() {
    this.$id = "car";
    this.$engine = null;
}
  
Car.prototype.run = function() { 
    this.$engine.run(); 
    console.log('run car...');
}
  
bearcat.module(Car, typeof module !== 'undefined' ? module : {});
```

engine.js
``` js
var Engine = function() {
    this.$id = "engine";
}
  
Engine.prototype.run = function() {
    console.log('run engine...');
}
  
bearcat.module(Engine, typeof module !== 'undefined' ? module : {});
```

car and engine use `this.$id` attribute to define its unique id  
car use `this.$engine` attribute to tell bearcat that it wants a dependency with the id of `engine`
car and engine both register its function constructor with magic attributes to bearcat

then, what does bearcat do ?
* resolve dependencies, knows car wants a dependency with the id of `engine`
* asynchronously load `engine.js` script file
* when car instance is created, automatically inject `engine` instance into car's `$engine` attribute
* when car invokes `run` method, engine is also ready to `run`

So, as you can see, what bearcat does is `dependency injection with asynchronous loading`.  

the whole demo sources can be found on [AMD vs bearcat](https://github.com/bearcatjs/bearcat-examples/tree/master/bearcat-vs-AMD)

## AMD vs bearcat
### module dependency
* AMD resolves script files as modules, modules use `define` to resolve dependencies, `define` makes it hard be compatible especially when some library does not provides `define` hook. Besides, modules are relative to some others, thus are `tightly` coupled, so unit-tests will be quite messy.    
* bearcat resolves script files also as modules, modules are all simple javaScript objects, which are compatible with javaScript world. modules use magic, self-described attributes to resolve dependencies through dependency injection, therefore, code is cleaner with the DI principle and decoupling is more effective when objects are provided with their dependencies. The object does not look up its dependencies, and does not know the location or class of the dependencies. As such, your classes become easier to test, in particular when the dependencies are on interfaces or abstract base classes, which allow for stub or mock implementations to be used in unit tests.  

### script loading
AMD and bearcat both supports asynchronous scripts loading as needed, both are easy to edit and debug.  

### configuration
* AMD(requirejs) needs to config for `baseUrl`, `shim`, `alias`, `packages` etc ... What's more, this configuration file can not be shared very well. When you want to use in another project or for use in unit-test, you should modifiy configuration file to make AMD happy.    
* bearcat does not need much configuration, as you can see, all configurations are embeded into javaScript objects themselves, that's it, then bearcat will do the following work, resolve dependency, asynchronously load script file if needed, create instance and inject it.  

## Want to use a libray ?
bearcat does not care about how to use a library, as long as it is a javaScript library, can be used in browser, it is ok. bearcat also does not resolve library as a dependency, for this concern, developers can try to using bearcat with [browserify](http://browserify.org/) for example.  

### Using with browserify
Browserify lets you require('modules') in the browser by bundling up all of your dependencies. Therefore, it is easy to resolve a library using browserify by simply call `require('library')`. However, browserify bundles up all files, debug and edit files may meet up some problems. You should watch files and build up bundle file whenever code files changes, moreover when build errored, the error message should show up in the browser to make developer know what happened. For better debugger, developers should know how to use [source-map](http://thlorenz.com/blog/browserify-sourcemaps).  
With bearcat, browserify will simply be a role of `library resolver`, developers write magic javaScript objects, and if want to use a library, use browserify to resolve it.  

Here comes with an example: use `jQuery` library  
write a javaScript object named with `requireUtil`, this acts as a bridge between browserify and bearcat    

requireUtil.js
``` js
var RequireUtil = function() {
    this.$id = "requireUtil";
    this.$init = "init"; // nice, sweet init hook
    this.$ = null;
}
  
RequireUtil.prototype.init = function() {
    var $ = require('jquery');
    this.$ = $;
}
  
bearcat.module(RequireUtil, typeof module !== 'undefined' ? module : {});
``` 

write our main javaScript object named with `testJquery`, it has the dependency of `requireUtil`.  

testJquery.js
``` js
var TestJquery = function() {
    this.$id = "testJquery";
    this.$requireUtil = null;
}
  
TestJquery.prototype.go = function() {
    var $ = this.$requireUtil.$; // get jQuery
    console.log($);	
}
  
bearcat.module(TestJquery, typeof module !== 'undefined' ? module : {});
```

bundle `requireUtil.js` into browserify to enable `require` ability  

``` js
var bearcat = require('bearcat');
window.bearcat = bearcat;          // make bearcat global
bearcat.createApp();

require('./bearcat-bootstrap');    // auto-generated bearcat-bootstrap file with bearcat command line
require('./app/util/requireUtil'); // magic javaScript object if want to use 'require', add it to browserify bundle
bearcat.use(['testJquery']);       // use testJquery
bearcat.start(function() {
    var testJquery = bearcat.getBean('testJquery');
    testJquery.go();
});
```

the whole sources can be found on [bearcat-browserify-jquery](https://github.com/bearcatjs/bearcat-examples/tree/master/bearcat-browserify-jquery)  

## Conclusion
bearcat is still a young but promising project, it heavilly needs your contributions.  
bearcat is focused on writing small javaScripts, but building big world. The world is connected through bearcat's powerful dependency injection and Aspect Oriented Programming(AOP). Codes are shareable, configurations are javaScript objects enhanced by themselves, dependencies are auto-resolved, scripts are asynchronously loaded if needed.   

The official site     [http://bearcatjs.org/](http://bearcatjs.org/)  
The official twitter  [bearcatjs](https://twitter.com/_bearcatjs)
The github repository [https://github.com/bearcatjs/bearcat](https://github.com/bearcatjs/bearcat)

May you enjoy coding with bearcat ...

## Reference
* [why-i-stopped-using-amd](http://codeofrob.com/entries/why-i-stopped-using-amd.html)
* [journey-from-requirejs-to-browserify](http://esa-matti.suuronen.org/blog/2013/03/22/journey-from-requirejs-to-browserify/)
* [angularjs-vs-knockout-modules-and-di-6](http://blogs.lessthandot.com/index.php/webdev/uidevelopment/angularjs-vs-knockout-modules-and-di-6/)
* [angularjs dependency injection](https://docs.angularjs.org/guide/di)
* [requirejs-angularjs-dependency-injection](http://solutionoptimist.com/2013/09/30/requirejs-angularjs-dependency-injection/)