-- ccpkg client
-- (c) 2022 tomodachi94, with help from rolcam
-- mit license
 
if not http then
    printError("ccpkg requires the HTTP API to be enabled.")
    printError("If you are an administrator, set http_enable to true in ComputerCraft.cfg. If you aren't an administrator, there isn't much else you can do other than ask an admin to enable it.")
end
 
local tArgs = { ... }
local packageHub = "https://tomodachi94.github.io/ccpkg-packages/packages/"
local destination = "/bin/"
local destinationDocs = "/doc/"
local command = tArgs[1]
local packageName = tArgs[2]
 
local function getPackage(package)
     local url = packageHub.. package ..'.lua'
    print("Connecting to " .. url .. "... ")
    local response = http.get(url)
        
    if response then
        print( "Success." )
        
        local sResponse = response.readAll()
        response.close()
        return sResponse
    else
        print( "Failed." )
    end
end
 
local function writePackage(file, path)
    if not fs.exists(path) then
   file1 = fs.open(path, "w")       
   file1.write(file)
   file1.flush()
   print("File written to local storage.")
    end
end
 
if command == "install" then
    packageFile = getPackage(packageName)
    finalDestination = destination .. packageName
    writePackage(packageFile, finalDestination)
else
 print("Invalid command.")
end