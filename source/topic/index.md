title: "code hot reload"
type: topic
order: 1
---

## Overview
Node.js code hot reload can bring a lot of benifits, for example, you can hot update code in production, fix an emergency bug, change the logic of code. Especially when in a long connection service, restarting server will make users logout and then reconnect, it is bad for user experiences. However, by default, hot code reload is not supported in Node.js, because when doing hot reload, it is necessary to keep the reference of the objects, which may cause memory leak.  
Bearcat provides a way for hot reload code, of course, there are some limits, not all codes updated will be hot reloaded.    

## Theory
Bearcat hot reload is based on bearcat's powerful IoC container, to watch some events, when hot reload files changed, Bearcat will dynamically replace the updated POJO's prototype functions. Therefore, because objects are shared with the same ***prototype*** object, when dynamically update the prototype object, all objects will be hot updated, without any influence to the objects' private fields.

That is to say that what bearcat hot reload is actually the ***prototype*** functions, when you want to update a private field, it is not supported.   

## Enable hot reload

pass params to ***bearcat.createApp***  
```
bearcat.createApp([contextPath], {
	BEARCAT_HOT: 'on',
	BEARCAT_HPATH: 'setup your hot reload source path'
})
```

* BEARCAT_HOT: setup 'on' to turn on bearcat hot code reload
* BEARCAT_HPATH: setup hot reload path, usually it is the scan source directory(app by default)

## Watch directory
Bearcat will watch your application runtime source directory by default it is ***app***, when it'is updated, bearcat will do hot reload for the updated files  

app/car.js
```
var Car = function() {
	this.$id = "car";
}

Car.prototype.run = function() {
	console.log('run hot car...');
	return 'car hot';
}

module.exports = Car;
```

Because bearcat updates the ***prototype***, the updated files need to provide the updated bean's ***id*** and ***func***, to imply which bean need to be updated and the newest prototype function definitions.    

## reload events

listen to bearcat ***reload*** event, when watch codes changed, it will be fired  

```
bearcat.on('reload', function() {
	console.log('reload occured...');
});
```

## Note
* To change the default watch directory, you can start your app with ***hpath*** arguments to specify the hot reload watch directory

```  
node app hpath=xxx  
```

or

```
node app --hpath=xxx  
```

* Current verision of bearcat uses [chokidar](https://github.com/paulmillr/chokidar) to implement watching directory, therefore, you can update all files in the watch directory

* Avoid using gloal var in file, require by relative path when doing hot reload, because all of these are tightly coupled

* Some copy actions like ***bind***, ***concat*** will keep the reference, it will break the hot reload, for this concern you can listen ***reload*** event

## Examples
* [bearcat hot reload](https://github.com/bearcatjs/bearcat/tree/master/examples/hot_reload)

## Conclusion
* Loosely coupled system makes it easy to hot reload part of codes, Bearcat uses IoC to decouple the dependency of objects