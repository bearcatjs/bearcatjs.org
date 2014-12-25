title: Common FAQs
type: guide
order: 15
---

- **Why named bearcat**
the name is easy to remember, also means `panda` which chinese national treasure, it also means small man does big thing  

- **Is bearcat creating another module system ?**
bearcat really provides is dependency injection, it is not the same module system. Dependency injection is based on module system actually. Module dependency uses `require`, `exports` like to resolve dependencies, and module can be any valid javaScript. Dependency injection (DI) is a process whereby objects define their dependencies, that is, the other objects they work with, only through constructor arguments, arguments to a factory method, or properties that are set on the object instance after it is constructed or returned from a factory method. The container then injects those dependencies when it creates the bean. This process is fundamentally the inverse, hence the name Inversion of Control (IoC), of the bean itself controlling the instantiation or location of its dependencies on its own by using direct construction of classes, or the Service Locator pattern.  
Therefore, you can use bearcat with other module system like `browserify` for example