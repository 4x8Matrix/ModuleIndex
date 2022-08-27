local Signal = require(script.Parent.Signal)

local Timer = { }

function Timer:start()
	self.clock = os.clock()
	self.started:Fire()
end

function Timer:stop()
	self.cancelled:Fire()

	return self._time
end

function Timer:continue()
	self.started:Fire()
end

function Timer:Reset()
	self:stop()
	self:start()
end

function Timer:getTime() 
	return os.clock() - self.clock
end

function Timer:getTimeMS() 
	return math.round((os.clock() - self.clock) * 1000)
end

function Timer:getTimeS() 
	return math.round(os.clock() - self.clock)
end

function Timer:getTimeM() 
	return self:getTimeS() / 60
end

function Timer:getTimeH() 
	return self:getTimeS() / 60 / 60
end

function Timer.new()
    local self = setmetatable({ }, { __index = Timer })

    self._time = 0

    self.cancelled = Signal.new()
    self.started = Signal.new()

    self.started:Connect(function()
        if self.active then
			return
		else
			self.active = true
		end

        self.cancelled:Wait()
        self.active = false
        self._time = os.clock() - self.clock
    end)

    return self
end

return Timer