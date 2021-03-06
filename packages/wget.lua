--wget.lua by dan200
--computercraft public license
--src::https://github.com/dan200/ComputerCraft/blob/master/src/main/resources/assets/computercraft/lua/rom/programs/http/wget.lua
local function printUsage()
	print("Usage:")
	print("wget <url> <filename>")
end

local tArgs = {...}
if #tArgs < 2 then
	printUsage()
	return
end

if not http then
	printError("wget requires http API")
	printError("Set http_enable to true in ComputerCraft.cfg")
	return
end

local function get(sUrl)
	write("Connecting to " .. sUrl .. "... ")

	if http.checkURL then -- not all versions of CC have checkURL
		local ok, err = http.checkURL(sUrl)
		if not ok then
			print("Failed.")
			if err then
				printError(err)
			end
			return nil
		end
	end

	local response = http.get(sUrl, nil, true)
	if not response then
		print("Failed.")
		return nil
	end

	print("Success.")

	local sResponse = response.readAll()
	response.close()
	return sResponse
end

-- Determine file to download
local sUrl = tArgs[1]
local sFile = tArgs[2]
local sPath = shell.resolve(sFile)
if fs.exists(sPath) then
	print("File already exists")
	return
end

-- Do the get
local res = get(sUrl)
if res then
	local file = fs.open(sPath, "wb")
	file.write(res)
	file.close()

	print("Downloaded as " .. sFile)
end
