# Angular JS

## Anatomy of an angular application
An application is comprised of modules.

Usually the entire application has a single `index.html` file. The `.css` go in the header while the javascript links go at the bottom of the `body`.

The `ng-app` directive is specified on one of the tags in the `index.html` file and specifies the name of the main module. On load, the browser looks for the `ng-app` directive. To connect the `ng-app` directive with a particular module we use the following syntax
  
  ```
  <body ng-app="ModuleName">
  ...
  ```

**NOTE**: Don't forget to add the corresponding `.js` file that defines the module above to the `index.html` page. 
  
The html code required for other parts of the application is included in view files which are normal html files. To include another file in the main `index.html` file one can use the `ng-include` directive.

Template files have an associated controller that provides the data and logic for the view.

The controller manages the data model for the view and contains the methods required by the view such as processing button clicks.


## Project file organisation
* `css`: Contains all the styling files
* `fonts`: Contains all the font files
* `img`: Contains all the font files
* `lib`: Contains all external JS library files
* `app`: The main application
  * `services`
  * `controllers`
  * `components`   
* `html`: Partial html pages
* `index.html`: Entry point to the application

## Directives
#### `ng-repeast` directive
Usually used for dynamically constructing rows of elements in a table.

```
<tr ng-repeat="p in ps">
  <td>{{p.Item}}</td>
  <td>
    <img ng-src="{{p.imageUrl}}" title="{{p.Description}}" />
  </td>
```
Specifically for the img-src attribute, we want to use `ng-src` here, otherwise the browser will attempt to load the image without having evaluated the expression in the curly braces before that.

#### `ng-init` directive
Its use is discouraged, however it allows you to quickly see how things work if a collection was actually populated when prototyping and before you actually connect to a real service.

```
<table ng-init='
  products= [
    { "productId" : 1,
      "imageUrl" : "http://1",
      "Description" : "The dscr1"},
    { "productId" : 2,
      "imageUrl" : "http://2",
      "Description" : "The dscr2"},
  ]'>
  
```
## Modules
Most applications have one module but can reference other modules.
A module tracks all of the application's code.
The module tracks all of the external dependencies of the application.

### Creating a module
To create a module we use the `module` method which as 2 overloads.

* **Setter method**  
    `angular.module("ModuleName", []);` The first parameter is the module's name, while the second one is an array of dependencies. Angular injects the dependencies. This is called the setter method because it's how you create a module.
* **Getter method**
    `angular.module("ModuleName");` In this case the first and only parameter is the module's name and it's how you can get a reference to an existing module.

This is usually done in the `app.js` file of the application and is bound to a variable named `app`. As this can pollute the top-level name space we often use a self-executing anonymous function know as an Immediately-Invoked Function Expression (IIFE).

```
(function () {
  "use strict";
  var app = angular.module("ModuleName", []);
}());
```

## Controllers
The purpose of the controller is to provide support to a view. The code in the controller defines the model and implements the actions that can be performed from the view.
* Defines model
* Defines actions/methods that can be performed on the view.

### Creating a controller
A controller is registered with one of the applications modules.

1) Start by defining the IIFE to wrap around the entire contents of the controller.
    ```
    (function() {
        // Code goes here
    }());
    ```

2) **Look up the module**. To associate the controller with a module we need to have a reference to the module. This is done using the getter syntax `angular.module("ModuleName")`
3) **Register the controller with the module**. This is done using the controller method. The first argument to the controller method is the name of the controller. The second argument is a list of variables names that are bound to the function parameters. The function is the last element of the list as in the example below. The reason why we need to explicitly write out the parameter names is that during the process of minification the name of the variables might change.
        
    ```
    .controller("ControllerNameCtrl", 
      ["$scope1", "$scope2",
       function($scope1, $scope2) {
          // code goes here
       }]);
    ```

4) Write the actual code of the controller

### Communicating between View and controller
Communication and information passing between the view and the controller can be performed with the following 2 ways:
* **Using `$scope`**  
  The variable `$scope` is a built in angular variable that enables communication between the view and the controller.
  
* **Using controller as**
  With the second method the `$scope` is not required as a parameter and the model and methods are defined on the controller itself. In the view, the model and methods are references using an alias defined in the `ng-controller`. Customarily the name of the variable is `vm` which stands for View Model. The directives inside the view can now access the model and methods of the controller through the alias.
  
  ```
  <body ng-app="MainModule" ng-controller="ProductCtrl as vm>
  ...
  ```


### Best practices for controllers
There are a few best practices when creating controllers
1) Define each controller as a separate .js file. This means that each controller needs a separate script tag in the main.html. 
2) Name the controller in Pascal case
3) Suffix the controller with "Controller" or "Ctrl"
4) Wrap the controller in an IIFE

### Hooking it up to the view
Connecting the controller to the view is done using the `ng-controller` directive applied to the tag that represents the view. The name used is the "logical" name of the controller rather than the filename.

```
<div ng-controller="ProductCtrl">
... 
</div>
```
 

## Filters
