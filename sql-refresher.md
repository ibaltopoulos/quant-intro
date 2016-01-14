### SQL refresher


#### Best practices checklist
* <http://sqlblog.com/blogs/aaron_bertrand/archive/2008/10/30/my-stored-procedure-best-practices-checklist.aspx>

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

There are 2 main types of tables from the point of view of the designer/developer.
1) Data tables
These tables are the big/important tables, they have lots of fields, lots of rows and are expected to constantly grow in size. The usually have foreign keys that point to other tables.
2) Lookup tables/setup tables/atomic tables
Small number of fields, a finite (mostly) number of records , no foreign keys


##### Temporary tables
Temporary tables created inside a stored procedure are destroyed upon completion of the stored procedure.
* **Local temporary table**: A `#table_name` exists only for the duration of a user session or the procedure that created the temporary table. A local temporary table cannot be shared amongst multiple users.
* **Global temporary table**: A `##table_name` also exists for the duration of a user session or procedure, but can be shared amongst multiple users.

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

##### Table variables
Table variables are declared in a similar way to creating regular or temporary tables. The only difference is the datatype used for naming the table. Table variables are used most often in table valued functions. 



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

Best practice is to use semi-colons after each statement. 

##### Selective execution
Highlight a particular portion of a statement and press F5 to execute only that portion of the whole program.

The execution results can be outputted in a results grid, plain text, or even a file.

##### Column aliases
This is useful when we use aggregation functions that: 1) change a column's name, temporarily renames the column name.
```<column> AS <new_name>```

The new name is provided in double quotes.

##### Performing calculations
Most arithmetic operations are available in statements (+ addition, - subtraction, * multiplication, / integer division, % modulo)

##### `Case` expressions


##### Focus on ```WHERE```
It is used to filter out some rows. It's going to exist right after the ```FROM``` line.

This is one of the first things SQL server is going to process. This means that if we start aliasing columns in the select part, those aliases are not going to be available to us in the WHERE clause.

##### Predicates in WHERE clauses
The recommended syntax is to have the column first

```
<column> <operator> <value>
```
operators (=, <>, <, >, <=, >=)

Looking at an inclusive range
```
<column> BETWEEN <value> AND <value>
```

Look for a value contained inside a list of values

IN, ALL, ANY, or SOME (not) EXISTS

##### Combining predicates
Use AND, OR


##### Querying strings
```
<column> LIKE <expression>
```
LIKE allows wildcard characters
* % - zero or more characters
* _ - one character
* [] - used for a range
  * [afr] - will look for the characters a, f, or r
  * [a-f] - will look for a, b, c, d, e, or f
* [^] - any character **except** what is in the range

Be careful when you put a percentage sign in front and behind a string. The problem with that is that SQL will take a performance hit as it will need 

Best practice is never to start with a wildcard character.
Best practice is to provide as many characters as possible (3-4 at a minimum). Again because of performance, SQL might decide to look through all records when trying to find something.

A final thing is when escaping characters in a string, SQL allows you to choose which escape character to use.
```
<column> LIKE '\[pc\]' ESCAPE '\'
```

##### Handling NULL data in predicates
Predicates have 3 possible return values: TRUE, FALSE and UNKNOWN.

SQL is going to return unknown if it needs to compare any value that contains NULL. 

In a where statement, only anything that returns TRUE is going to be included in the dataset. Any comparison to a NULL value is going to be excluded.


##### Filtering NULL data
```
<column> IS NULL 
```

#### Join Statements
Why do we have to do joins?
The data is split up in multiple tables. 

The way joins work is by bringing together two tables by matching the contents of 2 columns. 

We can join multiple tables (more than 2). 

Joins are put together on the FROM line.

```
FROM table1 as t1
   INNER JOIN table2 as t2 ON t1.C1 = t2.C1
```

It is possible to do the join on the WHERE line.

The preferred way (ANSI standard) is to do the JOIN on the FROM line instead of the WHERE line.

##### Best practices when doing joins

1) Always alias tables. When aliasing tables, the convention is to use each capital letter you see and possibly a number. Once you alias a table you MUST always use that alias to refer to the table. The fully qualified name no longer works. (Check this?) 
2) Always use two part naming for columns. This is because it will sometimes be required (table.Column). This is because sometimes the tables will have the same column name. Additionally it also helps with readability as you can quickly identify where the column is coming from.
3) Place each join on a separate line. Try to keep the ON keyword on the same line as the INNER JOIN keywords.
4) Place tables in logical order. This doesn't matter in terms of execution, but it does make the code more readable.

##### Types of joins
* **INNER JOIN**. By far the most frequently used type used. It's only going to return a row from both sides, when the values match. 
  ```
  FROM table1 as t1
    INNER JOIN table2 as t2 ON t1.C1 = t2.C1
  ```
  The keyword INNER is not necessary but it is considered a best practice to  include it to better document the code. Another best practice is to list the tables and column names after the ON in the order in which the tables were declared 
* **OUTER JOIN**. An outer join will return rows from the tables even if they don't match. There are 3 options for outer joins
  1) **FULL**. Any row in table A that doesn't match on the join will be returned regardless of which table they are in. Useful for data clean-up, for example find customers with no orders, or orphaned orders. 
  2) **LEFT**. With left we are pointing in the direction of which table we want to get the orders from.
  3) **RIGHT**. There is no difference in LEFT or RIGHT other than which order they're specified in, in the FROM line.

* **SELF JOIN**. The second least commonly used type of join. It is a sign of poor design. Instead what you want to do is to split the data in a separate table.

* **CROSS JOIN**. Cartesian product. It doesn't have an ON statement, and it returns all the data combinations from both tables. It's a good way to generate test data.

##### Venn diagram explanations of the different types of joins
[Jeff Attwood](http://blog.codinghorror.com/a-visual-explanation-of-sql-joins/)

[Code project](http://www.codeproject.com/Articles/33052/Visual-Representation-of-SQL-Joins)


#### Sub-queries and the UNION statement
A sub-query is a query inside another query. It is useful for 1) breaking down complex logic, 2) simplifying reading, 3) "Sneak in operations" that normally wouldn't be allowed in our queries. For example you cannot include an aggregate in a where clause (one that performs an operation on all the rows that get returned, e.g. average). However, but placing them in a sub-query they can be included in a sub-query.

Sub-queries can always be replaced by a JOIN. The join can be faster than a sub-query. 

For the most part if one writes good and clear code.


##### Placement of sub-queries
* **SELECT line**. It allows us to get information from another table and act upon it in the select line. The query must return a scalar or a single value that we can act upon (e.g. an average)
* **FROM line**. This is like creating a dynamic table. You must alias the result.
* **WHERE line**. Most common place where people place the order. Some extra predicate operators are used when putting a sub-query in a where line.
  1) **IN**. Confirm column value exists in the sub-query
  2) **EXISTS**. Returns true if the sub-query returns values. It can frequently be faster than an IN statement. It's used with a correlated query.
  3) **ALL**. Compares column value to all items returned by the sub-query.
  4) **ANY** or **SOME**. See whether the column matches any of the items returned by the sub-query
  
##### Correlated sub-queries
In this case we pass a column name from the outer query into the inner sub-query. It is used to simulate a join.


##### UNION statement
Two results that are tacked on top of each other. Rules for UNION to work
* Each query needs to have the same number of columns
* The data types must be compatible
* First query sets column names of result set
* If using ORDER BY there can only be one at the end
* By default UNION queries are DISTINCT. That means that SQL server will remove any duplicates. If we want to have duplicates in the result set then we should use UNION ALL.

##### EXCEPT and INTERSECT statements
They behave like a UNION statement in that they need the same number of columns and the data types to agree
* **INTERSECT** returns rows from top query that match the bottom query
* **EXCEPT** returns rows from top query that don't match the bottom query


#### Aggregating Data
The main focus on aggregation is on the SELECT line, but also the GROUP BY and the HAVING line.

##### Using aggregate functions
They are used to perform calculation on data. Average, max, min, 

* NULL values are ignored when aggregating. For example, a sum will add up all the rows that have a value, with all NULLs being skipped. Average will add all null values and will divide by the number of non-null values.
* When you use an aggregate, all columns MUST be in an aggregate (GROUP BY line for all the columns not in the aggregate). An aggregate is going to always return you 1 column. 

Several functions come built-in, but you can create a new one with .Net assemblies.

Whenever someone uses the words "by" or "for each" then a "GROUP BY" is required.

##### Some common aggregate functions
* SUM(column)
* COUNT(column) - does not count null values for provided column
* COUNT(*) - counts all the rows
* MAX(column)
* MIN(column)
* AVG(column)

##### HAVING 
HAVING allows you to filter on an entire group, i.e. that the group meets the required criteria.

##### Data rollups
WITH ROLLUP provides the totals using the order in an ORDER BY. If you GROUP BY several different columns, ROLLUP will provide you totals for each column and will roll them up to the higher level column as specified on the GROUP BY line.

##### CUBE
WITH CUBE provides the totals for all combinations of columns on the GROUP BY. 

##### GROUPING SETS
Grouping sets will allow us to tell SQL how we want our categories to be totalled up. 
```
GROUP BY GROUPING SET ( (...), (...) , (...))
```

##### GROUPING and GROUPING_ID

GROUPING identifies a column/row being used by a total. Returns the number 1 whenever that column/row is a total.


#### Common Table Expressions (CTE)
It is a lot like a temporary table, table variable or an inline view.

Uses:
* Breakdown complex queries
* Avoid sub-queries
* Simplify certain syntax

Syntax:
```
WITH <tableName> [(<columnName1>, ...)]
AS (
  <select query that returns a table>
)
```
The column names can be omitted and will be pulled in from the select query.

#### PIVOT and UNPIVOT
A pivot statement allows us to convert row data into column data.

```
SELECT <NonPivot>
  , <FirstNonPivotedColumn>
  , ...
FROM <table containing data>
  PIVOT (FUNCTION(<data column>)
    FOR <list of pivoted columns>
      AS <alias>
```

An unpivot statement allows us to convert column data into row data. It does not perform a full reverse of a pivot statement.

#### Sorting Data
SQL returns the data in the order that it appears in the index that SQL uses to query the database.



##### ORDER BY
ORDER BY controls which columns will be used to sort output

You can either use a column name or a column number as they appear in the SELECT statement. Using a number is considered a very bad practice and should be avoided.

You can use multiple columns, so the sorting will depend first on the initial column.

The ORDER BY executes last in a SELECT statement. 

By default the ORDER BY statement sorts everything in ascending order **ASC** (for numbers that means smallest to largest, and for strings that means in alphabetical order)

To reverse the default sort order we use the **DESC** keyword

The ASC/DESC modifiers are applied to a particular column after the ORDER BY.


##### Limiting rows
Use the TOP keyword. It's used to limit the number of rows that are returns. This can be done either by specifying a number of rows or a percent. TOP is typically used with ORDER BY.

```
SELECT TOP 5 PERCENT 
  <column1)
FROM ...
```


##### Ranking functions
There are different ways to specify a ranking function
1) ROW_NUMBER: Returns the row number
    ```
    SELECT <column1>
      , ROW_NUMBER() OVER (ORDER BY <column2> DESC) AS 'Row number'
    FROM ...
    WHERE ...
    ORDER BY <column2> DESC;
    ```
2) RANK: Returns ranking based on ORDER BY statement, ties skip to the next number.
Think of the Olympics, if two people finish second and nobody gets bronze

    ```
    SELECT <column1>
      , ROW_NUMBER() OVER (ORDER BY <column2> DESC) AS 'Row number'
      , RANK() OVER (ORDER BY <column2> DESC) AS 'Rank'
    FROM ...
    WHERE ...
    ORDER BY <column2> DESC;
    ```
3) DENSE_RANK: Returns ranking based on ORDER BY statement, ties don't advance the rank number
4) NTILE(X): Breaks rows into equal sections where X is the number of sections. 


##### Paging
Paging is used to retrieve portions of data
FETCH and OFFSET
* FETCH indicates the number of rows to retrieve
* OFFSET indicates the number of rows to skip

Restrictions, ORDER BY is required, TOP is not allowed

```
SELECT <columns>
FROM <tables>
ORDER BY <columns>
    OFFSET X ROWS 
    FETCH NEXT 5 ROWS ONLY;
```

##### DISTINCT
It is used to remove duplicate values. It will only remove rows when the ENTIRE row must be duplicate. 

Distinct will cause a sort of the order which impacts performance.


#### Built-in Functions
1) Deterministic functions. If I pass the same value I get back the same result
2) Nondeterministic functions. Same input may yield different results

##### Performance issues
SQL may need to process each row individually, this is also known as a "hidden cursor" because it goes row by row over your results.

Avoid passing columns into functions in a SELECT statement. Never do theis on the WHERE clause as it will need to be applied on the entire table!

##### NULL functions
* ISNULL: Takes 2 parameters and returns the first parameter if it's not null, returns the second parameter if the first parameter is null
* COALESCE: Takes multiple parameters and returns the first parameter SQL Server finds that is not null. This is more flexible and easier to read than the ISNULL function.

##### Date/Time functions
* GETDATE(): Returns the current server date
* GETUTCDATE: Returns the server date normalized to UTC
* DATEPART(): Returns part of a data. Related to DAY(), MONTH(), and YEAR()
* DATEDIFF(): Difference between two dates
* DATEADD(): Add time to a date
* ISDATE(): Determines if value is a date
* DATEFROMPARTS(): Builds a day from a provided year, day, month
* TIMEFROMPARTS(): Builds a time from provided hour, minute, second
* EOMONTH(): Provides the last day of the month for the provided date
* PARSE(): Converts string to a date.

##### String functions
* CHARINDEX(): Searches for one string inside another
* PATINDEX(): Supports pattern searches inside of a string
* LEFT() and RIGHT(): Returns characters from the left or right side of a string
* LTRIM() and RTRIM(): Removes strings whitespace from a string
* LEN(): Returns the length of a string
* CONCAT(): Concatenates strings
* FORMAT(): Converts value to a string using .Net formatting

##### Data Type functions
* CONVERT(type, value, format)
* CAST(value AS type)
* TRY_PARSE(): More flexible when converting string to data types, returns NULL if parse fails
* TRY_CONVERT(): Both will return NULL but use a different function behind the scenes.

##### Logic functions
* CHOOSE(): Returns a list item based on its location. First parameter is index, next parameters are the list
* IFF(): Instant if, three parameters boolean expression, return second parameter if true, third parameter if false.


#### Query optimization

##### Indexes
An index is some form of guaranteed order. Think of a phonebook.

Most indexes generally leads to faster querying, more indexes generally leads to slower modifications, because as data is inserted and deleted indexes must be preserved and updated.

Indexes must be maintained (administrator must defragment indexes). If one deletes data, the space occupied in the index will not get reoccupied by later inserts.


##### Types of indexes
* Clustered index: The rows are stored physically on the disk in the same order as the index, therefore there can only be one clustered index (think of a page number in a book)
* Non-clustered index: There is a second list that has pointers to the physical rows. Copy of data sorted for queries. Index in the back of a book, contains a pointer back to the original content.

##### Statistics
Statistics are used by SQL Server to figure out how to execute a query. Every time we write a query it generates an execution plan. It's goal is to identify the best way to execute a query but at the same time determine the execution plan as quickly as possible.

Statistics store information about the data in the indexes and tables. They are used to determine how to best execute a query.

##### Query plans
How can we figure out what SQL server is doing behind the scenes? 

A query plan shows us what is going behind the scenes. They are used to optimize queries and to determine which indexes were used.

There are two options for viewing a query plan:
* Actual execution plan. Requires the query to be executed
* Estimated execution plan. Doesn't require the query to be executed but it may not be correct.

##### Things in an execution plan
1) Data Access Methods
    * Scan. Examines every row in the table or index
    * Seek. Able to follow path directly to the desired data.
    * Key lookup

In general you want to see a Seek in your queries. Seeing a Scan is not always an indication of a problem, but you should think through what it is happening.

2) Join Methods
    * Merge join. Data is presorted and this is the most efficient join.
    * Loop join (nested loop). One table is much smaller than the other. Small table is searched for the values that match the larger table. Slower than a merge join 
    * Hash join. Large tables and unsorted data. Slowest type of join.


##### Query hints
Typically query hints should be avoided. 

Query hints control how SQL server will execute a query. This can include which index to use or how to lock data.

1) Locking Hints
    * ROWLOCK. Force locks at the row level
    * PAGELOCK. Force locks at the page level
    * TABLOCK. Force locks at he table level
2) Index and parameter hints
    * FORCESCAN. Scans index or table
    * FORCESEEK. Seeks at the index or table
    * OPTIMIZE FOR UNKNOWN. Tells SQL Server to create a query plan where the value for the parameter will change frequently.

##### Dynamic Management Objects
Use dynamic management objects are used to see what's going on behind the scenes. Find out how SQL server is using resources. It's at a higher level than an individual query. They can identify problem queries.

DMO's come in two varieties:
1) Views. Used like tables
2) Functions. They accept parameters, usually an object ID

**Index dynamic management objects**
* sys.dm_db_index_usage_stats - determine which indexes are (or aren't) being used
* sys.dm_db_mising_index_details - determine what indexes SQL server thinks should be added
* sys.dm_db_index_physical_stats - determine how an index is using disk space


**Transaction dynamic management objects**
* sym.dm_tran_database_transactions - information about transactions in the database
* sys.dm_tran_session_transactions - information about transactions for sessions
* sys.dm_tran_locks - information about data locked for transactions

##### Dynamic SQL
Allows for the creation of SQL on the fly
Use **sp_executesql** and be careful of SQL injection attacks

```
EXECUTE sp_executesql <SQL>
  , <Parameter Definitions>
  , <Parameter Values>
```


#### Error Handling
Errors can be detected in two ways:
1) @@ERROR variable. If there is no error from the previous operation the @@ERROR variable will be 0. However, it requires that one always checks after each operation. The code winds up very complicated. 
2) TRY/CATCH. Do these steps and get back to me if something goes wrong.

```
BEGIN TRY
  -- Perform task
END TRY
BEGIN CATCH
  -- Error handling
END CATCH
```
