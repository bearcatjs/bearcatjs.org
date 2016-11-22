title: Getting Started
type: guide
order: 2
---

## Introduction

Bearcat is a front-backend javaScript framework that enables developers to write magical, self-describing javaScript objects, to build up elastic, maintainable front-backend Javascript applications. It provides the backbone infrastructure to manage business objects so that developers can focus on application-level business logic.  

Bearcat is focused on writing small Javascripts files, which together make a big world. The world is connected through bearcat's powerful dependency injection and Aspect Oriented Programming(AOP).  

Little or no configuration is required to make it work. The configuration meta-data is described by javaScript objects themselves.  

Unlike other front-backend dependency management, bearcat does not use 'define', 'require', 'exports' to resolve dependencies. Everything is made up of pure Javascript objects. As a result, code is easy to re-use  between frontend (browser) and backend (nodejs) without any modifications or having to build up a bundle to make it work.  

Frontend dependency management with bearcat is asynchronously loaded: every page can use different script files. Development is easier: what you see is what you get, there is no need to build up a bundle and find out the source file when something goes wrong.  

So keep reading and give it a try.

## Concepts Overview

### Magic JavaScript Objects
JavaScript Object can be magic, it not only has properties and methods, but also can describe themselves through some DSL or syntax sugar. In bearcat, the syntax sugar is '$' character. So magic javaScript Object can be like this.  

```js
var MagicJsObject = function() {
  this.$id = "magicJsObject";
}
  
MagicJsObject.prototype.doMethod = function() {
  
}
```

It is a simple function Object, but has a property and the property is prefixed with '$'  

```js
this.$id = "magicJsObject";
```

This program describes itself with an id named 'magicJsObject', with this id bearcat knows this `guy`, when someone else ask the dependency for this `guy`, bearcat will automatically wire it up for you.  

### Dependency Injection

Inversion of Control (IoC) is a design pattern that addresses a component's dependency resolution, configuration and lifecycle. IoC is best understood through the Hollywood Principle: "Don't call us, we'll call you". Bearcat implements IoC with dependency injection (DI). That is, components do not look up, they provide plain simple configuration metadata enabling the container to resolve dependencies. The container is wholly responsible for wiring up components, passing resolved objects into JavaScript Object properties or constructors.  

### Aspect Object Programming
Aspect-Oriented Programming (AOP) complements Object-Oriented Programming (OOP) by providing another way of thinking about program structure. The key unit of modularity in OOP is the class, whereas in AOP the unit of modularity is the aspect. Aspects enable the modularization of concerns such as transaction management that cut across multiple types and objects. (Such concerns are often termed crosscutting concerns in AOP literature.) 

### Consistent configuration

In Node.js development, it is common that there are serveral envrionments like development, test, production and so. Corresponding to these envrioments are configurations differed from each other. Therefore, it is necessary to make these configuration consistently.  

## A Quick Example

Writing simple javaScript objects, and put these files into a directory named `app` for bearcat to scan    

car.js  
``` js
var Car = function() {
  this.$id = "car";
  this.$wheel = null;
  this.$engine = null;
}  
  
Car.prototype.run = function() {
  this.$wheel.run();
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

wheel.js
``` js
var Wheel = function() {
  this.$id = "wheel";
}  
  
Wheel.prototype.run = function() {
  console.log('run wheel...');
}  
  
bearcat.module(Wheel, typeof module !== 'undefined' ? module : {});
```

above codes show that car has the dependencies with `engine` and `wheel`, car uses `this.$wheel` to resolve `wheel`, uses `this.$engine` to resolve `engine`  

all codes use `bearcat.module` to register into bearcat, it is frontend and backend compatible.  

then add simple configuration file `context.json` to specify the scan directory path  

context.json  
``` json
{
  "name": "bearcat-simple-example",
  "scan": ["app"]
}
```

wire codes up, let them go  

### frontend browser  
index.html
```
<!DOCTYPE html>
<html lang="en-us">
  <head>
    <title>bearcat browser examples</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
  </head>
  <body>
    <h2>bearcat simple example</h2>
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
    </script>
  </body>
</html>
```

`bearcat-bootstrap.js` will be auto generated for you, it is used for bearcat to know where the javaScript objects is, and then load them asynchronously. More details for bearcat-bootstrap.js can be referred to [bearcat-bootstrap.js part](/guide/bearcat-bootstrap.html)   

### backend nodejs
app.js
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

as you can see, nodejs has the ability to load file synchronously, there's no bearcat-bootstrap.js file needed, just pass 'context.json' file path, bearcat will analyse, inject, connect javaScript objects ready for you.  

The whole repository can be found [bearcat-quick-example](https://github.com/bearcatjs/bearcat-examples), enjoy with it.  
