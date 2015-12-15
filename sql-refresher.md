### SQL refresher

#### Basics
The basic unit is a **table** (rectangular data structure that has columns and rows).

There are also other objects that we have in databases
* **Views**: Virtual tables. The whole goal of a view is to simplify structure. 
* **Stored procedures**: Programming object that allow us to make changes to data or return data. In contrast, Views are read only
* **Functions**: Commands that can be executed. A function can only return data. The return data can take some format either a single value or a table.

#### Referencing objects in a database

Each object in a database has 4 parts to its name:
1) The server name (optional) the server that is housing the database. By default it is the current server
2) Database name (optional), - default is the current database
3) Schema. They are like folders and allow you to structure objects and set permissions on a per-schema basis. If you don't provide a default schema use the default or dbo. Default schemas may change, or others have a different default schema. For that reason it is a good practice to always specify the name of the schema.
4) Object name: The required object name.

##### Object naming
letters, numbers and underscores. 
if we have an item that contains an "invalid" character in its name then we need to quote it using:
* Square brackets ```[]```
* Double quotes (```""```). To use double quotes this option needs to be enabled on the server using the option ```quoted identifiers```

The best practice is to use square brackets around names that contain invalid characters. 

Sometimes dynamically generated SQL comes with everything quoted in square brackets, however when typing it out by hand it is not necessary. 

##### Case sensitivity
Treat everything like it's case sensitive. 

Convention is to put all TSQL keywords in all capital letters.

String comparisons may be case sensitive. It is possible to disable this at different levels (server, database, table, column)

#### Tables
* **Columns** describe the information that is going to be stored in the database
* **Rows** describe instances
* **Constraints**: Ensure that the contents of a cell have the right values. Constraints the available values that the type permits.
* **Triggers**: It's automatically going to execute code in response to a modification in a table
* **Primary key**: Designed to uniquely identify every single row in that table. Each table is required to have a primary key.
* **Foreign key**: Used to create relationships between tables. Important in designing a database. Useful when we want to avoid data duplication. 

#### Table relationships

Why would want to do that.
1) To help improve the performance of updates. You go to a single place to update the data.
2) Provides us with more flexibility when querying
3) Data integrity, updating the single place. 

There are 3 types of relationships in SQL
1) One to One
2) One to Many
3) Many to Many

##### One to one relationship

It refers to a relationship where one row in one table, refers to another row in another table. 

They are not very common but can be useful in situations where we need to divide some data because the secondary data is not accessed frequently or not that important. Not frequently encountered when designing a database. 

##### One to many relationship
A relationship where one row may refer to many rows in another table.

Parent-child relationship, e.g. one category can have multiple products, or one customer has many orders.

Amongst the most frequently used type of relationship.

##### Many to many relationship
A relationship where many rows can refer to many rows in another table.

Implemented through two one-to-many relationships, the table in the middle is used to associate the categories. The middle table is called a join table.


#### Table design
##### Normalization
It is a process for designing and defining your tables. It can take 5 forms/levels. 

For example to be in 3rd normal form you already need to have reached 1st and 2nd normal form.



#### Result sets vs. row based logic
SQL statements can update sets of row or can update individual rows.

Individual rows are usually done through cursors. 

#### Variables
Variables store temporary data. They have 3 components
* Name: All variables start with an @ sign, and system variables start with @@
* Data type: What type of information can be stored in the variable
* Value: The information that is going to be stored. That value can be NULL, meaning no value.

```
DECLARE @<Name> <DataType>;
SET @<Name> = <Value>;
```

#### Comments
* Single line comment. Two dashes (```--```)
* Multi line comment. Slash star (```/*    */```)

**Keyboard shortcuts** 
* Comment: Ctrl-K, Ctrl-C
* Uncomment: Ctrl-K, Ctrl-U





#### Select Statements
First select check which database you want to use:
* Choose the database from the drop down box
* ```USE <DatabaseName>```

##### SELECT statement components

```
SELECT <columns>
FROM <tables>
WHERE <conditions>
GROUP BY <columns>
HAVING <conditions>
ORDER BY <columns>
```

##### Focus on ```SELECT``` and ```FROM```
The select line is a list of columns.
Columns are separated by commas:

The best practice is to list columns on separate lines. Commas can be either at the beginning or at the end, just be consistent.

You can use an asterisk ```*``` for all columns, but never do this for a production system. This is considered a bad practice for 2 reasons:
* Performance hit (memory load and network traffic)
* Ask for what you need and nothing else

Best practice is to not use select ```*```

