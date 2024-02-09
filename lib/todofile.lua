local io = io
local string = string
local os = os
local error = error
local tonumber = tonumber
local assert = assert
local type = type
local pairs = pairs
local class = require('lib.class')
local utils = require('lib.utils')
local todo = require('lib.todo')


local TYPE_STRING = 'string'
local TODO_LINE_PATTERN = '^%s*(%d-)%.%s*%[([ Xx])%]%s*(.-)%s*$'

---Handles todofile queries, updates and removals
---@class todofile
---@overload fun(path: string): todofile
---@field protected path string
---@field protected todos todo[]
---@field protected transaction boolean?
local todofile = class()

---Create or open the todofile
---@param path string Path to the todofile
function todofile:new(path)
	self.path = path
	self.todos = {}
	self:load()
end

---Save todos to the todofile
---@protected
function todofile:save()
	local file = assert(io.open(self.path, 'w+'))
	for index, curr_todo in pairs(self.todos) do
		file:write(
			index
			.. '. ['
			.. (curr_todo.checked and 'X' or ' ')
			.. '] '
			.. curr_todo.text
			.. '\n'
		)
	end
	file:close()
end

---Load todos from the todofile
---@protected
function todofile:load()
	--reset current todos
	self.todos = {}

	--read file line by line (we use mode 'a+' so it will create the file if not exists)
	local file = assert(io.open(self.path, 'a+'))
	local last_index = nil ---@type number?
	for line in file:lines() do
		if type(line) == TYPE_STRING and #utils.trim(line) > 0 then
			local match1, match2, match3 = string.match(line, TODO_LINE_PATTERN)
			if match1 and match2 and match3 then
				--handle the matches
				local index = tonumber(match1)
				local checked = match2 == 'X' or match2 == 'x'
				local text = utils.trim(match3)
				if not index or #text == 0 or self.todos[index] then
					error('Failed to read todofile')
				end

				--add todo to list
				self.todos[index] = todo(text, checked)
				last_index = index
			elseif last_index then
				--append text to previous todo
				self.todos[last_index].text =
					self.todos[last_index].text .. ' ' .. utils.trim(line)
			end
		end
	end
	file:close()
end

---Move the todofile
---@param new_path string New path of the todofile
function todofile:move(new_path)
	os.rename(self.path, new_path)
	self.path = new_path
end

---Remove the todofile
function todofile:delete()
	os.remove(self.path)
end

---Add a new todo
---@param text string
---@param checked boolean?
function todofile:add_todo(text, checked)
	self.todos[utils.table_max(self.todos) + 1] =
		todo(text, checked)

	if not self.transaction then
		self:save()
	end
end

---Return all todos
---@return todo[]
---@nodiscard
function todofile:get_todos()
	return self.todos
end

---Return all checked todos
---@return todo[]
---@nodiscard
function todofile:get_checked_todos()
	--get list of only checked todos
	local checked_todos = {} ---@type todo[]
	for index, curr_todo in pairs(self.todos) do
		if curr_todo.checked then
			checked_todos[index] = curr_todo
		end
	end

	return checked_todos
end

---Return all unchecked todos
---@return todo[]
---@nodiscard
function todofile:get_unchecked_todos()
	--get list of only unchecked todos
	local unchecked_todos = {} ---@type todo[]
	for index, curr_todo in pairs(self.todos) do
		if not curr_todo.checked then
			unchecked_todos[index] = curr_todo
		end
	end

	return unchecked_todos
end

---Count the number of todos
---@return number
---@nodiscard
function todofile:count_todos()
	local count = 0
	for _, _ in pairs(self.todos) do
		count = count + 1
	end

	return count
end

---Count the number of checked todos
---@return number
---@nodiscard
function todofile:count_checked_todos()
	local count = 0
	for _, curr_todo in pairs(self.todos) do
		if curr_todo.checked then
			count = count + 1
		end
	end

	return count
end

---Count the number of unchecked todos
---@return number
---@nodiscard
function todofile:count_unchecked_todos()
	local count = 0
	for _, curr_todo in pairs(self.todos) do
		if not curr_todo.checked then
			count = count + 1
		end
	end

	return count
end

---Get a specific todo by index or text
---@param index_or_text integer|string Index or text of the todo
---@return todo,integer todo_and_index The todo and the index of the todo
---@nodiscard
function todofile:get_todo(index_or_text)
	--if index was passed, return directly
	if type(index_or_text) == 'number' then
		local found_todo = self.todos[index_or_text]
		if found_todo then
			return found_todo, index_or_text
		else
			error('Todo not found')
		end
	end

	--if text was passed, try to find todo by text
	local found_todo ---@type todo?
	local found_todo_index ---@type integer?
	for index, curr_todo in pairs(self.todos) do
		if string.lower(curr_todo.text) == string.lower(index_or_text) then
			if found_todo then
				error('Multiple todos with given text found - please use index')
			end

			found_todo = curr_todo
			found_todo_index = index
		end
	end
	if not found_todo or not found_todo_index then
		error('Todo not found')
	end

	return found_todo, found_todo_index
end

---Set the text of a todo specified by index or text
---@param index_or_text integer|string Index or text of the todo
---@param new_text string New text of the todo
function todofile:update_todo_text(index_or_text, new_text)
	local found_todo = self:get_todo(index_or_text)
	found_todo.text = new_text

	if not self.transaction then
		self:save()
	end
end

---Set the checked state of a todo specified by index or text
---@param index_or_text integer|string Index or text of the todo
---@param new_checked boolean New checked state of the todo
function todofile:update_todo_checked(index_or_text, new_checked)
	local found_todo = self:get_todo(index_or_text)
	found_todo.checked = new_checked

	if not self.transaction then
		self:save()
	end
end

---Set the text and checked state of a todo specified by index or text
---@param index_or_text integer|string Index or text of the todo
---@param new_text string New text of the todo
---@param new_checked boolean New checked state of the todo
function todofile:update_todo_text_and_checked(index_or_text, new_text, new_checked)
	local old_transaction = self.transaction
	self.transaction = true
	self:update_todo_text(index_or_text, new_text)
	self:update_todo_checked(index_or_text, new_checked)
	self.transaction = old_transaction

	if not self.transaction then
		self:save()
	end
end

---Check a todo specified by index or text
---@param index_or_text integer|string Index or text of the todo
function todofile:check_todo(index_or_text)
	self:update_todo_checked(index_or_text, true)
end

---Uncheck a todo specified by index or text
---@param index_or_text integer|string Index or text of the todo
function todofile:uncheck_todo(index_or_text)
	self:update_todo_checked(index_or_text, false)
end

---Remove a specific todo by index or text
---@param index_or_text integer|string Index or text of the todo
function todofile:remove_todo(index_or_text)
	if type(index_or_text) == 'number' then
		--if index was passed, remove directly
		if self.todos[index_or_text] then
			self.todos[index_or_text] = nil
		else
			error('Todo not found')
		end
	else
		--if text was passed, try to remove todo by text
		local found_todo_index ---@type number?
		for index, curr_todo in pairs(self.todos) do
			if curr_todo.text == index_or_text then
				if found_todo_index then
					error('Multiple todos with given text found - please use index')
				end

				found_todo_index = index
			end
		end
		if not found_todo_index then
			error('Todo not found')
		end

		self.todos[found_todo_index] = nil
	end

	if not self.transaction then
		self:save()
	end
end

---Remove all checked todos
function todofile:remove_checked_todos()
	local old_transaction = self.transaction
	self.transaction = true
	for index, curr_todo in pairs(self.todos) do
		if curr_todo.checked then
			self:remove_todo(index)
		end
	end
	self.transaction = old_transaction

	if not self.transaction then
		self:save()
	end
end

return todofile
