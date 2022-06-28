-- Credit: http://www.computercraft.info/wiki/Making_a_Password_Protected_Door
-- CONFIG --

local side = "left" -- Change left to whatever side your door / redstone is on, E.G: left, right, front, back, bottom, top. Be sure to leave the "s around it, though
local password = "bacon" -- Change bacon to what you want your password to be. Be sure to leave the "s around it, though
local opentime = 5 -- Change 5 to how long (in seconds) you want the redstone current to be on. Don't put "s around it, though

local pullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

while true do -- infinitely loop this code
	term.clear() -- Clears the screen
	term.setCursorPos(1, 1) -- Fixes the cursor position, a bug on some older CC versions
	write("Password: ")

	local input = read("*") -- Makes the variable 'input' have the contents of what the user types in, the "*" part censors out the password

	if input == password then -- Checks if the user inputted the correct password
		term.clear()
		term.setCursorPos(1, 1)
		print("Password correct!")
		rs.setOutput(side, true) -- Output a redstone current to the side you specified

		sleep(opentime) -- Wait the amount of seconds you specifed, then..
		rs.setOutput(side, false) -- Stop outputting a redstone current
	else -- This block is ran if the password is incorrect
		print("Password incorrect!")
		sleep(2)-- Waits 2 seconds
	end
end
