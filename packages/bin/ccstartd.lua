--ccstartd by tomodachi94
--mit license

local function initializeDirs()
	fs.makeDir("/bin")
	fs.makeDir("/etc")
	fs.makeDir("/etc/ccstartd")
	fs.makeDir("/etc/ccstartd/startup")
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
 f.flush()
 f.close()
end

local function setPath()
	local helpPath = help.path() .. ":/share/help"
	local binPath = shell.path() .. ":/bin"

	shell.setPath(binPath)
	help.setPath(helpPath)
end

local function loadLibs()
	local libPath = "/lib"

	-- thank you carrot
 local files = fs.list(libPath)
	for k, v in pairs(files) do
		os.loadAPI(fs.combine(libPath, v))
	end
end

local function startupDir()
	local startup_dir = "/etc/ccstartd/startup/"
	local files = fs.list(startup_dir)
	for k,v in pairs(files) do
		if string.find(v, ".lua") then
			shell.run(fs.combine(startup_dir, v))
		end
	end

end

local function start()
	if not fs.exists("/.ccstartd_initialized") then
		initializeDirs()
		installStartup()
		f = fs.open("/.ccstartd_initialized", "w")
		f.write("true")
		f.close()
	end
	startupDir()
	setPath()
	loadLibs()
end

start()