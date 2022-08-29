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

docs["local.smartHttp"] = "Returns contents of HTTP"
local function smartHttp(sUrl)
    print("Connecting to " .. sUrl .. "... ")
    local response, httpError = http.get(sUrl)
 
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

docs["uninstall"] = "Removes a package according to its manifest."
function uninstall(sPackage)
    local metadata = smartHttp("https://" .. packageHub .. "meta/" .. sPackage .. ".json")
    local metadata = textutils.unserializeJSON(metadata)
    if metadata[sPackage] == false then
        printError("ccpkg: uninstall: Package was never installed")
    else
        for k,v in pairs(metadata[sPackage]["provides"]) do
            fs.delete(v)
        end
        -- else
            -- printError("Package '"..sPackage.."' was never installed.")
    end
end

docs["install"] = "Installs a package 'package' according to its manifest."
function install(sPackage)
    local metadata = smartHttp("https://" .. packageHub .. "meta/" .. sPackage .. ".json")
    local metadata = textutils.unserializeJSON(metadata)
    if not fs.exists(metadata[sPackage]["provides"][1]) then
        for _,v in pairs(metadata[sPackage]["provides"]) do
            local url = "https://" .. fs.combine(packageHub, v)
            local file = smartHttp(url)
            v = string.gsub(v, ".lua", "")
            v = string.gsub(v, ".txt", "")
            write(file, v)
        end
    --else
        --printError("Package '"..package.."' already exists.")
    end
end

docs["exec"] = "Executes a binary package 'package' with arguments 'arguments'."
function exec(package, arguments)
    if fs.exists(fs.combine("/bin/", package)) then
        shell.run(fs.combine("/bin/", package) .." ".. arguments)
    end
end
