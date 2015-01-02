title: browserify with asynchronous script loading​
date: 2015-01-02 11:50:05
comments: true
---

## Overview

[browserify](https://github.com/substack/node-browserify) is a great project that makes npm everywhere.  

`Browserify lets you require('modules') in the browser by bundling up all of your dependencies.`  

It is really cool since developers can now use modules from npm which is growing extremely fast, more and more front-end libraries, tools, frameworks are now supporting npm, it is a great advantage. browserify makes it real for front-end developers to use npm modules without much pains.  

browserify uses the same module system as node, it is called [node-flavored](http://nodejs.org/docs/latest/api/modules.html) CommonJS modules. It uses `require`, `exports` to organize modules, and uses `package.json`, `node_modules` to make module reuseable.  

therefore, you write node-style modular codes, you can test in node, then if you want to use in the browser, you bundle it through `browserify` command：  

```
browserify hello.js > bundle.js
```

now `bundle.js` contains all the javascript that `hello.js` needs to work. To use in the browser, just plop it into a single `script` tag in some html：  

``` html
<html>
  <body>
    <script src="bundle.js"></script>
  </body>
</html>
``` 

as you see, browserify bundles all modular codes in a build process, then it uses the final bundle file, not your original source codes. So when `bundle.js` file loaded in the browser, all your modular codes are loaded and mapped so that node-style CommonJS `require` can be worked in the browser. The build process that is always needed, is a problem that not only browserify faces, other browser CommonJS module system(like component, duo, webpack) also faces. 

## browserify problems
All problems browserify faces come from the annoying `build process`, it is not exist in nodejs environment, however when in browser environment it is a must to make CommonJS work.  
Then developers have to edit the code, build the bundle, set up a debugger, find the source, edit the code, then build the bundle again...
Coding and editing will be not easy for most developers, although browserify provides some usefull tools to resolve all these pains:  
* Use [watchify](https://www.npmjs.com/package/watchify), a browserify compatible caching bundler, for super-fast bundle rebuilds as you develop.
* Use --debug when creating bundles to have Browserify automatically include Source Maps for easy debugging.
* Check out tools like [Beefy](http://didact.us/beefy/) or [run-browser](https://github.com/ForbesLindesay/run-browser) which make automating browserify development easier.

However, when you are building multiple pages application, each page uses different script files, then you build different bundles, set up different watch tasks, the problem grows more than you can image, developers feel not quite comfortable.  

As we all know, since browser does not support synchronous require well, commonJS in the browser does not work well. On the other end, AMD works quite well in the browser, the asynchronous script loading feature really fascinates developers, the codes developers edit and debug are the same as what browser loads, and for multiple page application, AMD can asynchronously load different script files as needed, the development experience is the same as in nodejs or some others.  

However, AMD is also not perfect, like not simple modular definition as CommonJS, and the messy configuration for using a third-party libray, the only key point of AMD is the feature of asynchronous script loading.  

## asynchronous script loading
When you write modular codes, set up the main file, and the asynchronous script loader will analyze the dependencies, load the script files, and execute the module, the development experience with asynchronous script loading is simple, easy and comfortable.  
Therefore, what about `browserify with asynchronous script loading` ? Sounds cool, reallly ?  
The approach is that using browserify to resolve modules from npm and using asynchronous script loading to write application level codes.  
To achieve the above goal, there's now another choice not just the way that AMD provides.  
The choice is that we can now use `dependency injection with asynchronous script loading`.  

## dependency injection
CommonJS and AMD actually both implements the same design pattern named `service locator`, in service locator developers call the `require` or `define` function to ask explicitly for the dependency from the locator, the locator then feeds the dependency module back, this pattern is simple and easy. `Dependency injection`, however on the other end, components do not look up, they provide plain simple configuration metadata enabling the container to resolve dependencies. The container is wholly responsible for wiring up components, passing resolved objects into JavaScript Object properties or constructors.  Hence the inversion of control.  

`Service locator` and `dependency injection` are both ways to resolve dependencies and enable modular codes, there is no golden rule on which is better, it all depends. Basically, when you write to quick and easy development, like library、 shell、 tools, you may choose to use `service locator`. When you want to write project that needed be continuously maintainable, you may choose to use `dependency injection`. What's more, `service locator` and `dependency injection` can be used together to take advantages of both.   

Dependency injection needs a dependency injection container or IoC container to make it work. A good dependency injection container should have the following features:  
* non-invasive, use configuration instead of container api
* code over configuration, use code embeded DSL or some syntax sugars
* implements asynchronous script loading, since container knows the dependencies
* shareable codes frontend and backend without any modifications
* implements other feature based on the IoC container, like AOP or codes hot reload

these are what bearcat really do.  
[bearcat](http://bearcatjs.org/) is still a young but promising project, it heavilly needs your contributions.  

## bearcat
bearcat is focused on writing small javaScripts, but building big world. The world is connected through bearcat's powerful dependency injection and Aspect Oriented Programming(AOP). Codes are shareable, configurations are javaScript objects enhanced by themselves, dependencies are auto-resolved, scripts are asynchronously loaded if needed.  

a quick bearcat example using dependency injection  

just suppose a system needs a `car`, then the `car` must have an `engine` so that it can run, so you write the following codes:  

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

as we can see, the above codes are actually plain, old javaScript objects, the only difference is that there are `$` prefixed properties. In bearcat, these properties are actually configurations that tell the IoC container how to resolve the dependencies, the lifecycle hooks and so on. Therefore, these javaScript objects are magic, self-described javaScript objects that have the power to build up elastic, maintainable front-backend javaScript applications.  

let's see in detail about the above codes:  
* use `$id` property to define the unique id in the IoC container
* use `$xxId` to tell the IoC container that it needs a dependency with the id of `xxId`
in this example, car needs a dependency of engine so that it just add `$engine` property
* use `bearcat.module()` to register the `module` into the IoC container  
`typeof module !== 'undefined' ? module : {}` this code is used to be compatible with frontend and backend  
if you just use in the frontend, you can simply use `bearcat.module(Car);`  
if you just use in the backend(nodejs), you can simply use `module.exports = Car;`

start the IoC container  

in frontend  
```
<script src="./lib/bearcat.js"></script>
<script src="./bearcat-bootstrap.js"></script>
<script type="text/javascript">
bearcat.createApp();   // create app to init 
bearcat.use(['car']);  // javaScript objects needed to be used
bearcat.start(function() {
    // when this callback invoked, everything is ready
    var car = bearcat.getBean('car');
    car.run(); 
});
```

use `bearcat.use(['car']);` to specify that in current page, needs the car as the main module, then bearcat will load the `car.js` script file, analyze the dependency in `car`, then it knows `car` needs a dependency of `engine`, then it asynchronously load the `engine.js` script file, and then inject the `engine` instance into the `car` instance, when all is done, fire the `bearcat.start()` callback, and in the callback, everything is ready, you can now get the `car` to run.  

in backend(nodejs)  
```
var bearcat = require('bearcat');
var contextPath = require.resolve('./context.json');
global.bearcat = bearcat; // make bearcat global, for `bearcat.module()`
bearcat.createApp([contextPath]);
bearcat.start(function() {
  var car = bearcat.getBean('car'); // get car
  car.run(); // call the method
});
```

in nodejs environment, there are no need to use `bearcat.use`, it can use synchronous require through file I/O, so just pass the `context.json` file path into the bearcat container, bearcat will do the rest things, resolve the dependencies and wire all the modules up ready for you to call.  

the full codes repo [10-secondes-example](https://github.com/bearcatjs/bearcat-examples/tree/master/10-seconds-example)

## bearcat + browserify
* bearcat -- the ability of dependency injection with asynchronous script loading makes development quite nature and easy
* browserify -- the ability of reuse the increasing npm modules without much pains

therefore, use bearcat to write application level codes and use browserify to resolve third-party library can be a great choice for frontend development.  

here comes with a simple example, a simple markdwon editor using bearcat and browserify  

To make a bridge between bearcat and browserify, we need to use a module file `requireUtil`(for example)  

requireUtil.js  
``` js
var RequireUtil = function() {
    this.$id = "requireUtil";
    this.$init = "init";  // enable init lifecycle hook
    this.brace = null;
    this.marked = null;
}
    
RequireUtil.prototype.init = function() {
    this.brace = require('brace');
    this.marked = require('marked');
}
     
bearcat.module(RequireUtil, typeof module !== 'undefined' ? module : {});
```

in this module script, we can use browserify provided `require` ability to resolve third-party library like `brace`, `marked` and then we should register it into the bearcat IoC container  

then in your application level codes, you can write a `markDownController`(for example)  

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

in markDownController, just inject the `requireUtil` into it through `$requireUtil` property, so that you can now third-party library that browserify resolved, and because this code is loaded through bearcat asynchronously script loading, the source code is the same as the browser loaded, edit and debug will be quite nature and easy, you can set up a debugger as you like, just enjoy with it.  

the whole demo can be found on [markdown-editor](http://bearcatjs.org/examples/markdown-editor.html)

## Conclusion
frontend javaScript dependency management is still on the way, there are lots of approaches.  
Take care of your business, and coding as you like.  
bearcat with browserify, just try and enjoy with it ~_~  

## Read More
* [bearcat](http://bearcatjs.org/)
* [browserify](http://browserify.org/)
* [asynchronous frontend dependency management without AMD](http://bearcatjs.org/2014/12/24/asynchronous-frontend-dependency-management-without-AMD/)