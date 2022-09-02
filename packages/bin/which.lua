tArgs = {...}

for _,v in pairs(tArgs) do
	print("/"..shell.resolveProgram(v))
end
