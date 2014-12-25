title: Aspect Object Programming
type: guide
order: 4
---

## Introduction
Aspect-Oriented Programming (AOP) complements Object-Oriented Programming (OOP) by providing another way of thinking about program structure. The key unit of modularity in OOP is the class, whereas in AOP the unit of modularity is the aspect. Aspects enable the modularization of concerns such as transaction management that cut across multiple types and objects. (Such concerns are often termed crosscutting concerns in AOP literature)  

## AOP concepts
* Aspect: a modularization of a concern that cuts across multiple classes. Transaction management is a good example of a crosscutting concern in enterprise Node.js applications.  
* Join point: a point during the execution of a program, such as the execution of a method or the handling of an exception.  
* Advice: action taken by an aspect at a particular join point. Different types of advice include "around",  "before" and "after" advice.   
* Pointcut: a predicate that matches join points. Advice is associated with a pointcut expression and runs at any join point matched by the pointcut (for example, the execution of a method with a certain name).   
* Target object: object being advised by one or more aspects.  
* AOP proxy: an object created by the AOP framework in order to implement the aspect contracts (advise method executions and so on).  
* Weaving: linking aspects with other application types or objects to create an advised object.  

Types of advice:  
* Before advice: Advice that executes before a join point  
* After returning advice: Advice to be executed after a join point completes normally  
* After throwing advice: Advice to be executed if a method exits by throwing an exception.  
* Around advice: Advice that surrounds a join point such as a method invocation. This is the most powerful kind of advice. Around advice can perform custom behavior before and after the method invocation. It is also responsible for choosing whether to proceed to the join point or to shortcut the advised method execution by returning its own return value or throwing an exception.  

Bearcat supports ***Before advice***, ***After returning advice*** and ***Around advice***, since throwing an exception is not a best practise in Node.js.

## Declaring an aspect
In Bearcat, an aspect is also a simple javaScript object, it is treated the same as other javaScript objects managed by Bearcat, so you can inject other beans into an aspect quite easily.  
In an aspect, you should define advices, you can refer to [declaring an advice part](#Declaring_an_advice)  

## Declaring an advice
advice is a function in an aspect, advice function's last argument must be a ***next*** callback function to tell the AOP framework the end of the current advice execution.   
In configuration metadata, you can use the ***advice*** attribute to specify the name of the advice in the current aspect.   
```
"advice": "doBefore"
```

### Before advice
``` js
Aspect.prototype.doBefore = function(next) {
    console.log('Aspect doBefore');
    next();
}
```

### After advice
after advice is equal to after returning advice in Bearcat.  
the joint point method execution callback return arguments will be passed to after advice.  
``` js
Aspect.prototype.doAfter = function(err, r, next) {
    console.log('Aspect doAfter ' + r);
    next();
}
```

### Around advice
in around advice, target object and target method will be passed as arguments.  
``` js
Aspect.prototype.doAround = function(target, method, next) {
    console.log('Aspect doAround before');
    target[method](function(err, r) {
	    console.log('Aspect doAround after ' + r);
	    next(err, r + 100);
    });
}
```

## Declaring a pointcut
Recall that pointcuts determine join points of interest, and thus enable us to control when advice executes. In Bearcat, a pointcut declaration has two parts: a prefix declaring the type of advice, and a pointcut expression that determines exactly which method executions we are interested in.  
Pointcut is declared in configuration metadata under the ***pointcut*** attribute  
```
"pointcut": "before:.*?runBefore"
```

the prefix should be ***before***, ***after*** and ***around*** corresponding to before advice, after advice and around advice.  

after the prefix it is a ***:*** separator.  

after the separator, it is the pointcut expression which matches the target method  
the pointcut expression is actually a regexp expression  
the target method has the following signature:  
```
id.method
```
***id*** is the bean id of the target  
***method*** is the method name of the target  

therefore, when target object is a bean named with id ***car*** and has the method named ***runBefore***  
the following pointcut expression will matches:  
```
"pointcut": "before:.*?runBefore"
```

## Runtime support
when an advice is defined to be runtime, target method arguments will be passed to this advice.  
***before advice*** and ***around advice*** can be defined to be runtime, while ***after advice*** is actually runtime.  
To use this feature, you can use the ***runtime*** attribute and set to be true  
```
"runtime": true
```

### before advice (runtime)
``` js
Aspect.prototype.doBeforeRuntime = function(num, next) {
    console.log('Aspect doBeforeRuntime ' + num);
    next();
}
``` 

### around advice (runtime)
``` js
Aspect.prototype.doAroundRuntime = function(target, method, num, next) {
    console.log('Aspect doAroundRuntime before ' + num);
    target[method](num, function(err, r) {
        console.log('Aspect doAroundRuntime after ' + r);
	    next(err, r + 100);
    });
}
```

## Embeded aspect configuration metas  
Aspect is also a bean, to enable $ annotation, needs to configure in constructor as follows:  
```
this.$aop = true;
```

Every method in Aspect's prototype can be an advice, to be an advice, you just declare the pointcut like this:  
```
var $pointcut = "pointcut expression";
```

order, runtime can also be declared as follows:  
```
var $order = 1;
var $runtime = true;
```

a simple aspect example  
``` js
var Aspect = function() {
    this.$id = "aspect";
    this.$aop = true;
}
  
Aspect.prototype.doBefore = function(next) {
    var $pointcut = "before:.*?runBefore";
    var $order = 10;

    console.log('Aspect doBefore');
    next();
}
  
module.exports = Aspect;
```

[aop_annoation examples](https://github.com/bearcatjs/bearcat/tree/master/examples/aop_annotation)