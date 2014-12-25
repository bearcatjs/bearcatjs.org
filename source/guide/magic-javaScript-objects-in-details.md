title: Magic javaScript object in detail
type: guide
order: 6
---

## Overview 
Configuration metadata contains a lot of configuration information, including constructor arguments, property values, and container-specific information such as initialization method, static factory method name, and so on.  

## Configuration Style
In Bearcat, configuration metadatas are recommended to write Magic, self-described javaScript objects. Howerver, for some history reason, it can be written in JSON-style configuration file like context.json for example, or it can be written in the code file with simple javaScript objects. The only difference between these two styles is that code-based meta's ***func*** attribute must be ***Function*** specified by the constructor function of the bean, and the configuration-file-based meta's ***func*** attribute is a ***String*** to specify the relative location of node.js file path that contains the constructor function.  

magic javaScript objects  
car.js 
``` js
var Car = function() {
    this.$id = "car"; // id car
}
  
Car.prototype.run = function() {
    console.log('run car...');
    return 'car';
}
  
module.exports = Car;
```

code-based meta  
car.js
``` js
var Car = function() {}

Car.prototype.run = function() {
    console.log('run car...');
    return 'car';
}

// func is the constructor function
module.exports = {
    id: "car",
    func: Car
};
```

configuration-file-based meta  
car.js  
``` js
var Car = function() {}

Car.prototype.run = function() {
    console.log('run car...');
    return 'car';
}

module.exports = Car;
```

context.json
``` js
{
    "name": "simple",
    "beans": [{
      "id": "car",
      "func": "car"
    }]
}
```

## Configuration attribute

### Bean attribute
Bean attribute will be wrapped into a [BeanDefinition](https://github.com/bearcatjs/bearcat/blob/master/lib/beans/support/beanDefinition.js) object.  

* id : the unique bean name in the current container, for container to lookup  
* func : the constructor function for the bean  
* order : the order of instantiation when it is a singleton bean  
* init : init method which will be invoked after constructor function, init can be async  
* destroy : destroy method which will be invoked when the container gracefully shutdown, beans need to be destroyed  
* factoryBean : the name of the factory bean for the bean's instantiation  
* factoryMethod : the factory method of the factory bean  
* scope : scope can be [singleton](/guide/dependency-injection.html#The_singleton_scope) or [prototype](/guide/dependency-injection.html#The_prototype_scope), by default it is singleton  
* async : specify whether the init method is async or not, by default it is false  
* abstract : specify a bean to be abstract, do not need to be instantiated, by default it is false   
* parent : specify the inheritance relationship between beans, the child bean will inherit the method in parent bean's prototype that child bean does not have, the value is the parent bean id   
* lazy : specify whether current bean do not need to be preInstantiated, it will be instantiated when requested by the container, by default it is false  
* args : the arguments dependency injection, it is an array, all of its elements will be wrapped into a [BeanWrapper](https://github.com/bearcatjs/bearcat/blob/master/lib/beans/support/beanWrapper.js), it has the following attributes  
  - name : the name of the dependency injection element  
  - type : when type is specified, it is a var dependency injection, you can pass argument into the ***getBean*** function  
  - value : the value to be injected  
  - ref : the name of the bean to be injected in the current container  
* props : the properties dependency injection, it is the same as args
* factoryArgs : the factory arguments dependency injection, it is the same as args    
* proxy : specify whether the bean need to be proxied or not, by default it is true. Proxy is needed when the bean can be intercepted by an AOP advice, however when the bean is infrastructural, it is unnecessary to be proxied.    
* aop : to specify the bean is an ***aspect*** that defines pointcut and advice, it is an array.  
  - pointcut : defines the pointcut expression  
  - advice : defines the advice method matches the pointcut
  - runtime : set to true to specify that target method arguments will be passed to this advice  