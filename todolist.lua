local argparse =  require("argparse")
local sttf = require("saveTableToFile")

local parser = argparse()
   :name "todolist"
   :description "CLI-Todolist: A simple todolist for the command line."
   :epilog "GitHub: https://github.com/Skayo/CLI-Todolist"

-- Configure command line commands
local addtodo = parser:command("addtodo at", "Add a new todo to the given list")
local newlist = parser:command("newlist nl", "Create a new list")
local deletelist = parser:command("deletelist dl", "Delete the given list")
local done = parser:command("done d", "Set the given todo as done")
local open = parser:command("open o", "Set the given todo as open")
local removedone = parser:command("removedone rd", "Remove the done todos from the given list")
local list = parser:command("list l", "Show all lists or the todos of the given list")

addtodo:argument("name", "The name of your todo (Cannot contain spaces)")
addtodo:argument("list", "The title of the list to add the todo to")
addtodo:option("-n --notice", "Add a optional notice to your todo"):default("")
addtodo:option("-p --priority", "Set the priority of your todo"):args(1):default("0"):convert(tonumber)

newlist:argument("title", "The title of your new list (Cannot contain spaces)")

deletelist:argument("list", "The title of the list you want to delete")

done:argument("todo", "The name of the todo to set as done")
done:argument("list", "The title of the list where the todo is located at")

open:argument("todo", "The name of the todo to set as open")
open:argument("list", "The title of the list where the todo is located at")

removedone:argument("list", "The title of the list to remove the done todos from")

list:argument("list", "The title of the list to show"):default("show_all_lists")

-- Parse command line arguments
local args = parser:parse()

-- Storage
function loadStorage()
	local storage = table.load("storage.lua")
	if storage ~= nil then
		return storage
	else
		return {}
	end
end
function saveStorage(newstorage)
	table.save(newstorage, "storage.lua")
end

local storage = loadStorage()

---- IGNORE -----
-- Used to sort a table
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end
---- IGNORE -----

-- Handle commands
if args.addtodo then
	-- if list does not exist
	if storage[args.list] == nil then
		addtodo:error("No list with title '"..args.list.."'")
	end

	-- if todo does already exist
	if storage[args.list][args.name] ~= nil then
		addtodo:error("Todo '"..args.list.."' already exists")
	end

	-- if priority is not in range 0-3
	if args.priority > 3 or args.priority < 0 then
		addtodo:error("Priority must be in range 0-3")
	end

	-- add new todo to list 
	storage[args.list][args.name] = {state = "open", name = args.name, notice = args.notice, priority = args.priority}

	print("Added new todo '"..args.name.."' to list '"..args.list.."'")
elseif args.newlist then
	-- if list does already exist
	if storage[args.title] ~= nil then
		addtodo:error("List '"..args.title.."' already exists")
	end

	-- add new list
	storage[args.title] = {}

	print("Created new list '"..args.title.."'")
elseif args.deletelist then
	-- if list does not exist
	if storage[args.list] == nil then
		deletelist:error("No list with title '"..args.list.."'")
	end

	-- confirm
	io.write("Delete list '"..args.list.."'?\nThis cannot be undone! (Y/n) ")
	io.flush()
	local answer = io.read()

	if answer ~= 'Y' then print("Cancelled."); os.exit() end

	-- remove list by setting it to nil
	storage[args.list] = nil

	print("Deleted list '"..args.list.."'")
elseif args.done then
	-- if list does not exist
	if storage[args.list] == nil then
		done:error("No list with title '"..args.list.."'")
	end

	-- if todo does not exist
	if storage[args.list][args.todo] == nil then
		done:error("No todo with name '"..args.todo.."'")
	end

	-- set state of todo as done
	storage[args.list][args.todo].state = "done"

	print("Set todo '"..args.todo.."' of list '"..args.list.."' as done")
elseif args.open then
	-- if list does not exist
	if storage[args.list] == nil then
		open:error("No list with title '"..args.list.."'")
	end

	-- if todo does not exist
	if storage[args.list][args.todo] == nil then
		open:error("No todo with name '"..args.todo.."'")
	end

	-- set state of todo as open
	storage[args.list][args.todo].state = "open"

	print("Set todo '"..args.todo.."' of list '"..args.list.."' as open")
elseif args.removedone then
	-- if list does not exist
	if storage[args.list] == nil then
		list:error("No list with title '"..args.list.."'")
	end

	local removedcount = 0
	for k,todo in pairs(storage[args.list]) do
		if todo.state == "done" then
			storage[args.list][todo.name] = nil
			removedcount = removedcount + 1
		end
	end

	print("Removed "..removedcount.." done todos from list '"..args.list.."'")
elseif args.list then
	-- if list does not exist
	if args.list ~= "show_all_lists" and storage[args.list] == nil then
		list:error("No list with title '"..args.list.."'")
	end

	if args.list == "show_all_lists" then
		-- show all lists
		print("-- All lists --")
		for list,todos in pairs(storage) do
			print("\n> "..list)
		end
	else
		-- show contents of given list (sorted by priority)
		print("-- "..args.list.." --")
		for todo,data in spairs(storage[args.list], function(t, a, b) return t[a].priority > t[b].priority end)do
			print("\n> "..todo.."\n   - State: "..data.state.."\n   - Priority: "..data.priority)
			if data.notice ~= "" then print("   - Notice: "..data.notice) end
		end
	end
end

print("\n")

saveStorage(storage)