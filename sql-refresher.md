### SQL refresher

#### Basics
The basic unit is a table (rectangular data structure that has columns and rows).

There are also other objects that we have in databases
* **Views**: Virtual tables. The whole goal of a view is to simplify structure. 
* **Stored procedures**: Programming object that allow us to make changes to data or return data. In contrast, Views are read only
* **Functions**: Commands that can be executed. A function can only return data. The return data can take some format either a single value or a table.

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



