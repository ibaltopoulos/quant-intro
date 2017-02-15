## Code blocks
* **Lines and indentation:** Python uses line indentation for blocks of code. The number of indentation is variable but it is strictly enforced.
* **Multiline statements:** They are continued with the (\) character. Statements within [], {} or () do not need the continuation character
* **Quotation:** single ('), double (") or triple (''', """) for string literals. Triple quotes are used to span the string across multiple lines.
* **Comments:** A hash (#) not inside a string literal begins a comment.
* **Multiple statements on a single line:** Each line is a statement, however, the semicolon (;) allows multiple statements on a single line, provided that neither statements starts a new code block.

## Variables
* **Basics:** Variables are case sensitive, they can start with a letter or an underscore
* **Conventions:**
    * **Class names:** Start with uppercase letter
    * **Underscores:** 
        * 1 underscore, the identifier is private
        * 2 underscores, strongly private identifier
        * 2 leading, 2 trailing underscores, language-defined special name
    * **Reserved words:** There are a few
* **Assignment:** The equals (=) sign is used for assignment, and multiple assignment is allowed

## Standard Data types
* **Numbers:** (int, long, float, complex)
* **String:** 
    * **Plain and unicode:** They are different, need more research on this
    * **Operators:** plus (+) is used for concatenation, star (*) is used for repetition, and slice [] and [:] with indexes starting at 0 allow taking substrings
  • List: Comma separated and enclosed with square brackets []. Items in the list can be of different data type. + is concatenation, * is repetition
  • Tuple: They are immutable and are enclosed within parentheses
  • Dictionary: A hashtable of key value pairs. They are enclosed by curly braces {} and values can be accessed using square brackets. The key can be any python type but it's usually a string or number. The value can be any arbitrary python object. Elements are unordered

Functions
  • Syntax
    ○ def funcName( parameters ):    "function doc string"    function_suite    return [expression]
  • Pass by reference
  • Function arguments
    ○ Required arguments: This is the conventional way of using positional arguments.
    ○ Keyword arguments: Named arguments can appear out of order
      ▪ called by using funName(p = "value")
    ○ Default argument: Default values are provided during the function declaration
    ○ variable-length arguments: The asterisk placed before the variable name that holds the values of all nonkeyword variable arguments. The tuple is empty if no additional arguments are specified during the function call.
      ▪ def funcName( [named_args,] *var_args_tuple ):    "function doc string"    function_suite    return [expression]
  • Anonymous functions (lambda)
    • Syntax
      ○ lambda [arg1 [, arg2, … argm]]: expression
Flow control
  • Conditionals
    • If <expr>:    <indented block>elif <expr>:    <indented block>else:    <indented block>
  • Loops
    • While <expr>:    <indented block>loop can contain break, continue
    • for <name> in <iterable>:    <indented block>loop can contain break, continue


