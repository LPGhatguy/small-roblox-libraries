# PrioritySignal
Simple signal class that requires assigning a priority to each listener. When the signal is fired, listeners are always invoked in *ascending priority*.

## Example
```lua
local signal = PrioritySignal.new()

local disconnect1 = signal:connect(2, function(value)
	print("priority 2:", value)
end)

local disconnect2 = signal:connect(1, function(value)
	print("priority 1:", value)
end)

signal:fire("hello")

-- Output:
-- priority 1: hello
-- priority 2: hello
```

## Notable Properties

Common edge cases that are handled:
- It is safe to disconnect listeners while the signal is firing.
- If a listener is disconnected, it will _never_ be invoked again, even if disconnected while the signal is firing.
- If a listener throws or yields, all other listeners will continue executing.