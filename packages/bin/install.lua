if not http then
	print("The http api is required to proceed with installation.")
	return false
end

local function get(sUrl)
	--write("Connecting to " .. sUrl .. "... ")
	local ok, err = http.checkURL(sUrl)
	if not ok then
		print("Failed.")
		if err then
			printError(err)
		end
		return nil
	end

	local response = http.get(sUrl, nil, true)
	if not response then
		print("Failed.")
		return nil
	end

	--print("Success.")

	local sResponse = response.readAll()
	response.close()
	return sResponse
end

local function write(content, path)
	f = fs.open(path, "w")
	f.write(content)
	f.flush()
	f.close()
end

local function installStuff()
	fs.makeDir("/bin")
	fs.makeDir("/lib")
	write(get('https://tomodachi94.github.io/ccpkg-packages/packages/ccstartd.lua'), '/bin/ccstartd')
	write(get('https://tomodachi94.github.io/ccpkg-packages/packages/ccpkg.lua'), '/bin/ccpkg')
	write(get('https://tomodachi94.github.io/ccpkg-packages/lib/ccpkg.lua'), '/lib/ccpkg')
	write(get('https://tomodachi94.github.io/ccpkg-packages/lib/json.lua'), '/lib/json')
	shell.run("/bin/ccstartd")
	print('Rebooting...')
	sleep(1)
	os.reboot()
end

installStuff()