-- this file should be present on disk
if not os.loadAPI("/disk/lib/ccpkg") then
	printError("Could not find library ccpkg in /disk/lib/ccpkg.")
	return false
end

fs.makeDir("/bin")
fs.makeDir("/lib")

-- install base packages
ccpkg.installLib("ccpkg")
ccpkg.install("ccpkg")
ccpkg.install("ccstartd")

shell.run("/bin/ccstartd")