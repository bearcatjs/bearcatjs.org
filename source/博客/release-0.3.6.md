title: bearcat 0.3.6 更新日志
type: 博客
order: 2
---

## 热更新
本次升级主要是优化了热更新，热更新的原理还是基于bearcat IoC 动态替换 javaScript 对象的 prototype 里面的方法，之前热更新watch file是通过nodejs自带的fs.watch实现的，现在版本基于 [chokidar](https://github.com/paulmillr/chokidar) 库实现，可以支持多层目录的监听热更新，而不是之前版本的只能监听一级文件夹下面的文件，因为可以直接指定源码文件夹即可（默认就是app目录），更新里面的代码，只要是松散耦合，并不存在引用依赖的，就可以热更新

## 使用

启动bearcat时传入两个参数  

```
bearcat.createApp([contextPath], {
	BEARCAT_HOT: 'on',
	BEARCAT_HPATH: 'setup your hot reload source path'
})
```

* BEARCAT_HOT: 传入 'on' 来开启热更新，默认是关的 
* BEARCAT_HPATH: 设置热更新的扫描路径，默认是app文件夹

更多详情还请看官方文档 [bearcat hot reload](http://bearcatjs.org/topic/index.html)