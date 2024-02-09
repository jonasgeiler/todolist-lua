local tonumber = tonumber
local type = type
local math = math
local print = print
local pairs = pairs
local argparse = require('lib.vendor.argparse')
local todofile = require('lib.todofile')

--common help message epilogues used below
local epilog_help = 'Run "todolist <command> --help" for more information on a command.'
local epilog_link = 'For bugs and questions, head to https://github.com/jonasgeiler/todolist-lua'

--init the cli
local cli = argparse('todolist', 'A simple todolist for the command line')
	:epilog(epilog_help .. '\n' .. epilog_link)
	:add_help_command()

---Converter which converts the todo index or text argument into number or string
---@param raw_index_or_text string The raw argument
---@return string|number index_or_text The argument parsed as either a number or string
local function convert_index_or_text(raw_index_or_text)
	local index_or_text = tonumber(raw_index_or_text) or raw_index_or_text
	if type(index_or_text) == 'number' and (index_or_text < 1 or index_or_text ~= math.floor(index_or_text)) then
		cli:error('Invalid todo index or text given')
	end
	return index_or_text
end


--implement the 'add' command, which adds a todo
local add_cmd = cli:command('add a', 'Add a new todo to a todofile')
	:hidden_name('addtodo at') --old version aliases
	:epilog(epilog_link)
add_cmd:argument('todofile_path', 'The path to the todofile to use')
add_cmd:argument('text', 'The text of the todo to add')
add_cmd:flag('-c --checked', 'Add the todo in an already checked state')

---@param args { todofile_path: string, text: string, checked: boolean? }
add_cmd:action(function(args)
	local tf = todofile(args.todofile_path)
	tf:add_todo(args.text, args.checked)
end)


--implement the 'check' command, which checks a todo
local check_cmd = cli:command('check c', 'Check a todo in a todofile')
	:hidden_name('done d') --old version aliases
	:epilog(epilog_link)
check_cmd:argument('todofile_path', 'The path to the todofile to use')
check_cmd:argument('index_or_text', 'The index or text of the todo to check')
	:convert(convert_index_or_text)

---@param args { todofile_path: string, index_or_text: string|number }
check_cmd:action(function(args)
	local tf = todofile(args.todofile_path)
	tf:check_todo(args.index_or_text)
end)


--implement the 'uncheck' command, which unchecks a todo
local uncheck_cmd = cli:command('uncheck u', 'Uncheck a todo in a todofile')
	:hidden_name('open o') --old version aliases
	:epilog(epilog_link)
uncheck_cmd:argument('todofile_path', 'The path to the todofile to use')
uncheck_cmd:argument('index_or_text', 'The index or text of the todo to uncheck')
	:convert(convert_index_or_text)

---@param args { todofile_path: string, index_or_text: string|number }
uncheck_cmd:action(function(args)
	local tf = todofile(args.todofile_path)
	tf:uncheck_todo(args.index_or_text)
end)


--implement the 'list' command, which lists all todos
local list_cmd = cli:command('list l', 'List all todos in a todofile')
	:epilog(epilog_link)
list_cmd:argument('todofile_path', 'The path to the todofile to use')
list_cmd:mutex(
	list_cmd:flag('-c --checked', 'Show only checked todos'),
	list_cmd:flag('-u --unchecked', 'Show only unchecked todos')
)
list_cmd:flag('-q --quiet', 'Don\'t print the header')

---@param args { todofile_path: string, checked: boolean?, unchecked: boolean?, quiet: boolean? }
list_cmd:action(function(args)
	local tf = todofile(args.todofile_path)

	if not args.quiet then
		local header = 'Todolist "'
			.. args.todofile_path
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


--implement the 'get' command, which retrieves a todo
local get_cmd = cli:command('get g', 'Get a todo from a todofile')
	:epilog(epilog_link)
get_cmd:argument('todofile_path', 'The path to the todofile to use')
get_cmd:argument('index_or_text', 'The index or text of the todo to retrieve')
	:convert(convert_index_or_text)

---@param args { todofile_path: string, index_or_text: string|number }
get_cmd:action(function(args)
	local tf = todofile(args.todofile_path)
	local todo, index = tf:get_todo(args.index_or_text)

	print(
		index
		.. '. ['
		.. (todo.checked and 'X' or ' ')
		.. '] '
		.. todo.text
	)
end)


--implement the 'update' command, which updates a todo
local update_cmd = cli:command('update s', 'Update the text of a todo in a todofile')
	:epilog(epilog_link)
update_cmd:argument('todofile_path', 'The path to the todofile to use')
update_cmd:argument('index_or_text', 'The index or text of the todo to update')
	:convert(convert_index_or_text)
update_cmd:argument('new_text', 'The new text of the todo')
update_cmd:mutex(
	update_cmd:flag('-c --check', 'Also check the todo'),
	update_cmd:flag('-u --uncheck', 'Also uncheck the todo')
)

---@param args { todofile_path: string, index_or_text: string|number, new_text: string, check: boolean?, uncheck: boolean? }
update_cmd:action(function(args)
	local tf = todofile(args.todofile_path)

	if args.check then
		tf:update_todo_text_and_checked(args.index_or_text, args.new_text, true)
	elseif args.uncheck then
		tf:update_todo_text_and_checked(args.index_or_text, args.new_text, false)
	else
		tf:update_todo_text(args.index_or_text, args.new_text)
	end
end)


--implement the 'remove' command, which removes a todo
local remove_cmd = cli:command('remove', 'Remove a todo from a todofile')
	:epilog(epilog_link)
remove_cmd:argument('todofile_path', 'The path to the todofile to use')
remove_cmd:argument('index_or_text', 'The index or text of the todo to remove')
	:convert(convert_index_or_text)

---@param args { todofile_path: string, index_or_text: string|number }
remove_cmd:action(function(args)
	local tf = todofile(args.todofile_path)
	tf:remove_todo(args.index_or_text)
end)


--implement the 'remove-checked' command, which removaes all checked todos
local remove_checked_cmd = cli:command('remove-checked', 'Remove all checked todos from a todofile')
	:hidden_name('removedone rd')
	:epilog(epilog_link)
remove_checked_cmd:argument('todofile_path', 'The path to the todofile to use')

---@param args { todofile_path: string }
remove_checked_cmd:action(function(args)
	local tf = todofile(args.todofile_path)
	tf:remove_checked_todos()
end)


return cli
