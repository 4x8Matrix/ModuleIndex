local Vector2 = { }

function Vector2:__tostring()
	return string.format("Vector2: {%d, %d}", self.x, self.y)
end

function Vector2:__mod(Value)
	local typeValue = type(Value)

	if typeValue == "number" then
		return Vector2.new(self.x % Value, self.y % Value)
	elseif typeValue == "table" and Value.__type == "Vector2" then
		return Vector2.new(self.x % Value.x, self.y % Value.y)
	end
end

function Vector2:__div(Value)
	local typeValue = type(Value)

	if typeValue == "number" then
		return Vector2.new(self.x / Value, self.y / Value)
	elseif typeValue == "table" and Value.__type == "Vector2" then
		return Vector2.new(self.x / Value.x, self.y / Value.y)
	end
end

function Vector2:__mul(Value)
	local typeValue = type(Value)

	if typeValue == "number" then
		return Vector2.new(self.x * Value, self.y * Value)
	elseif typeValue == "table" and Value.__type == "Vector2" then
		return Vector2.new(self.x * Value.x, self.y * Value.y)
	end
end

function Vector2:__sub(Value)
	local typeValue = type(Value)

	if typeValue == "table" and Value.__type == "Vector2" then
		return Vector2.new(self.x - Value.x, self.y - Value.y)
	end
end

function Vector2:__add(Value)
	local typeValue = type(Value)

	if typeValue == "table" and Value.__type == "Vector2" then
		return Vector2.new(self.x + Value.x, self.y + Value.y)
	end
end

function Vector2:__unm()
	return Vector2.new(-self.x, -self.y)
end

-- // Functions
function Vector2:Max(vector)
	return Vector2.new(
		(vector.x > self.x and vector.x) or self.x,
		(vector.y > self.y and vector.y) or self.y
	)
end

function Vector2:Min(vector)
	return Vector2.new(
		(vector.x < self.x and vector.x) or self.x,
		(vector.y < self.y and vector.y) or self.y
	)
end

function Vector2:Cross(vector)
	return (vector.y * self.x) - (vector.x * self.y)
end

function Vector2:Angle(vector)
	return math.deg(math.acos(self:Dot(vector) / (vector.magnitude * self.magnitude)))
end

function Vector2:Dot(vector)
	return (vector.x * self.x) + (vector.y * self.y)
end

function Vector2:Lerp(vector, alpha)
	return self + (vector - self) * alpha
end

function Vector2:Normalise()
	return self / self.magnitude
end

function Vector2:Unpack()
	return self.x, self.y
end

function Vector2.new(x, y)
	local self = setmetatable({ x = x or 0, y = y or 0 }, { __index = Vector2 })

	self.magnitude = math.sqrt((self.x ^ 2) + (self.y ^ 2))

	return self
end

return Vector2