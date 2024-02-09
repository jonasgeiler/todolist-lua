local tostring = tostring
local class = require('lib.class')

---Represents a todo item
---@class todo
---@overload fun(text: string, checked: boolean?): todo
---@field public text string
---@field public checked boolean
local todo = class()

---Init the todo
---@param text string Text of the todo
---@param checked boolean? Whether the todo is checked or not
function todo:new(text, checked)
	self.text = text
	self.checked = checked or false
end

---Returns a string representation of the todo
---@return string
---@nodiscard
function todo:__tostring()
	return '{ '
		.. 'text = "' .. self.text .. '", '
		.. 'checked = ' .. tostring(self.checked)
		.. ' }'
end

return todo
