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
**Note:** If the name contains spaces, you have to use double (or single) quotes. (See Example)

**Example**:
```
$ ./todolist newlist MyProject

Or with spaces:
$ ./todolist newlist "My Project"
```

## Add a new todo

To add a new todo to a list type
```
$ ./todolist addtodo <name> <list> [-n --notice] [-p --priority]
```

**Optional parameters:**<br>
Use ``--notice <notice>`` (or ``-n <notice>``) to add a notice (details, informations, etc.) to the todo.<br>
*Default: ""*

Use ``--priority <priority>`` (or ``-p <priority>``) to set a priority for the todo. Must be in range 0-3!<br>
*Default: 0*

**Note:** If the name or the notice contains spaces, you have to use double (or single) quotes. (See example)

**Example:**
```
$ ./todolist addtodo Fix-Bugs MyProject -n Issue#123 -p 2

Or with spaces:
$ ./todolist addtodo "Fix Bugs" "My Project" -n "See Issue #123" -p 2
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

Oh wait... They aren't:
$ ./todolist open Fix-Bugs MyProject
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
