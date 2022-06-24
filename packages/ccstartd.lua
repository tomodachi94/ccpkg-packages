--ccstartd by tomodachi94
--mit license
 
local function initializeDirs()
    fs.makeDir("/bin")
    fs.makeDir("/etc")
    fs.makeDir("/etc")
    fs.makeDir("/var")
    fs.makeDir("/var/log")
    fs.makeDir("/lib")
    fs.makeDir("/home")
    fs.makeDir("/share")
    fs.makeDir("/share/help")
end
 
local function installStartup()
 if fs.exists("/startup") then
   fs.move("/startup", "startup.old")
 end
 
  local f = fs.open("startup", "w")
  f.write("shell.run('/bin/ccstartd')") 
end 
 
local function setPath()
    local helpPath = help.path() .. ":/share/help"
    local binPath = shell.path() .. ":/bin"
 
    shell.setPath(binPath)
    help.setPath(helpPath)  
end
 
local function start()
    if not fs.exists("/.ccstartd_initialized") then
        initializeDirs()
  installStartup()
        f = fs.open("/.ccstartd_initialized", "w")
        f.write("true")
        f.close()
    end
    setPath()
end
 
start()