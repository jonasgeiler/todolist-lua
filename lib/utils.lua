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

---Returns the largest positive numerical index of the given table,
---or zero if the table has no positive numerical indices
---@param tbl any[]
---@return integer
function utils.table_max(tbl)
	if table.maxn then
		return table.maxn(tbl)
	else
		--table.maxn was removed in Lua 5.2+, polyfill:
		local max = 0
		local i = next(tbl)
		while i do
			if type(i) == 'number' and i > max then
				max = i
			end
			i = next(tbl, i)
		end

		return max
	end
end

return utils
