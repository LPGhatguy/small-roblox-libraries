--[[
	PrioritySignal is a simple signal implementation where listeners are ordered
	based on a priority value.
]]

--[[
	Run a function in a new thread, insulating other code from errors and
	yields.

	Re-uses the same BindableEvent instance in a way that should be safe.
]]
local bindable = Instance.new("BindableEvent")
local function exec(callback, ...)
	local args = {...}
	local argsLen = select("#", ...)

	local connection
	connection = bindable.Event:Connect(function()
		connection:Disconnect()
		callback(unpack(args, 1, argsLen))
	end)
	bindable:Fire()
end

--[[
	Construct a listener that is used in PrioritySignal's listener list.
]]
local function createListener(priority, callback)
	return {
		-- A number priority value, which is used to order listeners.
		priority = priority,

		-- The callback to invoke when the signal is fired.
		callback = callback,

		-- Whether this listener is still eligible to be invoked.
		--
		-- This value is important to ensure that disconnected listeners are not
		-- accidentally invoked when they're disconnected in the middle of the
		-- signal being fired.
		connected = true,
	}
end

--[[
	Construct a new listeners table with the given listener inserted into the
	correct position. Does not modify listeners and instead returns a new table
	to prevent iterator invalidation issues and simplfiy insertion.
]]
local function insertListener(listeners, listenerToAdd)
	-- Whether we've inserted listenerToAdd into our new listener table yet.
	local needToInsert = true

	local newListeners = {}

	for _, listener in ipairs(listeners) do
		if needToInsert and listener.priority > listenerToAdd.priority then
			table.insert(newListeners, listenerToAdd)
			needToInsert = false
		end

		table.insert(newListeners, listener)
	end

	if needToInsert then
		-- If we've reached here, listenerToAdd has the highest priority value,
		-- so we can push it onto the end.
		table.insert(newListeners, listenerToAdd)
	end

	return newListeners
end

--[[
	Construct a new listeners table without the given listener.
]]
local function removeListener(listeners, listenerToRemove)
	local newListeners = {}

	for _, listener in ipairs(listeners) do
		if listener ~= listenerToRemove then
			table.insert(newListeners, listener)
		end
	end

	return newListeners
end

local PrioritySignal = {}
PrioritySignal.__index = PrioritySignal

function PrioritySignal.new()
	local self = {
		-- A sorted list of listeners, constructed by createListener, to invoke
		-- when this signal is fired.
		__listeners = {},
	}

	return setmetatable(self, PrioritySignal)
end

--[[
	Connect a new listener to the PrioritySignal with the given priority.

	Listeners with a lower priority value will be fired first.

	Returns a function that can be called to disconnect the listener.
]]
function PrioritySignal:connect(priority, callback)
	local thisListener = createListener(priority, callback)
	self.__listeners = insertListener(self.__listeners, thisListener)

	local function disconnect()
		-- If we've already disconnected this listener, we don't need to do
		-- anything.
		if not thisListener.connected then
			return
		end

		thisListener.connected = false
		self.__listeners = removeListener(self.__listeners, thisListener)
	end

	return disconnect
end

function PrioritySignal:fire(...)
	for _, listener in ipairs(self.__listeners) do
		if listener.connected then
			exec(listener.callback, ...)
		end
	end
end

return PrioritySignal