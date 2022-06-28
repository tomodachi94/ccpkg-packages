-- ccpkg command line interface
-- (c) tomodachi94 2022
-- mit license

local tArgs = {...}
command = tArgs[1]
packageName = tArgs[2]

os.loadAPI("/lib/ccpkg")

if command == "install" then
	ccpkg.install(packageName)

elseif command == "uninstall" then
	ccpkg.uninstall(packageName)

elseif command == "install-lib" then
	ccpkg.installLib(packageName)

elseif command == "uninstall-lib" then
	ccpkg.uninstallLib(packageName)

elseif command == nil then
	printError("ccpkg: No command specified.")

else
	printError("Invalid command '" .. command .. "'.")
end
