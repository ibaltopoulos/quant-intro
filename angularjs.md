# Angular JS

## Anatomy of an angular application
An application is comprised of modules.

Usually the entire application has a single `index.html` file. The `.css` go in the header while the javascript links go at the bottom of the `body`.

The `ng-app` directive is specified on one of the tags in the `index.html` file and specifies the name of the main module.

The html code required for other parts of the application is included in view files which are normal html files. To include another file in the main `index.html` file one can use the `ng-include` directive.

Template files have an associated controller that provides the data and logic for the view.

The controller manages the data model for the view and contains the methods required by the view such as processing button clicks.