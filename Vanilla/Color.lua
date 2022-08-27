local Color = { __type = "Color" }

function Color:__tostring()
	return string.format("<Color> [%d, %d, %d]", self.r, self.g, self.b)
end

function Color:__div(Value)
	local typeValue = type(Value)

	if typeValue == "number" then
		return Color.new(self.r / Value, self.b / Value,  self.g / Value)
	elseif typeValue == "table" and Value.__type == "Color" then
		return Color.new(self.r / Value.r, self.b / Value.b, self.g / Value.g)
	end
end

function Color:__mul(Value)
	local typeValue = type(Value)

	if typeValue == "number" then
		return Color.new(self.r * Value, self.b * Value,  self.g * Value)
	elseif typeValue == "table" and Value.__type == "Color" then
		return Color.new(self.r * Value.r, self.b * Value.b, self.g * Value.g)
	end
end

function Color:__sub(Value)
	local typeValue = type(Value)

	if typeValue == "number" then
		return Color.new(self.r - Value, self.b - Value,  self.g - Value)
	elseif typeValue == "table" and Value.__type == "Color" then
		return Color.new(self.r - Value.r, self.b - Value.b, self.g - Value.g)
	end
end

function Color:__add(Value)
	local typeValue = type(Value)

	if typeValue == "number" then
		return Color.new(self.r + Value, self.b + Value,  self.g + Value)
	elseif typeValue == "table" and Value.__type == "Color" then
		return Color.new(self.r + Value.r, self.b + Value.b,  self.g + Value.g)
	end
end

function Color:unpack()
	return self.r / 255, self.g / 255, self.b / 255
end

function Color.new(r, g, b)
	local self = setmetatable({ r = r, g = g, b = b }, { __index = Color })

	return self
end

return Color