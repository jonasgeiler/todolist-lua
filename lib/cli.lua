local argparse = require('lib.vendor.argparse')
local todofile = require('lib.todofile')

--- TODO: Finish CLI
--- Commands:
--- * todolist add ./todo.md 'Do the dishes'
--- * todolist check ./todo.md 'Do the dishes'
--- * todolist check ./todo.md 1
--- * todolist uncheck ./todo.md 'Do the dishes'
--- * todolist uncheck ./todo.md 1
--- * todolist list ./todo.md
--- * todolist list ./todo.md --checked
--- * todolist list ./todo.md --unchecked
--- * todolist list ./todo.md --quiet   # only shows the list without the fancy stuff
--- * todolist get ./todo.md 'Do the dishes'
--- * todolist get ./todo.md 1
--- * todolist update ./todo.md 'Do the dishes' 'Do the dishes tomorrow'
--- * todolist update ./todo.md 1 'Do the dishes tomorrow'
--- * todolist remove ./todo.md 'Do the dishes'
--- * todolist remove ./todo.md 1
--- * todolist remove-checked ./todo.md  # no shorthand for this one since destructive
---
--- Also provide shorthands for the commands above!
--- Also maybe allow the legacy commands for "backwards compatibility"

--common epilogues
local epilog_help = 'Run "todolist <command> --help" for more information on a command.'
local epilog_link = 'For bugs and questions, head to https://github.com/jonasgeiler/todolist-lua'

--init the cli
local cli = argparse('todolist', 'A simple todolist for the command line')
	:epilog(epilog_help .. '\n' .. epilog_link)
	:add_help_command()

---Converter which converts the todo index or text argument into number or string
---@param todoindexortext string The raw argument
---@return string|number index_or_text The argument parsed as either a number or string
local function convert_todoindexortext(todoindexortext)
	local index_or_text = tonumber(todoindexortext) or todoindexortext
	if type(index_or_text) == 'number' and (index_or_text < 1 or index_or_text ~= math.floor(index_or_text)) then
		cli:error('Invalid todo index or text given')
	end
	return index_or_text
end

local add_cmd = cli:command('add a', 'Add a new todo to a todofile')
	:hidden_name('addtodo at') --old version aliases
	:epilog(epilog_link)
add_cmd:argument('todofile', 'The todofile to use')
add_cmd:argument('todotext', 'The text of the todo to add')
add_cmd:flag('-c --checked', 'Add the todo in an already checked state')
---@param args {add:true,todofile:string,todotext:string,checked:boolean?}
add_cmd:action(function(args)
	local tf = todofile(args.todofile)
	tf:add_todo(args.todotext, args.checked)
end)

local check_cmd = cli:command('check c', 'Check a todo in a todofile')
	:hidden_name('done d') --old version aliases
	:epilog(epilog_link)
check_cmd:argument('todofile', 'The todofile to use')
check_cmd:argument('todoindexortext', 'The index or text of the todo to check')
	:convert(convert_todoindexortext)
---@param args {check:true,todofile:string,todoindexortext:string|integer}
check_cmd:action(function(args)
	local tf = todofile(args.todofile)
	tf:check_todo(args.todoindexortext)
end)

local uncheck_cmd = cli:command('uncheck u', 'Uncheck a todo in a todofile')
	:hidden_name('open o') --old version aliases
	:epilog(epilog_link)
uncheck_cmd:argument('todofile', 'The todofile to use')
uncheck_cmd:argument('todoindexortext', 'The index or text of the todo to uncheck')
	:convert(convert_todoindexortext)
---@param args {uncheck:true,todofile:string,todoindexortext:string|integer}
uncheck_cmd:action(function(args)
	local tf = todofile(args.todofile)
	tf:uncheck_todo(args.todoindexortext)
end)

local list_cmd = cli:command('list l', 'List all todos in a todofile')
	:epilog(epilog_link)
list_cmd:argument('todofile', 'The todofile to use')
list_cmd:mutex(
	list_cmd:flag('-c --checked', 'Show only checked todos'),
	list_cmd:flag('-u --unchecked', 'Show only unchecked todos')
)
list_cmd:flag('-q --quiet', 'Don\'t print a header')
---@param args {list:true,todofile:string,checked:boolean?,unchecked:boolean?,quiet:boolean?}
list_cmd:action(function(args)
	local tf = todofile(args.todofile)

	if not args.quiet then
		local header = 'Todolist "'
			.. args.todofile
			.. '" - '
			.. tf:count_todos()
			.. ' todos ('
			.. tf:count_unchecked_todos()
			.. ' unchecked, '
			.. tf:count_checked_todos()
			.. ' checked)'
		print(header)
		print(string.rep('-', #header))
	end

	local todos = {}
	if args.checked then
		todos = tf:get_checked_todos()
	elseif args.unchecked then
		todos = tf:get_unchecked_todos()
	else
		todos = tf:get_todos()
	end

	for index, todo in pairs(todos) do
		print(
			index
			.. '. ['
			.. (todo.checked and 'X' or ' ')
			.. '] '
			.. todo.text
		)
	end
end)

local get_cmd = cli:command('get g', 'Get a todo from a todofile')
	:epilog(epilog_link)
get_cmd:argument('todofile', 'The todofile to use')
get_cmd:argument('todoindexortext', 'The index or text of the todo to retrieve')
	:convert(convert_todoindexortext)
---@param args {get:true,todofile:string,todoindexortext:string|integer}
get_cmd:action(function(args)
	local tf = todofile(args.todofile)
	local todo, index = tf:get_todo(args.todoindexortext)

	print(
		index
		.. '. ['
		.. (todo.checked and 'X' or ' ')
		.. '] '
		.. todo.text
	)
end)

local update_cmd = cli:command('update n', 'Update the text of a todo in a todofile')
	:epilog(epilog_link)
update_cmd:argument('todofile', 'The todofile to use')
update_cmd:argument('todoindexortext', 'The index or text of the todo to update')
	:convert(convert_todoindexortext)
update_cmd:argument('newtodotext', 'The new text of the todo')
update_cmd:mutex(
	update_cmd:flag('-c --check', 'Also check the todo'),
	update_cmd:flag('-u --uncheck', 'Also uncheck the todo')
)
---@param args {update:true,todofile:string,todoindexortext:string|integer,newtodotext:string,check:boolean?,uncheck:boolean?}
update_cmd:action(function(args)
	local tf = todofile(args.todofile)

	if args.check then
		tf:update_todo_text_and_checked(args.todoindexortext, args.newtodotext, true)
	elseif args.uncheck then
		tf:update_todo_text_and_checked(args.todoindexortext, args.newtodotext, false)
	else
		tf:update_todo_text(args.todoindexortext, args.newtodotext)
	end
end)

local remove_cmd = cli:command('remove', 'Remove a todo from a todofile')
	:epilog(epilog_link)
remove_cmd:argument('todofile', 'The todofile to use')
remove_cmd:argument('todoindexortext', 'The index or text of the todo to remove')
	:convert(convert_todoindexortext)
---@param args {remove:true,todofile:string,todoindexortext:string|integer}
remove_cmd:action(function(args)
	local tf = todofile(args.todofile)
	tf:remove_todo(args.todoindexortext)
end)

local remove_checked_cmd = cli:command('remove-checked', 'Remove all checked todos from a todofile')
	:hidden_name('removedone rd')
	:epilog(epilog_link)
remove_checked_cmd:argument('todofile', 'The todofile to use')
---@param args {remove:true,todofile:string}
remove_checked_cmd:action(function(args)
	local tf = todofile(args.todofile)
	tf:remove_checked_todos()
end)

return cli
