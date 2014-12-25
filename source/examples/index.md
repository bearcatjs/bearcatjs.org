title: multipage
type: examples
order: 0
---

<iframe width="100%" height="300" src="bearcat-examples/example-multipage/car_BMW.html" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

this example shows two pages, each page asynchronously loads different script files  

when in BMW page, it uses `bmwCarController`, which requires `bmwCar`  

bmwCarController.js
``` js
var BmwCarController = function() {
    this.$id = "bmwCarController";
    this.$bmwCar = null;
}
  
BmwCarController.prototype.run = function() {
    this.$bmwCar.run();
}
  
bearcat.module(BmwCarController, typeof module !== 'undefined' ? module : {});
```

`bmwCar` requires `bmwEngine` and `bmwWheel`  

bmwCar.js
``` js
var BmwCar = function() {
    this.$id = "bmwCar";
    this.$bmwEngine = null;
    this.$bmwWheel = null;
    this.$printUtil = null;
}
  
BmwCar.prototype.run = function() {
    this.$bmwEngine.start();
    this.$bmwWheel.run();
    var msg = 'bmwCar run...';
    console.log(msg);
    this.$printUtil.printResult(msg);
}
  
bearcat.module(BmwCar, typeof module !== 'undefined' ? module : {});
```

wire them up with bearcat  
``` html
<script src="./lib/bearcat.js"></script>
<script src="./bearcat-bootstrap.js"></script>
<script type="text/javascript">
bearcat.createApp();
bearcat.use(['bmwCarController']);
bearcat.start(function() {
    var bmwCarController = bearcat.getBean('bmwCarController');
    bmwCarController.run();
});
</script>
```

the whole source sources can be found on [example-multipage](https://github.com/bearcatjs/bearcat-examples/tree/master/example-multipage)