local string = string
local utils = {}


local LINE_TRIM_PATTERN = '^%s*(.-)%s*$'

---Trim leading and trailing whitespace form string
---@param str string
---@return string
---@nodiscard
function utils.trim(str)
	return string.match(str, LINE_TRIM_PATTERN)
end

return utils
