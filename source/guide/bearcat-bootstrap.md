title: bearcat-bootstrap.js
type: guide
order: 8
---

As we all know, for frontend browser, there is no synchronous file io that can be used to load scripts. Therefore, a ***bearcat-bootstrap.js*** file is needed to tell bearcat the meta configurations and how to load these javaScript files  

bearcat-bootstrap.js file can be auto-generated, no need to write by yourself  

install bearcat  
```
npm install -g bearcat
```

then in your project root directory, run   
```
bearcat generate
```

bearcat-bootstrap.js is ready for you  
load it as you like by script tag or browerify require or amd define  

``` html
<script src="bearcat-bootstrap.js"></script>
```

***note***：only when you add a file or delete a file or modify the file location，`bearcat-bootstrap.js` need to be regenerated, when you just edit files，it is not needed to be regenerated