-- ccpkg api
-- (c) 2022 tomodachi94
-- mit license
 
if not http then
    printError("ccpkg requires the HTTP API to be enabled.")
    printError("If you are an administrator, set http_enable to true in ComputerCraft.cfg. If you aren't an administrator, there isn't much else you can do other than ask an admin to enable it.")
end
 
docs = {} -- documentation for all methods is located in this table, call print(ccpkg.docs["docs"]) for more information.
 
docs["docs"] = "A table which contains docs for all methods in the ccpkg API. Local methods are prefixed by 'local'."
 
local packageHub = "tomodachi94.github.io/ccpkg-packages/"
local destination = "/bin/"
local destinationHelp = "/share/help/" -- unused
local destinationLib = "/lib/"
 
docs["local.getFromHub"] = "Gets a file from sHub/sSubDir/sPackage.sExtension. sExtension defaults to .lua, for backwards compatibility."
local function getFromHub(sHub, sSubDir, sPackage, sExtension)
	sExtension = sExtension or ".lua" -- default sExtension to .lua
    local url = "https://" .. fs.combine(fs.combine(sHub, sSubDir), sPackage..sExtension)
    --print(url)
    --print(sPackage)
    print("Connecting to " .. url .. "... ")
    local response, httpError = http.get(url)
 
    if response then
        print("Success.")
 
        local sResponse = response.readAll()
        response.close()
        return sResponse
    else
        printError("HTTP request failed with the following error:")
        printError(httpError)
        return false
    end
end
 
docs["local.write"] = "Writes a file to the specified path."
local function write(sContent, sPath)
	if sContent then -- Checking to make sure content is there, to prevent writing an empty file
	    file1 = fs.open(sPath, "w")
	    file1.write(sContent)
	    file1.flush()
	    print("File written to local storage.")
	else
		return false
	end
end
 
docs["uninstall"] = "Removes a file from /bin/package if it exists."
function uninstall(sPackage)
    if fs.exists(destination .. sPackage) then
        fs.delete(destination .. sPackage)
        print("Removed " .. sPackage)
    else
        printError("Package '"..sPackage.."' was never installed.")
    end
end
 
docs["uninstallHelp"] = "Removes a file from /share/help/package if it exists."
function uninstallHelp(sPackage)
    if fs.exists(destinationHelp .. sPackage) then
        fs.delete(destinationHelp .. sPackage)
        print("Removed help for " .. sPackage)
    else
        printError("Help for package '"..sPackage.."' was never installed.")
    end
end
 
docs["uninstallLib"] = "Removes a file from /lib/lib if it exists, in a similar fashion to ccpkg.uninstall."
function uninstallLib(sPackage)
    if fs.exists(destinationLib .. sPackage) then
        fs.delete(destinationLib .. sPackage)
        print("Removed library " .. sPackage)
    else
        printError("Library '"..sPackage.."' was never installed.")
    end
end
 
docs["install"] = "Installs a package 'package' to /bin/."
function install(sPackage)
    if not fs.exists(destination..sPackage) and sPackage then
        local packageFile = getFromHub(packageHub, "bin", sPackage)
        local finalDestination = destination .. sPackage
        write(packageFile, finalDestination)
    --else
        --printError("Package '"..package.."' already exists.")
    end
end
 
docs["installHelp"] = "Installs help for a package 'package' to /share/help."
function installHelp(sPackage)
    if not fs.exists(destination..sPackage) and sPackage then
        local packageFile = getFromHub(packageHub, "help", sPackage, ".txt")
        local finalDestination = destinationHelp .. sPackage
        write(packageFile, finalDestination)
    --else
        --printError("Help for package '"..package.."' already exists.")
    end
end
 
docs["installLib"] = "Installs a library 'lib' to /lib/, in a similar fashion to ccpkg.install."
function installLib(sPackage)
    if not fs.exists(destinationLib..sPackage) then
        packageFile = getFromHub(packageHub, "lib", sPackage)
        finalDestination = destinationLib .. sPackage
        write(packageFile, finalDestination)
    else
        printError("Library '"..sPackage.."' already exists.")
    end
end
 
docs["exec"] = "Executes a package 'package' with arguments 'arguments'."
function exec(package, arguments)
    if fs.exists(destination..package.." "..arguments) then
        shell.run(package)
    end
end
