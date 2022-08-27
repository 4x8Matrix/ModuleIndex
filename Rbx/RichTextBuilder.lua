local LocalizationService = game:GetService("LocalizationService")
local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")

local STRING_BUILDER_CLASS_NAME = "RichTextBuilder"
local IS_SERVER = RunService:IsServer()
local RGB_MAX_VALUE = 255

type RichTextBuilder = {
	new: (...any) -> RichTextBuilder,

	Bold: () -> RichTextBuilder,
	Upper: () -> RichTextBuilder,
	Lower: () -> RichTextBuilder,
	Break: () -> RichTextBuilder,
	Strike: () -> RichTextBuilder,
	Italic: () -> RichTextBuilder,
	Comment: () -> RichTextBuilder,
	Underline: () -> RichTextBuilder,

	Size: (SizeValue: number) -> RichTextBuilder,
	Font: (FontValue: Enum.Font) -> RichTextBuilder,
	color: (Color3Value: Color3) -> RichTextBuilder,
	Stroke: (color: Color3, thickness: number, transparency: number, joins: Enum.LineJoinMode) -> RichTextBuilder,

	ToString: () -> string,
}

local RichTextBuilder: RichTextBuilder = {
	escapeCharacterSwitch = {
		["<"] = "&lt;",
		[">"] = "&gt;",
		["\""] = "&quot;",
		["'"] = "&apos;",
		["&"] = "&amp;"
	}
}

function RichTextBuilder:color(color3Value)
	self.stack[#self.stack + 1] = {
		string.format(
			"<font color=\"%s\">",
			string.format(
				"rgb(%d, %d, %d)",

				color3Value.R * RGB_MAX_VALUE,
				color3Value.G * RGB_MAX_VALUE,
				color3Value.B * RGB_MAX_VALUE
			)
		),
		"</font>"
	}

	return self
end

function RichTextBuilder:size(sizeValue)
	self.stack[#self.stack + 1] = {
		string.format(
			"<font size=\"%s\">",
			tostring(sizeValue)
		), 
		"</font>"
	}

	return self
end

function RichTextBuilder:font(fontValue)
	local fontName = typeof(fontValue) == "EnumItem" and fontValue.Name or tostring(fontValue)

	assert(Enum.Font[fontName] ~= nil, string.format("Expected Font, got %s", tostring(fontValue)))

	self.stack[#self.stack + 1] = {
		string.format(
			"<font face=\"%s\">",
			fontName
		), 
		"</font>"
	}

	return self
end

function RichTextBuilder:stroke(color, thickness, transparency, joins)
	color = color or "#000000"
	thickness = thickness or 2
	transparency = transparency or 0
	joins = joins or "Miter"

	assert(Enum.LineJoinMode[joins], string.format("Expected LineJoinMode, got %s", tostring(joins)))

	if typeof(color) == "Color3" then
		color = string.format(
			"rgb(%d, %d, %d)",

			color.R * RGB_MAX_VALUE,
			color.G * RGB_MAX_VALUE,
			color.B * RGB_MAX_VALUE
		)
	else
		color = tostring(color)
	end

	self.stack[#self.stack + 1] = {
		string.format(
			"<stroke color=\"%s\" joins=\"%s\" thickness=\"%s\" transparency=\"%s\">",
			color, joins, thickness, transparency
		), 
		"</stroke>"
	}

	return self
end

function RichTextBuilder:bold()
	self.stack[#self.stack + 1] = {
		"<b>",
		"</b>"
	}

	return self
end

function RichTextBuilder:italic()
	self.stack[#self.stack + 1] = {
		"<i>",
		"</i>"
	}

	return self
end

function RichTextBuilder:underline()
	self.stack[#self.stack + 1] = {
		"<u>",
		"</u>"
	}

	return self
end

function RichTextBuilder:strike()
	self.stack[#self.stack + 1] = {
		"<s>",
		"</s>"
	}

	return self
end

function RichTextBuilder:comment()
	self.stack[#self.stack + 1] = {
		"<!--",
		"-->"
	}

	return self
end

function RichTextBuilder:lineBreak()
	self.stack[#self.stack + 1] = {
		"<br/>"
	}

	return self
end

function RichTextBuilder:lower()
	self.stack[#self.stack + 1] = {
		"<smallcaps>",
		"</smallcaps>"
	}

	return self
end

function RichTextBuilder:upper()
	self.stack[#self.stack + 1] = {
		"<uppercase>",
		"</uppercase>"
	}

	return self
end

function RichTextBuilder:toString(player)
	local stringObject = ""
	local translator

	if IS_SERVER then
		if player and player:IsA("player") then
			local success, translatorObject = pcall(LocalizationService.GetTranslatorForPlayerAsync, LocalizationService, player)

			translator = success and translatorObject
		end
	else
		local success, translatorObject = pcall(LocalizationService.GetTranslatorForPlayerAsync, LocalizationService, PlayersService.LocalPlayer)

		translator = success and translatorObject
	end

	for _, sourceAddition in self.Source do
		local sourceAdditionMetatable = type(sourceAddition) == "table" and getmetatable(sourceAddition)

		if not sourceAdditionMetatable or (sourceAdditionMetatable and sourceAdditionMetatable.__class ~= STRING_BUILDER_CLASS_NAME) then
			for key, value in RichTextBuilder.escapeCharacterSwitch do
				sourceAddition = string.gsub(sourceAddition, key, value)
			end
		end

		stringObject ..= string.format(" %s", tostring(sourceAddition))
	end

	if translator then
		stringObject = string.gsub(stringObject, "(%a+)", function(String)
			return translator:Translate(game, String) or String
		end)
	end

	for _, stackLayer in self.stack do
		stringObject = string.format(
			"%s%s%s",
			stackLayer[1],
			stringObject,
			stackLayer[2] or ""
		)
	end

	return string.format("<!-- Generated Text: RichTextBuilder --> %s", stringObject)
end

function RichTextBuilder.new(...)
	return setmetatable({ Source = { ... }, Stack = { } }, {
		__index = RichTextBuilder,
		__class = STRING_BUILDER_CLASS_NAME,
		__tostring = function(self) return self:ToString() end,
		__call = function(self) return self:ToString() end,
		__concat = function(self, value)
			local ConcentratedText = table.clone(self.Source)
			table.insert(ConcentratedText, value)
			local RichTextObject = RichTextBuilder.new(table.unpack(ConcentratedText))

			RichTextObject.Stack = table.clone(self.stack)

			return RichTextObject
		end,
	})
end

return RichTextBuilder