-- installs stuff from disk to computer, requires packages:

requires = {0: "/lib/ccpkg", 1: "/bin/ccpkg", 2: "/bin/ccstartd"}

-- creates an install disk

tArgs = {...}
command = tArgs[1]
target = tArgs[2]

function help():
	return "# install-disk

	Tools for installing ccpkg and ccstartd from a disk and for creating such a disk.

	## Arguments

	install-disk-make [COMMAND] <OPTION>

	Valid commands:
	- install: Installs ccpkg and ccstartd to local computer 
	- install-unattended: Installs ccpkg and ccstartd to local computer without prompts. WARNING: THIS IS FOR AUTOMATION ONLY, USE AT OWN RISK.
	- make: Creates an install disk for [TARGET], using files present on the computer to do so.
		- OPTIONS: Requires option to be a folder.
	"
end

local function copyLib(sTarget):
	local libTarget = fs.combine(sTarget, "lib") .. "/"
	fs.copy("/lib/ccpkg", libTarget..'ccpkg')
end

local function copyBin(sTarget):
	local binTarget = fs.combine(sTarget, "bin") .. "/"
	fs.copy("/bin/ccpkg", binTarget..'ccpkg')
	fs.copy("/bin/ccstartd", binTarget..'ccstartd')
	fs.copy("/bin/disk-install", fs.combine(sTarget, "disk-install"))
	f = fs.open(fs.combine(sTarget, "startup"))
	f.write("print('To install ccpkg and ccstartd, run /disk/disk-install in the shell.')")
	f.flush()
	f.close()
end

function make(sTarget):
	fs.makeDir(fs.combine(sTarget, 'bin'))
	fs.makeDir(fs.combine(sTarget, 'lib'))
	copyLib(sTarget)
	copyBin(sTarget)
end

function install():
	shell.run("cp /disk/lib /lib")
	shell.run("cp /disk/bin /bin")

	for k,v in pairs(requires) do
		if not fs.exists(v) then
			os.print("File "..v.." was not copied, this could break your installation.")

	shell.run("/bin/ccstartd")
end

function cli():
	if commmand == "make" then
		make()
	elseif command == nil then
		print(help())
	elseif command == "install" then
		print("WARNING: This operation will overwrite the /bin and /lib directories.")
		print("Type 'continue' to proceed with installation, or any other string to halt installation. ")
		local confirm = read()
		confirm = string.lower(confirm)
		if confirm == "continue"
			install()
		else
			printError("The installer was terminated by the user.")
		end
	elseif command == "install-unattended" then
		print("Installing in unattended mode...")
		install()
	else
		printError("Invalid command '" ..command.. "'")
	end
end

cli()
