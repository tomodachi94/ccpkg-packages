-- installs stuff from disk to computer, requires packages:
 
--requires = {0: "/lib/ccpkg", 1: "/bin/ccpkg", 2: "/bin/ccstartd"}
 
tArgs = {...}
command = tArgs[1]
target = tArgs[2]
 
local function copyLib(sTarget)
    local libTarget = fs.combine(sTarget, "lib") .. "/"
    fs.copy("/lib/ccpkg", libTarget..'ccpkg')
end
 
local function copyBin(sTarget)
    local binTarget = fs.combine(sTarget, "bin") .. "/"
    fs.copy("/bin/ccpkg", binTarget..'ccpkg')
    fs.copy("/bin/ccstartd", binTarget..'ccstartd')
    fs.copy("/bin/disk-install", fs.combine(sTarget, "disk-install"))
    f = fs.open(fs.combine(sTarget, "startup"))
    f.write("print('To install ccpkg and ccstartd, run ``/disk/disk-install install` in the shell.')")
    f.flush()
    f.close()
end

function make(sTarget)
    fs.makeDir(fs.combine(sTarget, 'bin'))
    fs.makeDir(fs.combine(sTarget, 'lib'))
    copyLib(sTarget)
    copyBin(sTarget)
end
 
function install()
    shell.run("cp /disk/lib /lib")
    shell.run("cp /disk/bin /bin")
    shell.run("/bin/ccstartd")
end
 
function cli()
    if commmand == "make" then
        make()
    elseif command == nil then
        return false
    elseif command == "install" then
        print("WARNING: This operation will overwrite the /bin and /lib directories.")
        print("Type 'continue' to proceed with installation, or any other string to halt installation. ")
        local confirm = read()
        confirm = string.lower(confirm)
        if confirm == "continue" then
            install()
        else
            printError("The installer was terminated by the user.")
            return false
        end
    elseif command == "install-unattended" then
        print("Installing in unattended mode...")
        install()
    else
        printError("Invalid command '" ..command.. "'")
        return false
    end
end
 
cli()
