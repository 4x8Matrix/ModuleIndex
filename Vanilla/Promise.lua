local Promise = { }

function Promise:get()
	if self.rejected or self.resolved then
		return unpack(self.result)
	end
end

function Promise:finally(callback)
	self._FinallyCallback = callback

	if self.rejected or self.resolved then
		self._cancel = true

		callback(self, unpack(self.result))
	end

	return self
end

function Promise:catch(callback)
	self._catchCallback = callback

	if self.rejected then
		callback(self, unpack(self.result))
	end

	return self
end

function Promise:andThen(callback)
	table.insert(self._stack, callback)

	if self.rejected or self.resolved then 
		callback(self, unpack(self.result))
	end

	return self
end

function Promise:cancel()
	self._cancel = true
end

function Promise:retry()
	self.rejected = nil
	self.resolved = nil
	self._cancel = nil

	return (self.parameters and self(unpack(self.parameters))) or self()
end

function Promise:await()
	if self.rejected or self.resolved then 
		return self
	else
		table.insert(self._await, coroutine.running())

		return coroutine.yield()
	end
end

function Promise:resolve(...)
	if self.rejected or self.resolved then
		return
	end

	self.resolved = true
	self.result = { ... }

	for _, thread in self._await do
		coroutine.resume(thread, self, ...)
	end

	for _, callback in self._stack do
		callback(self, ...)

		if self._cancel then
			self._cancel = nil

			break
		end
	end

	if self._FinallyCallback then
		self._FinallyCallback(self, ...)
	end

	self._await = { }
end

function Promise:reject(...)
	if self.rejected or self.resolved then 
		return
	end

	self.rejected = true
	self.result = { ... }

	for _, thread in self._await do
		coroutine.resume(thread, self, ...)
	end

	if self._catchCallback then
		self._catchCallback(self, ...)
	else
		print(string.format("Unhandled Promise Rejection: [ %s ]", table.concat(self.result, ", ")))
	end
end

function Promise.new(func)
	return setmetatable({ _function = func, _stack = { }, _await = { } }, {
		__index = Promise,
		__call = function(self, ...)
			if self.rejected or self.resolved then
				return table.unpack(self.result)
			end

			self.parameters = { ... }

			local thread = coroutine.create(self._function)
			local success, result = coroutine.resume(thread, self, ...)

			if not success then
				self:Reject(result)
			end

			return self
		end
	})
end

function Promise.Wrap(func, ...)
	return Promise.new(function(object, ...)
		local result = { pcall(func, ...) }

		return (table.remove(result, 1) and object:resolve(unpack(result))) or object:reject(unpack(result))
	end, ...)
end

function Promise.Settle(Promises)
	for _, object in ipairs(Promises) do
		object:Await()
	end
end

function Promise.AwaitSuccess(object)
	repeat
		object:Await()
	until Promise.resolved

	return object:Get()
end

return Promise