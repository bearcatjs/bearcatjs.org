title: Dependency injection 
type: guide
order: 3
---

## Container Overview
Inversion of Control (IoC) is a design pattern that addresses a component's dependency resolution, configuration and lifecycle. IoC is best understood through the Hollywood Principle: "Dont's call us, we'll call you". Bearcat implements IoC with dependency injection (DI). That is components do not look up, they provide plain simple configuration metadata enabling the container to resolve dependencies. The container is wholly responsible for wiring up components, passing resolved objects into JavaScript Object properties or constructors. Bearcat implements the container with basic ***beanFactory*** and high-level ***applicationContext***

## Configuration metadata
Configuration metadata is the key point for developers to tell the Bearcat container to instantiate, configure, and assemble the objects in your application.  
In bearcat, configuration metadata is embeded into javaScript objects with some syntax sugars as showed below.   

``` js
var JsObject = function() {
    this.$id = "jsObject";
}
  
bearcat.module(JsObject, typeof module !== 'undefined' ? module : {});
```

These javaScript objects also called ***bean*** as a nick or for short.    

The ***$id*** property with its value is a string that you use to indentify the individual bean definition. The ***JsObject***  is a function defines the constructor function for this bean, which will be registered to bearcat through bearcat api (for frontend browser) or just using 'module.exports' (for backend nodejs).  
``` js
bearcat.module(JsObject, typeof module !== 'undefined' ? module : {});
```

this code will be frontend and backend compatible.  

``` js
bearcat.module(Function, Module);
```

``` js
var JsObject = function() {
    this.$id = "jsObject";
}
  
module.exports = JsObject;
```

## Instantiating a container
Instantiating a Bearcat IoC container is straightforward. Just pass the ***context.json*** defined paths to ***bearcat.createApp*** factory function (for backend nodejs) or use auto-generated ***bearcat-bootstrap.js*** (for frontend browser).  

### frontend browser
``` html
<script src="./lib/bearcat.js"></script>
<script src="./bearcat-bootstrap.js"></script>
<script type="text/javascript">
bearcat.createApp();
bearcat.start(function() {
    console.log('bearcat IoC container started');
});
```

### backend nodejs
``` js
var bearcat = require('bearcat');
var configPaths = ['path/to/context.json'];

bearcat.createApp(configPaths);
bearcat.start(function() {
    console.log('bearcat IoC container started');
});
```

## Using the container
When container started, you just use ***getBean*** method to retrieve instances of your beans.  
``` js
var bearcat = require('bearcat');
var configPaths = ['path/to/context.json'];

bearcat.createApp(configPaths);
bearcat.start(function() {
    console.log('bearcat IoC container started');
    var dog = bearcat.getBean('dog');
    dog.bite(); // call bite method
});
```

## Bean overview
simple javaScript objects managed in bearcat IoC container are called ***Beans***. These beans are created with the configuration metadata that you supply to the container.  

## Instantiating beans
A bean definition essentially is a recipe for creating one or more objects. The container looks at the recipe for a named bean when asked, and uses the configuration metadata encapsulated by that bean definition to create (or acquire) an actual object.  

### Instantiation with a constructor
In Bearcat, instantiation with a constructor is quite easy, with self-described configuration metadata you can specify your bean class as follows:  
``` js
var Bean = function() {
    this.$id = "beanId";
}
  
module.exports = Bean;
```

### Instantiation using an instance factory method
To use this mechanism, add the ***factoryBean*** attribute, specify the name of a bean in the current container and the instance method that is to be invoked to create the Object. Set the name of the factory method itself with the ***factoryMethod*** attribute.  
``` js
var Car = function() {
    this.$id = "car";
    this.$factoryBean = "carFactory";
    this.$factoryMethod = "createCar";
}
  
module.exports = Car;
```

carFactory.js
``` js
var Car = require('./car');

var CarFactory = function() {
    this.$id = "carFactory";
}
  
CarFactory.prototype.createCar = function() {
    console.log('CarFactory createCar...');
    return new Car();
}
  
module.exports = CarFactory;
```

### Lazy-initialized beans  
By default, ApplicationContext implementations eagerly create and configure all singleton beans as part of the initialization process. Generally, this pre-instantiation is desirable, because errors in the configuration or surrounding environment are discovered immediately, as opposed to hours or even days later. When this behavior is not desirable, you can prevent pre-instantiation of a singleton bean by marking the bean definition as lazy-initialized. A lazy-initialized bean tells the IoC container to create a bean instance when it is first requested, rather than at startup.  

This behavior is controlled by the ***$lazy*** attribute, for example:  
context.json
``` js
var Car = function() {
    this.$id = "car";
    this.$lazy = true;
}
  
module.exports = Car;
```

## Dependencies
Dependency injection (DI) is a process whereby objects define their dependencies, that is, the other objects they work with, only through constructor arguments, arguments to a factory method, or properties that are set on the object instance after it is constructed or returned from a factory method. The container then injects those dependencies when it creates the bean. This process is fundamentally the inverse, hence the name Inversion of Control (IoC), of the bean itself controlling the instantiation or location of its dependencies on its own by using direct construction of classes, or the Service Locator pattern.  
Code is cleaner with the DI principle and decoupling is more effective when objects are provided with their dependencies. The object does not look up its dependencies, and does not know the location or class of the dependencies. As such, your classes become easier to test, in particular when the dependencies are on interfaces or abstract base classes, which allow for stub or mock implementations to be used in unit tests.  

DI exists in two major variants, [Constructor-based dependency injection](#Constructor-based_dependency_injection) and [Properties-based dependency injection](#Properties-based_dependency_injection).  

### Constructor-based dependency injection
Constructor-based DI is accomplished by the container invoking a constructor with a number of arguments, each representing a dependency.  
car.js
``` js
// the Car has a dependency on an Engine
// a constructor so that the Bearcat container can inject an Engine
var Car = function($engine) {
    this.$id = "car";
    this.$engine = $engine;
}
  
Car.prototype.run = function() {
    console.log('run car...');
    this.$engine.run();
}
  
module.exports = Car;
```

engine.js
``` js
var Engine = function() {
    this.$id = "engine";
}
  
Engine.prototype.run = function() {
    console.log('run engine...');
}
  
module.exports = Engine;
```

Besides inject a bean into the constructor, you can specify to inject ***variable*** into the constructor.  

inject ***variable*** example:  

car.js  
``` js
var Car = function(num) {
    this.$id = "car";
    this.$Tnum = num;
}
  
Car.prototype.run = function() {
    console.log('run car...');
    return 'car ' + this.$Tnum;
}
  
module.exports = Car;
```

main.js
``` js
var car = bearcat.getBean('car', 100);
car.run(); // car 100
``` 

use the attribute with the prefix ***$T*** to specify the ***variable*** to be injected into the constructor with the argument named ***num***  

main.js
``` js
var car = bearcat.getBean('car', 100);
car.run(); // car 100
``` 

### Properties-based dependency injection
Properties-based DI is accomplished by the container setting properties dynamicly.  
car.js
``` js
// the Car has a dependency on an Engine
// in constructor specify the engine properties to null for V8 optimization
var Car = function() {
    this.$id = "car";
    this.$engine = null;
}
  
Car.prototype.run = function() {
    console.log('run car...');
    this.$engine.run();
}
  
module.exports = Car;
```

engine.js
``` js
var Engine = function() {
    this.$id = "engine";
}
  
Engine.prototype.run = function() {
    console.log('run engine...');
}
  
module.exports = Engine;
```

you can also specify to inject ***value*** into the properties from configuration files for example.  

inject value example:  
car.js  
``` js
var Car = function() {
    this.$id = "car";
    this.$Vnum = "{car.num}";
}
  
Car.prototype.run = function() {
    console.log('run car...');
    return 'car ' + this.$Vnum;
}
  
module.exports = Car;
```

car.json  
``` js
{
    "car.num": 100
}
```

main.js
``` js
var car = bearcat.getBean('car');
car.run(); // car 100
``` 

Note: there is no need for Properties-based dependency injection to inject ***variable*** type into the properties  

## Bean scopes
When you create a bean definition, you create a recipe for creating actual instances of the class defined by that bean definition. The idea that a bean definition is a recipe is important, because it means that, as with a class, you can create many object instances from a single recipe.  

You can control not only the various dependencies and configuration values that are to be plugged into an object that is created from a particular bean definition, but also the scope of the objects created from a particular bean definition.  

You can use ***scope*** attribute to specify the scope of the bean.  

### The singleton scope
Only one shared instance of a singleton bean is managed, and all requests for beans with an id or ids matching that bean definition result in that one specific bean instance being returned by the Bearcat container. The singleton beans will preInstantiate by default.  

By default, scope is singleton  
``` js
var Car = function() {
    this.$id = "car";
    this.$scope = "singleton"; // default, no need to set it up
}
  
module.exports = Car;
```

main.js
``` js
var car1 = bearcat.getBean('car');
var car2 = bearcat.getBean('car');
// car2 is exactly the same instance as car1
```

### The prototype scope
The non-singleton, prototype scope of bean deployment results in the creation of a new bean instance every time a request for that specific bean is made. That is, the bean is injected into another bean or you request it through a `getBean()` method call on the container. As a rule, use the prototype scope for all stateful beans and the singleton scope for stateless beans.  

``` js
var Car = function() {
    this.$id = "car";
    this.$scope = "prototype";
}
  
module.exports = Car;
```

main.js
``` js
var car1 = bearcat.getBean('car');
var car2 = bearcat.getBean('car');
// car2 is not the same instance as car1
```

## Customizing the nature of a bean
### Lifecycle callbacks
To interact with the container management of the bean lifecycle, you can add ***init*** and ***destroy*** method with the attribute ***init*** and ***destroy***.  

#### Initialization method
car.js
``` js
var Car = function() {
    this.$id = "car";
    this.$init = "init";
    this.num = 0;
}
  
Car.prototype.init = function() {
    console.log('init car...');
    this.num = 1;
    return 'init car';
}
  
Car.prototype.run = function() {
    console.log('run car...');
    return 'car ' + this.num;
}
  
module.exports = Car;
```

when car is requested by ***getBean*** invoke, init method will be called to do some init actions  

#### Destruction method
car.js
``` js
var Car = function() {
    this.$id = "car";
    this.$destroy = "destroy";
}
  
Car.prototype.destroy = function() {
    console.log('destroy car...');
    return 'destroy car';
}
  
Car.prototype.run = function() {
    console.log('run car...');
    return 'car';
}
  
module.exports = Car;
```

when the container is ready to stop, beans in the container will call ***destroy*** method if setted.  

#### Async Initialization method
In nodejs, almost everything is async, so async initialization is quite common.  
When async initialization is required, use the ***async*** attribute to specify a async initialization method and in the function method, call ***cb*** callback function to end the async init action.  
When multiple async initializations are required, use the ***order*** attribute to specify the order of the bean initialization.  

car.js
``` js
var Car = function() {
    this.$id = "car";
    this.$init = "init";
    this.$order = 2;
    this.num = 0;
}
  
Car.prototype.init = function() {
    console.log('init car...');
    this.num = 1;
    return 'init car';
}
  
Car.prototype.run = function() {
    console.log('run car...');
    return 'car ' + this.num;
}
  
module.exports = Car;
```

wheel.js
``` js
var Wheel = function() {
    this.$id = "wheel";
    this.$init = "init";
    this.$async = true;
    this.$order = 1;
}
  
Wheel.prototype.init = function(cb) {
    console.log('init wheel...');
    setTimeout(function() {
	    console.log('asyncInit setTimeout');
	    cb();
    }, 1000);
}
  
Wheel.prototype.run = function() {
    console.log('run wheel...');
    return 'wheel';
}
  
module.exports = Wheel;
```

in this example, wheel has an async initialization method and must be init before car, so besides set the ***async*** attribute to true, should set the ***order*** attribute to to smaller than the car.  

## Bean definition inheritance
A bean definition can contain a lot of configuration information, including constructor arguments, property values, and container-specific information such as initialization method, static factory method name, and so on. A child bean definition inherits configuration data from a parent definition. The child definition can override some values, or add others, as needed. Using parent and child bean definitions can save a lot of typing. Effectively, this is a form of templating.  

In Bearcat, use the ***parent*** to specify the parent bean to inherit the bean definition.  
Besides bean definition inheritance, child bean will inherit methods from parent bean prototype which it does not have  

bus.js
``` js
var Bus = function(engine, wheel, num) {
    this.engine = engine;
    this.wheel = wheel;
    this.num = num;
}
  
Bus.prototype.run = function() {
    return 'bus ' + this.num;
}
  
module.exports = {
    func: Bus,
    id: "bus",
    parent: "car",
    args: [{
   	    name: "engine",
	    ref: "engine"
    }, {
	    name: "wheel",
	    ref: "wheel"
    }]
};
```

car.js
``` js
var n = 1;

var Car = function(engine, wheel, num) {
    this.engine = engine;
    this.wheel = wheel;
    this.num = num;
    n++;
};
  
Car.prototype.run = function() {
    this.engine.start();
    this.wheel.run();
    console.log(this.num);
}
  
module.exports = {
    func: Car,
    id: "car",
    args: [{
	    name: "engine",
	    ref: "engine"
    }, {
	    name: "num",
	    value: 100
    }, {
	    name: "wheel",
	    ref: "wheel"
    }],
    order: 1
};
```

in this example, bus has a parent bean car, and it will inherit the bean definition from car, therefore, bus has the num with value of 100 which is inherited from car.  

## Abstract bean
When a bean is marked as an abstract bean, it is usable only as a pure template bean definition that servers as a parent definition for child definitions. It is abstract and can not be initialized by ***getBean*** method, you can get the abstract bean constructor function by ***bearcat.getFunction*** method to handle child inherition. Similarly, the container’s internal preInstantiateSingletons() method ignores bean definitions that are defined as abstract.  

## Bean namespace
bean can have `namespace`, by default the namespace is null, all beans can be requested through unique `id`, when some beans specify to have a `namespace`, it must be requested by `namespace:id`  

the magic attribute for namespace is  
```
this.$Nid = "namespace:id";
```

in `context.json`, specify the `namespace` attribute to set up namespace, and in `beans` attribute, set up which beans have the namespace  
context.json
``` js
{
    "name": "beans",
    "namespace": "app",
    "scan": "",
    "beans": [{
        "id": "car",
        "func": "car"
    }]
}
```
you can refer to [context_namespace example](https://github.com/bearcatjs/bearcat/tree/master/examples/context_namespace) for more details

## Note
you can write $ based syntax sugars as you like, so the following is also ok  

``` js
var Car = function() {
    this.$id = "car";
    this["$engine"] = null; // use []
    var wheelName = "$wheel";
    this[wheelName] = null; // use variable
};
  
Car.prototype["$light"] = null; // use variable in prototype
  
Car.prototype.run = function() {
    this.$engine.run();
    this.$light.shine();
    this.$wheel.run();
    console.log('car run...');
}
  
module.exports = Car;
```

a full example can be found on [complex_function_annotation](https://github.com/bearcatjs/bearcat/tree/master/examples/complex_function_annotation)