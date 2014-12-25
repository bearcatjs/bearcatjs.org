title: clumsy-bird
type: examples
order: 2
---

<iframe width="100%" height="500" src="bearcat-examples/clumsy-bird/index.html" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

You must be familiar with flappy-bird, and that's the same as clumsy-bird, try to fly the bird and make bird alive as long as you can.  
Games are more complex than normal web applications, and need more about modular codes to make it simple and maintainable.  
This demo uses [melonjs](https://github.com/melonjs/melonJS) as the javaScript game engine, the official codes are writtern in sperate files that need to build up a bundle to work up for the browser. `melonjs` provides a lot of useful base class for developers to use, in `melonjs` the codes will mostly like this  

pipeEntity.js
``` js
var PipeEntity = me.ObjectEntity.extend({
    init: function(x, y) {
       // ...
	},
  
    update: function(dt) {
	   // ...
    }
});
```

extend a base class which `melonjs` provides, overrides the part you needed. Although codes are written in sperate files, `actually` they are in the `same` file. All variables are global, you need to take care of all of these. Besides, edit and debug is not quite attractive because you have to bundle files up whenever source codes changed...  

What about coding with bearcat ? Then you can write modular codes in `actual` sperate files and do not need to bundle up a file, bearcat will asynchronously load scirpt files for you ...  

To use bearcat, you can wrap the above code with a factory bean, whenever someone else need this `PipeEntity`, just get the instance through the factory contrustor. Factory beans are connected with bearcat's powerfull dependency injection.  

PipeEntityFactory.js
``` js
var PipeEntityFactory = function() {
    this.$id = "pipeEntity";
    this.$init = "init";
    this.ctor = null;
}
  
PipeEntityFactory.prototype.init = function() {
    this.ctor = me.ObjectEntity.extend({
	    init: function(x, y) {
		// ...
	    },
  
	    update: function(dt) {
		// ...
	    },
    });
}
  
PipeEntityFactory.prototype.get = function(x, y) {
    return new this.ctor(x, y);
}
  
bearcat.module(PipeEntityFactory, typeof module !== 'undefined' ? module : {});
```

then you want to create a pipe instance ? just inject the pipe factory into it  

game.js
``` js
var Game = function() {
    this.$id = "game";
    this.$pipeEntity = null;
}
  
Game.prototype.loaded = function() {
    var pipeEntity = this.$pipeEntity;
    me.pool.register("pipe", pipeEntity.ctor, true); // register pipeEntity construstor
}
  
bearcat.module(Game, typeof module !== 'undefined' ? module : {});
```

the whole sources can be found on [bearcat clumsy-bird](https://github.com/bearcatjs/bearcat-examples/tree/master/clumsy-bird)  
this exmaple is originally cloned from [ellisonleao clumsy-bird](https://github.com/ellisonleao/clumsy-bird), you can make a comparison  