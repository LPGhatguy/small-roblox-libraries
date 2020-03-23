return function()
	local PrioritySignal = require(script.Parent)

	it("should pass all arguments through", function()
		local signal = PrioritySignal.new()

		local args
		local argsLength

		signal:connect(1, function(...)
			argsLength = select("#", ...)
			args = {...}
		end)
		signal:fire("a", 2, nil)

		expect(argsLength).to.equal(3)
		expect(args[1]).to.equal("a")
		expect(args[2]).to.equal(2)
		expect(args[3]).to.equal(nil)
	end)

	it("should disconnect listeners", function()
		local signal = PrioritySignal.new()

		local aCalled = false
		signal:connect(1, function()
			aCalled = true
		end)

		local bCalled = false
		local bDisconnect = signal:connect(1, function()
			bCalled = true
		end)

		bDisconnect()
		signal:fire()
		assert(aCalled)
		assert(not bCalled)
	end)

	it("should disconnect listeners, even when they're about to be fired", function()
		local signal = PrioritySignal.new()

		local disconnectB
		signal:connect(1, function()
			disconnectB()
		end)

		local bCalled = false
		disconnectB = signal:connect(2, function()
			bCalled = true
		end)

		signal:fire()
		assert(not bCalled)
	end)

	it("should fire listeners in priority order", function()
		local signal = PrioritySignal.new()

		local aCalled = false
		local bCalled = false

		signal:connect(2, function()
			assert(bCalled)
			aCalled = true
		end)

		signal:connect(1, function()
			assert(not aCalled)
			bCalled = true
		end)

		signal:fire()
		assert(aCalled)
		assert(bCalled)
	end)
end