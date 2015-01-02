title: javaScript 依赖管理
type: 博客
order: 1
---

### 概述
javaScript -- 目录最火热的语言，到处发着光芒, html5, hybrid apps, node.js, full-stack 等等。javaScript 从一个仅仅在浏览器上面的一个玩具语言，一转眼演变成无所不能神一般的存在。但是，由于天生存在着一点戏剧性（javaScript 据传说是在飞机上几天时间设计出来的），模块系统作为一门语言最基本的属性却是javaScript所缺的。 
让我们回到过去，通过 `<script>` 标签来编写管理 js 脚本的年代也历历在目，翻看现在的许多项目，还是能找到这样子的痕迹，但是随着项目规模的不断增长，js文件越来越多，需求的不断变更，让维护的程序员们越来越力不从心，怎么破？

### CommonJS
2009 ~ 2010 年间，[CommonJS](http://wiki.commonjs.org/wiki/CommonJS) 社区大牛云集，稍微了解点历史的同学都清楚，在同时间出现了 [nodejs](nodejs.org)，一下子让 javaScript 摇身一变，有了新的用武之地，同时在nodejs推动下的 CommonJS 模块系统也是逐渐深入人心。 
1：通过 require 就可以引入一个 module，一个module通过 exports 来导出对外暴露的属性接口，在一个module里面没有通过 exports 暴露出来的变量都是相对于module私有的  
2：module 的查找也有一定的策略，通过统一的 `package.json` 来进行 module 的依赖关系配置，require一个module只需要require package.json里面定义的name即可  

同时，nodejs也定义了一些系统内置的module方便进行开发，比如简单的http server    

``` js
var http = require('http');
http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello World\n');
}).listen(1337, '127.0.0.1');
console.log('Server running at http://127.0.0.1:1337/');
```

CommonJS 在nodejs带领下，风声水起，声明大噪，CommonJS 社区大牛们也就逐渐思考能否把在nodejs的这一套推向浏览器？  
理想很丰满，但是现实却是不尽如人意的  
一个最大的问题就是在浏览器加载脚本天生不支持同步的加载，无法通过文件I/O同步的require加载一个js脚本  
So what ? CommonJS 中逐渐分裂出了 [AMD](http://wiki.commonjs.org/wiki/Modules/AsynchronousDefinition)，这个在浏览器环境有很好支持的module规范，其中最有代表性的实现则是 [requirejs](http://requirejs.org/)  

### AMD
正如 AMD 介绍的那样： 
The Asynchronous Module Definition (AMD) API specifies a mechanism for defining modules such that the module and its dependencies can be asynchfanronously loaded. This is particularly well suited for the browser environment where synchronous loading of modules incurs performance, usability, debugging, and cross-domain access problems.  

翻译过来就是说：异步模块规范 API 定义了一种模块机制，这种机制下，模块和它的依赖可以异步的加载。这个非常适合于浏览器环境，因为同步的加载模块会对性能，可用性，debug调试，跨域访问产生问题。

确实，在浏览器环境下，AMD有着自己独特的优势：  
由于源码和浏览器加载的一致，所见即所得，代码编写和debug非常方便。尤其是在多页面的web项目下，不同页面的脚本js都是根据依赖关系异步按需加载的，不用手动处理每个页面加载js脚本的情况。  

但是，AMD 有一个不得不承认的作为一个module system的不足之处  
请问？在 AMD(requireJS)里面怎么使用一个第三方库的？  

一般都会经历这么几个步骤： 
* 使用的第三方库不想成为 global 的，只有引用的地方才可见
* 需要的库支不支持 AMD ？
* 不支持 AMD，我需要 fork 提个 patch 吗？
* 支持AMD，我的项目根路径在哪儿？库在哪儿？
* 不想要使用库的全部，要不要配置个 shim？
* 需不需要配置个 alias ？

一个库就需要问这么些个问题，而且都是`人工手动的操作`  
最最关键的问题是你辛辛苦苦搞定的配置项都是相对于你当前项目的  
当你想用在其他项目或者是单元测试，那么OK，你还得修改一下  
因为，你相对的是当前项目的根路径，一旦根路径发生改变，一切都发生了变化  

requireJS 使用之前必须配置，同时该配置很难***重用***

相比较于 CommonJS 里面如果要使用一个第三方库的话，仅仅只需要在 package.json 里面配置一下 库名和版本号，然后npm install一下之后就可以直接 require 使用的方式，AMD 的处理简直弱爆了 !!!

对于 AMD 的这个不足之处，又有社区大神提出了可以在 browser 运行的 CommonJS 的方式，并且通过模块定义配置文件，可以很好的进行模块复用  
比较知名的就有 substack 的 [browserify](https://github.com/substack/node-browserify), tj 曾主导的 [component](https://github.com/componentjs/component)，还有后来的 [duo](https://github.com/duojs/duo)，[webpack](https://github.com/webpack/webpack)，时代就转眼进入了 browser 上的 CommonJS  

### CommonJS in browser  
由于 CommonJS 的 require 是同步的，在 require 处需要阻塞，这个在浏览器上并没有很好的支持（浏览器只能异步加载脚本，并没有同步的文件I/O），CommonJS 要在 browser 上直接使用则必须有一个 build 的过程，在这个 build 的过程里进行依赖关系的解析与做好映射。这里有一个典型的实现就是 substack 的 [browserify](https://github.com/substack/node-browserify)。  

#### browserify
browserify 在 github 上的 README.md 解释是：

`require('modules')` in the browser

Use a [node](http://nodejs.org)-style `require()` to organize your browser code
and load modules installed by [npm](https://npmjs.org).

browserify will recursively analyze all the `require()` calls in your app in
order to build a bundle you can serve up to the browser in a single `<script>`
tag.  

在 browserify 里可以编写 nodejs 一样的代码（即CommonJS以及使用package.json进行module管理），browserify 会递归的解析依赖关系，并把这些依赖的文件全部build成一个bundle文件，在browser端使用则直接用 `<script>` tag 引入这个 bundle 文件即可  

browserify 有几个特性：
* 编写和 nodejs 一样的代码
* 在浏览器直接使用 npm 上的 module

为了能让browser直接使用nodejs上的module，browserify 内置了一些 nodejs module 的 browser shim 版本  
比如：assert，buffer，crypto，http，os，path等等，具体见[browserify builtins](https://github.com/substack/browserify-handbook#builtins)  

这样子，browserify就解决了：  
* CommonJS在浏览器
* 前后端代码复用
* 前端第三方库使用

#### component
component 通过 component.json 来进行依赖描述，它的库管理是基于 github repo的形式，由于进行了显示的配置依赖，它并不需要对源码进行 require 关系解析，但是时刻需要编写 component.json 也使得开发者非常的痛苦，开发者更希望 code over configuration 的形式  

#### duo
所以有了 duo，duo 官网上介绍的是：  

Duo is a next-generation package manager that blends the best ideas from [Component](https://github.com/component/component), [Browserify](https://github.com/substack/node-browserify) and [Go](http://golang.org/) to make organizing and writing front-end code quick and painless.

Duo 有几个特点：
* 直接使用 require 使用 github 上某个 repo 的库
``` js
var uid = require('matthewmueller/uid');
var fmt = require('yields/fmt');

var msg = fmt('Your unique ID is %s!', uid());
window.alert(msg);
```

* 不需用配置文件进行描述，直接内嵌在代码里面
* 支持源码transform，比如支持 Coffeescript 或者 Sass

#### webpack
webpack takes modules with dependencies and generates static assets representing those modules.  

webpack 是一个 module bundler 即模块打包工具，它支持 CommonJS，AMD的module形式，同时还支持 code splittling，css 等  

#### 小结
这些 browser 上的 CommonJS 解决方案都有一个共同的问题，就是无法避免的需要一个 build 过程，这个过程虽然可以通过 watch task 来进行自动化，但是还是edit和debug还是非常不方便的  

试想着，你在进行debug，你设置了一个debugger，然后单步调试，调试调试着跳到了另外一个文件中，然后由于是一个bundle大文件，你在浏览器开发者工具看到的永远都是同一个文件，然后你发现了问题所在，回头去改源码，还得先找到当前所在行与源码的对应关系！当然这个可以通过 [source map](http://thlorenz.com/blog/browserify-sourcemaps) 技术来进行解决，但是相比较 AMD 那种所见即所得的开发模式还是有一定差距  

同时，需要build的过程也给多页面应用开发带来了很多麻烦，每个页面都要配置 watch task，都要配置 source map 之类的，而且build过程如果一旦出现了build error，开发者还要去看看命令行里面的日志，除非使用 [beefy](https://github.com/chrisdickinson/beefy) 这种可以把命令行里面的日志输出到浏览器console，否则不知道情况的开发者就会一脸迷茫     

### CommonJS vs AMD
这永远是一个话题，因为谁也无法很好的取代谁，尤其在浏览器环境里面，因为两者都有自己的优点和缺点  
CommonJS 
* 优点：简洁，更符合一个module system，同时 module 库的管理也非常方便  
* 缺点：浏览器环境必须build才能使用，给开发过程带来不便

AMD 
* 优点：天生异步，很好的与浏览器环境进行结合，开发过程所见即所得
* 缺点：不怎么简洁的module使用方式，第三方库的使用时的重复繁琐配置

### dependency injection
前面提到的 javaScript 依赖管理的方式，其实都是实现了同一种设计模式，service locator 或者说是 dependency lookup：    
通过`显示的`调用 require(id) 来向 service locator 提供方请求依赖的 module  
id 可以是路径，url，特殊含义的字符串（duo 中的github repo）等等  

相反，dependency injection 则`并没有显示的`调用，而仅仅通过一种与 container 的约定描述来表达需要某个依赖，然后由 container 自动完成依赖的注入，这样，其实是完成了 IoC（Inversion of control 控制反转）

service locator 和 dependency injection 并没有谁一定优于谁一说，要看具体使用场景，尤其是 javaScript 这种天生动态且是first-class的语言里, 可以简单的对比下：    

* service locator 非常直接，需要某个依赖，则直接通过 locator 提供的 api （比如 require）调用向 locator 获取即可，不过这也带来了必须与 locator 进行耦合的问题，比如CommonJS的require，AMD的define

相反，dependency injection 由于并没有显示的调用container某个api，而是通过与container之间的某个约定来进行描述依赖，container再自动完成注入，相比较 service locator 则会隐晦一点

* service locator 由于可以自己控制，使用起来更加的灵活，所依赖的也可以多样，不仅仅限于javaScript（还可以是json等，具体要看service locator实现）  
dependency injection 则没有那么的灵活，一般的container实现都是基于某个特定的module，比如最简单的class，注入的一般都是该module所约定好的，比如class的instance  

* service locator 中的id实现一般基于文件系统或者其它标识，可以是相对路径或者绝对路径或者url，这个其实就带来了一定的限制性，依赖方必须要在该id描述下一直有效，如果依赖方比如改了个名字或者移动了目录结构，那么所有被依赖方则必须做出改动  

dependency injection 中虽然也有id，但是该id是module的全局自定义唯一id，这个id与文件系统则并没有直接的关系，无论外部环境如何变，由于module的id是硬编码的，container都能很好的处理

* service locator 由于灵活性，写出来的代码多样化，module之间会存在一定耦合，当然也可以实现松耦合的，但是需要一定的技巧或者规范

dependency injection 由于天生是基于id描述的形式，控制交由container来完成，松散耦合，当应用规模不断增长的时候还能持续带来不错的维护性

* service locator 目前在javaScript界有大量实现，而且有大量的库可以直接使用，比如基于CommonJS的npm，因此在使用库方面 service locator 有着天然的优势

dependency injection 则实现不多，而且由于是与container之间的约定，不同container之间的实现不同，也无法共通  

其实，比较来比较去，不如两者结合起来使用，都有各自的优缺点：  
dependency injection 来编写松散耦合的应用层逻辑，service locator来使用第三方库  

#### dependency injection container
一个优秀的dependency injection container需要有下面这些特性：  
* 无侵入式，与container之间的描述不是显示通过container api调用而是通过配置
* code over configuration，配置最好是内嵌于code的，自描述的
* 实现异步脚本加载，由于已经描述了依赖关系，那么就无需蛋疼的再通过其它途径来处理依赖的脚本加载
* 代码可以前后端直接复用，可以直接引用，而不是说通过复制/粘贴而来的复用
* 在container之上实现其它，比如AOP，一致性配置，代码hot reload

这其实就是 [bearcat](http://bearcatjs.org/) 所做的事儿  
bearcat 并不是实现了 service locator 模式的module system，它实现了 dependency injection container，因此bearcat可以很好的与上面提到的各种CommonJS或者AMD结合使用，结合自己的优势来编写弹性、持续可维护的系统（应用）  

#### bearcat

bearcat 的一个理念可以用下面一句话来描述：  
`Magic, self-described javaScript objects build up elastic, maintainable front-backend javaScript applications`  
bearcat 所倡导的就是使用简单、自描述的javaScript对象来构建弹性、可维护的前后端javaScript应用  

当然可能有人会说，javaScript里面不仅仅是对象，还可以函数式、元编程什么的，其实也是要看应用场景的，bearcat更适合的场景是一个多人协作的、需要持续维护的系统（应用），如果是快速开发的脚本、工具、库，那么则该怎么简单、怎么方便，就怎么来  

##### bearcat 快速例子

假如有一个应用，需要有一辆car，同时car必须要有engine才能发动，那么car就依赖了engine，在bearcat的 dependency injection container 下，仅仅如下编写代码即可：  

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

* 通过 `this.$id` 来定义该module在bearcat container里的全局唯一id
* 通过 `$Id` 属性来描述依赖，在car里就描述了需要id为 engine的一个依赖
* 通过 bearcat.module(Function) 来把module注册到bearcat container中去
`typeof module !== 'undefined' ? module : {}`  
这一段是为了与 CommonJS（nodejs） 下进行兼容，在nodejs里由于有同步require，则无需向在浏览器环境下进行异步加载

启动bearcat容器，整体跑起来  

浏览器环境  
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

`bearcat.use(['car'])` 表面当前页面需要使用 car，bearcat然后就会加载car.js，然后解析car里面的依赖，知道需要engine，然后加载engine.js脚本，加载完之后，再把engine实例化注入到car中，最后调用`bearcat.start`的回调完成整个容器的启动

nodejs 环境  
``` js
var bearcat = require('bearcat');
var contextPath = require.resolve('./context.json');
global.bearcat = bearcat; // make bearcat global, for `bearcat.module()`
bearcat.createApp([contextPath]);
bearcat.start(function() {
  var car = bearcat.getBean('car'); // get car
  car.run(); // call the method
});
```

nodejs 环境下启动，则不需用`bearcat.use`了，直接把 `context.json`的路径传递给bearcat即可，bearcat会扫描`context.json`里面配置着的扫描路径，该路径下的所有js文件都会被扫描，合理的module都会注册到bearcat中，然后实例化，注入  

完整源码 [10-secondes-example](https://github.com/bearcatjs/bearcat-examples/tree/master/10-seconds-example)

##### bearcat + browserify

bearcat 的简洁，异步加载的module，无需打包，所见即所得，在编写应用层代码上有非常大的便利  
browserify 可以直接复用 npm 上的 module，使用第三方库非常的方便  

bearcat + browserify 会是一个不错的组合  

一个例子，基于 bearcat + browserify 的 markdwon-editor  

bearcat 与 browserify 直接通过一个`requireUtil`（比如）的module来进行连接

在这个 `requireUtil` 可以使用 browserify 的 require，用这个 require 来引入第三方库，比如marked库  

requireUtil.js
``` js
var RequireUtil = function() {
    this.$id = "requireUtil";
    this.$init = "init";
    this.brace = null;
    this.marked = null;
}
    
RequireUtil.prototype.init = function() {
    this.brace = require('brace');
    this.marked = require('marked');
}
     
bearcat.module(RequireUtil, typeof module !== 'undefined' ? module : {});
```

然后在你的业务层代码上，注入这个 `requireUtil`来使用 browserify 引入的第三方库  

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

这样子一来，编写业务层代码由于是由bearcat管理的，javaScript依赖异步加载，代码编写和debug就和AMD一样，所见即所得，设置断点什么的，再也不用担心找不到源文件（或者需要source map）  
使用 browserify 仅仅是为了用它来引入第三方库，且也仅仅当引入一个新的第三方库的时候才会执行一下 browserify 的 build  

bearcat 和 browserify 的优势就都发挥了出来，提高了开发的效率以及可维护性  

bearcat-markdown-editor 官网例子地址 [markdown-editor](http://bearcatjs.org/examples/markdown-editor.html)

### 总结
无论是CommonJS、AMD或者是dependency injection，单独使用某一个，javaScript依赖管理都不是完美的  
面对不同的场景，使用不同的方案  

### 参考
* [martin fowlter dependency injection](http://martinfowler.com/articles/injection.html)
* [asynchronous frontend dependency management without AMD](http://bearcatjs.org/2014/12/24/asynchronous-frontend-dependency-management-without-AMD/)
