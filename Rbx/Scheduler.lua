local GENERIC_THREAD_WORKER_NAME = "ActiveThreadWorker"

local Scheduler = { }

Scheduler.Awaiting = { }
Scheduler.Schedule = { }
Scheduler.Workers = { }

function Scheduler.worker(id)
	while true do
		while #Scheduler.Schedule > 0 do
			local jobInformation = table.remove(Scheduler.Schedule, 1)

			Scheduler.Workers[id] = true

			jobInformation.processed = true

			xpcall(function()
				local resolvedValues = { jobInformation.Instance[jobInformation.Method](table.unpack(jobInformation.Parameters)) }

				jobInformation:accept(resolvedValues)
			end, function(exception)
				jobInformation:reject(exception)
			end)
		end

		task.wait()

		Scheduler.Workers[id] = false
	end
end

function Scheduler.job(object, method, ...)
	local jobObject = { }

	local jobAwaiters = { }
	local jobBinds = { }

	jobObject.Instance = object
	jobObject.Method = method
	jobObject.Parameters = { ... }

	jobObject.Return = { }

	function jobObject:await()
		if jobObject.processed then
			return jobObject.Success, jobObject.Return
		else
			jobAwaiters[#jobAwaiters + 1] = coroutine.running()

			return coroutine.yield()
		end
	end

	function jobObject:bind(callback)
		jobBinds[#jobBinds + 1] = callback

		if jobObject.processed then
			callback(jobObject.Success, jobObject.Return)
		end

		return function()
			local index = table.find(jobBinds, callback)

			if index then
				table.remove(jobBinds, index)
			end
		end
	end

	function jobObject:accept(returnValues)
		jobObject.Return = returnValues
		jobObject.Success = true

		for _, awaitingThread in jobAwaiters do
			task.spawn(awaitingThread, jobObject.Success, jobObject.Return)
		end

		for _, connectionObject in jobBinds do
			task.spawn(connectionObject, jobObject.Success, jobObject.Return)
		end
	end

	function jobObject:reject(exception)
		jobObject.Return = exception
		jobObject.Success = false

		for _, awaitingThread in jobAwaiters do
			task.spawn(awaitingThread, jobObject.Success, jobObject.Return)
		end

		for _, connectionObject in jobBinds do
			task.spawn(connectionObject, jobObject.Success, jobObject.Return)
		end
	end

	table.insert(Scheduler.Schedule, jobObject)

	return jobObject
end

task.spawn(Scheduler.worker, GENERIC_THREAD_WORKER_NAME)

return Scheduler