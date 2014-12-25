title: Consistent-configuration
type: guide
order: 5
---

## Overview
In Node.js development, it is common that there are serveral envrionments like development, test, production and so. Corresponding to these envrioments are configurations differed from each other. Therefore, it is necessary to make these configuration consistently.  

## Using placeHolders  
placeHolder is a signature indicating the place to be replaced by the specific envrioment value  
in Bearcat, the placeHolder can be like this:  
```
${car.num}
```

then in config.json file you can define ***car.num*** with the specific value  
``` js
{
    "car.num": 100
}
```

## Environment configuration
In Bearcat, you can write different environment configurations in the following structure:  
![directory structure](https://raw.githubusercontent.com/wiki/bearcatnode/bearcat/images/configuration-structure.png)

in directory named ***config***, you put ***dev*** and ***prod*** sub-directory named by specific envrioment, and then write the specific configurations in these directory corresponding to each environment.  

## Switching environment
In Bearcat, you can switch different environment in the following ways:  
* run with ***env*** or ***--env*** args  
```
node app.js env=prod
```
* run with NODE_ENV  
```
NODE_ENV=prod node app.js
```

by default, the env is ***dev***