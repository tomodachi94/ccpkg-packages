-- ccpkg api
-- (c) 2022 tomodachi94
-- mit license

if not http then
	printError("ccpkg requires the HTTP API to be enabled.")
	printError("If you are an administrator, set http_enable to true in ComputerCraft.cfg. If you aren't an administrator, there isn't much else you can do other than ask an admin to enable it.")
end

if not settings then
	printError("ccpkg requires the settings API.")
	printError("Please ask your administrator to look into installing a polyfill for it.")
end

local tArgs = {...}
local packageHub = "https://tomodachi94.github.io/ccpkg-packages/"
local destination = "/bin/"
local destinationLib = "/lib/"
local destinationDocs = "/share/help/"
local command = tArgs[1]
local packageName = tArgs[2]

local function getPackage(package)
	local url = packageHub .. "packages" .. package .. '.lua'
	print("Connecting to " .. url .. "... ")
	local response = http.get(url)

	if response then
		print("Success.")

		local sResponse = response.readAll()
		response.close()
		return sResponse
	else
		print("Failed.")
	end
end

local function getLib(lib)
	local url = packageHub .. "lib" .. package .. '.lua'
	print("Connecting to " .. url .. "... ")
	local response = http.get(url)

	if response then
		print("Success.")

		local sResponse = response.readAll()
		response.close()
		return sResponse
	else
		print("Failed.")
	end
end

local function writePackage(file, path)
	--if not fs.exists(path) then
	file1 = fs.open(path, "w")
	file1.write(file)
	file1.flush()
	print("File written to local storage.")
	--end
end

function uninstall(package)
	if fs.exists(destination .. package) then
		fs.delete(destination .. package)
		print("Removed " .. package)
	else
		printError("Package was never installed.")
	end
end

function install(package)
	if not fs.exists(destination..package) then
		packageFile = getPackage(package)
		finalDestination = destination .. package
		writePackage(packageFile, finalDestination)
	else
		printError("Package '"..package.."' already exists.")
	end
end

function installLib(lib)
	if not fs.exists(destinationLib..lib) then
		libFile = getPackage(lib)
		finalDestination = destinationLib .. lib
		writePackage(packageFile, finalDestination)
	else
		printError("Library '"..lib.."' already exists.")
	end
end

-- function exists(package)
--	if fs.exists(destination..package)
--		return fs.exists(destination..package)
--	else
--		return false
--	end
-- end
--

function exec(package)
	if fs.exists(destination..package) then
		shell.run(package)
 end
end

--if not exists("ccpkg") then
--	install("ccpkg")
--end
