# CLI-Todolist
A simple todolist written in Lua for the command line interface.

# Requirements

- Lua - 5.1.x or newer
- LuaRocks - 2.x or newer

(Older versions not tested)

# Installation

```
$ luarocks install argparse
```

# How to use

```
$ ./todolist <command> <arguments>
```

## Help

For generic help type
```
$ ./todolist -h
```

For help about a command type
```
$ ./todolist <command> -h
```

## Create new list

To create a new list type
```
$ ./todolist newlist <title>
```
**Note:** The title of the list can't contain any spaces!

**Example**:
```
$ ./todolist newlist MyProject
```

## Add a new todo

To add a new todo to a list type
```
$ ./todolist addtodo <name> <list>
```
**Note:** The name of the todo can't contain any spaces!

**Example:**
```
$ ./todolist addtodo Fix-Bugs MyProject
```

## Set todo as done/open

To set a todo as done type
```
$ ./todolist done <todo> <list>
```

To set a todo as open type
```
$ ./todolist open <todo> <list>
```

**Example:**
```
$ ./todolist done Fix-Bugs MyProject
```

## Remove done todos

To remove all done todos from a list type
```
$ ./todolist removedone <list>
```

**Example:**
```
$ ./todolist removedone MyProject
```

## Show all lists

To show all lists type
```
$ ./todolist list
```

## Show all todos in list

To show all todos in a list type
```
$ ./todolist list <list>
```

**Example:**
```
$ ./todolist list MyProject
```

## Delete a list

To remove a list type
```
$ ./todolist deletelist <list>
```

**Example:**
```
$ ./todolist deletelist MyProject
Delete list 'MyProject'?
This cannot be undone! (Y/n) Y
```
