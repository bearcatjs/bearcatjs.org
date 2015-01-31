title: context.json
type: guide
order: 7
---

context.json is the only configuration file that bearcat needed  

### Context attribute
Context attribute is written in json like file with the following attributes:   

* name : specify the name of the project or library  
* beans : specify the beans metadata definitions to be managed in the container, it is an array with the element of [bean metas](/guide/magic-javaScript-objects-in-details.html#Bean_attribute)
* scan : scan paths for auto-wired code-based metadata beans, it can be simple path of type String and multiple paths of type Array
* imports : an array defines imported context.json paths  
* dependencies : specify the beans from the dependency module to be managed in the container  
* namespace : specify the namespace of beans defined in context.json configuration metadatas
in bearcat, the actual id will be ***namespace:id***  
therefore, when you use dependency injection or getBean, you should add the namespace  
```
namespace:id
```