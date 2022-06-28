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
local destinationLib = "/lib"
 
docs["local.getFromHub"] = "Gets a file from sHub/sSubDir/sPackage.sExtension. sExtension defaults to .lua, for backwards compatibility."
local function getFromHub(sHub, sSubDir, sPackage, sExtension)
	sExtension = sExtension or ".lua" -- default sExtension to .lua
    local url = "https://" .. fs.combine(fs.combine(packageHub, sSubDir), sPackage..sExtension)
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
local function write(file, path)
    file1 = fs.open(path, "w")
    file1.write(file)
    file1.flush()
    print("File written to local storage.")
end
 
docs["uninstall"] = "Removes a file from /bin/package if it exists."
function uninstall(package)
    if fs.exists(destination .. package) then
        fs.delete(destination .. package)
        print("Removed " .. package)
    else
        printError("Package was never installed.")
    end
end
 
docs["uninstallHelp"] = "Removes a file from /share/help/package if it exists."
function uninstallHelp(package)
    if fs.exists(destinationHelp .. package) then
        fs.delete(destinationHelp .. package)
        print("Removed help for " .. package)
    else
        printError("Help for package '"..package.."' was never installed.")
    end
end
 
docs["uninstallLib"] = "Removes a file from /lib/lib if it exists, in a similar fashion to ccpkg.uninstall."
function uninstallLib(lib)
    if fs.exists(destinationLib .. lib) then
        fs.delete(destinationLib .. lib)
        print("Removed library " .. lib)
    else
        printError("Library was never installed.")
    end
end
 
docs["install"] = "Installs a package 'package' to /bin/."
function install(package)
    if not fs.exists(destination..package) and package then
        packageFile = getFromHub(packageHub, "packages", package)
        finalDestination = destination .. package
        write(packageFile, finalDestination)
    --else
        --printError("Package '"..package.."' already exists.")
    end
end
 
docs["installHelp"] = "Installs help for a package 'package' to /share/help."
function installHelp(package)
    if not fs.exists(destination..package) and package then
        packageFile = getFromHub(packageHub, "help", package, ".txt")
        finalDestination = destinationHelp .. package
        write(packageFile, finalDestination)
    --else
        --printError("Help for package '"..package.."' already exists.")
    end
end
 
docs["installLib"] = "Installs a library 'lib' to /lib/, in a similar fashion to ccpkg.install."
function installLib(lib)
    if not fs.exists(destinationLib..lib) then
        packageFile = getFromHub(packageHub, "lib", sPackage)
        finalDestination = destinationLib .. lib
        write(packageFile, finalDestination)
    else
        printError("Library '"..lib.."' already exists.")
    end
end
 
docs["exec"] = "Executes a package 'package' with arguments 'arguments'."
function exec(package, arguments)
    if fs.exists(destination..package.." "..arguments) then
        shell.run(package)
    end
end
