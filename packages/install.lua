-- ccpkg setup utility
-- (c) tomodachi94 2022
-- mit license

local packageHub = "https://tomodachi94.github.io/ccpkg-packages/packages/"

local function mkdir(dir)
  shell.run("mkdir" .. dir)
end
  
local function initDirs()
  mkdir("bin")
  mkdir("doc")
  mkdir("var")
  mkdir("var/ccpkg")
end
    
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

local def installCcpkg()
  initDirs()
  ccpkg-lua = getPackage("ccpkg")
  writePackage(ccpkg-lua, "bin/ccpkg")
end
