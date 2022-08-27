local MutexLock = { }

function MutexLock:lock()
	self._locked = true
	self._thread = coroutine.running()

	if self.callback then
		self.callback()
	end
end

function MutexLock:unlock(force)
	if not force and self._thread then
		assert(self._thread == coroutine.running(), "Thread Exception: Attempted to call Mutex.unlock")
	end

	self._thread = nil
	self._locked = false
end

function MutexLock:timeout(int)
	self._locked = true
	self._Timeout = {
		T = os.time(), int = int
	}

	if self.callback then 
		self.callback(true, int) 
	end
end

function MutexLock:IsLocked()
	if self._Timeout then
		if os.time() - self._Timeout.T >= self._Timeout.int then
			self._Timeout = false
			self._locked = false

			return false
		end
	end

	return self._locked
end

function MutexLock.new(callback)
	return setmetatable({ callback = callback, _locked = false }, MutexLock)
end

return MutexLock