title: "bearcat api"
type: api
order: 1
---

## createApp 

The `createApp` is the core of bearcat. It is a factory constructor function that allows you to create bearcat instance.

 * @param  {Array}  configLocations context path array
 * @param  {Object} opts
 * @param  {String} opts.NODE_ENV            setup env
 * @param  {String} opts.BEARCAT_ENV         setup env
 * @param  {String} opts.NODE_CPATH          setup config path
 * @param  {String} opts.BEARCAT_CPATH       setup config path
 * @param  {String} opts.BEARCAT_LOGGER      setup 'off' to turn off bearcat logger configuration
 * @param  {String} opts.BEARCAT_HOT         setup 'off' to turn off bearcat hot code reloading
 * @param  {String} opts.BEARCAT_ANNOTATION  setup 'off' to turn off bearcat $ based annotation
 * @param  {String} opts.BEARCAT_GLOBAL  	 setup bearcat to be global object
 * @return {Object} bearcat object
 * @api public

 ## start 

start bearcat app  

 * @param  {Function} cb start callback function
 * @api public

 ## stop

stop bearcat app, it will stop internal applicationContext, destroy all singletonBeans

 * @api public

## use

add async loading beans, this just add beans needed to be loaded to bearcat.

examples:  
```
bearcat.use(['car']);
bearcat.use('car');
```

 * @param  {Array|String} async loading beans id
 * @api public

## async

async loading beans

examples:  
```js
bearcat.async(['car'], function(car) {
  // car is ready
});
```

 * @param  {Array|String} async loading beans id
 * @return {Function}     callback with loaded bean instances
 * @api public

## module

register module(bean) to IoC container through $ based self-described function.

examples:
``` js
bearcat.module(function() {
    this.$id = "car";
    this.$scope = "prototype";
});
```

* @param  {Function} func $ annotation function
* @api public

## getBean

get bean from IoC container through beanName or meta argument.

examples:
``` js
 // through beanName
 var car = bearcat.getBean("car");

 // through meta
 var car = bearcat.getBean({
    id: "car",
    func: Car // Car is a function constructor
 });

 // through $ annotation func
 var car = bearcat.getBean(function() {
    this.$id = "car";
    this.$scope = "prototype";
 });
```

 * @param  {String} beanName
 * @return {Object} bean
 * @api public

 ## getRoute

 convenient function for using in MVC route mapping.

 examples:  
 ``` js
 // express
 var app = express();
 app.get('/', bearcat.getRoute('bearController', 'index'));
 ```

 * @param  {String} beanName
 * @param  {String} fnName routeName
 * @api public

 ## getFunction

 get bean constructor function from IoC container through beanName.

 examples:  
 ``` js
 // through beanName
 var Car = bearcat.getFunction("car");
 ```

 * @param  {String}   beanName
 * @return {Function} bean constructor function
 * @api public
 
 ## getBeanByFunc

 get bean from IoC container through $ annotation function.

 examples:  
 ``` js
 bearcat.getBeanByFunc(function() {
    this.$id = "car";
    this.$scope = "prototype";
 });
 ```

 * @param  {Function} func $ annotation function
 * @api public

 ## getBeanByMeta

 get bean from IoC container through meta argument.

 examples:  
 ``` js
 bearcat.getBeanByMeta({
    id: "car",
    func: Car // Car is a function constructor
 });
 ```

 * @param  {Object} meta meta object
 * @api public