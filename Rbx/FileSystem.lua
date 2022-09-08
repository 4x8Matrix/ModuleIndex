local FileSystem = { }

function FileSystem.import(module, ...)
	local moduleResolve = require(module)
	local moduleResolveType = type(moduleResolve)

	if moduleResolveType == "table" and moduleResolve.init then
		return moduleResolve.init(...)
	elseif moduleResolveType == "function" then
		return moduleResolve(...)
	else
		return moduleResolve
	end
end

function FileSystem.importChildren(object, ...)
	local childrenModule = { }

	for _, psuedoModule in object:GetChildren() do
		if not psuedoModule:IsA("ModuleScript") then
			continue
		end

		childrenModule[psuedoModule.Name] = FileSystem.import(psuedoModule, ...)
	end

	return childrenModule
end

function FileSystem.importTable(children, ...)
	local childrenModule = { }

	for _, psuedoModule in children do
		if typeof(psuedoModule) == "Instance" and not psuedoModule:IsA("ModuleScript") then
			continue
		end

		childrenModule[psuedoModule.Name] = FileSystem.import(psuedoModule, ...)
	end

	return childrenModule
end

function FileSystem.forEach(object, ...)
	local psuedoModules = object:GetChildren()

	return function(...)
		return next(psuedoModules, ...)
	end
end

return FileSystem
