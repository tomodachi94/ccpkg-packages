--  Brainfuck Interpreter
--  Written by GravityScore
--  Original Pastebin: https://pastebin.com/0AXaibqV
 
--  Variables
 
local w, h = term.getSize()
local args = {...}
 
local loopLocations = {}
local dataCells = {}
local dataPointer = 1
local instructionPointer = 1
 
 
-- Not enough arguments
if #args < 1 then
    print("Usage:")
    print("brainfuck <path>")
    error()
end
 
-- Get path
local path = "/" .. shell.resolve(args[1])
if not fs.exists(path) then
    print("File does not exist!")
    error()
elseif fs.isDir(path) then
    print("File is a directory!")
    error()
end
 
-- Get file contents
local f = io.open(path, "r")
local content = f:read("*a")
f:close()
 
 
-- Find all loops
local loc = 1
local line = 1
for let in content:gmatch(".") do
    if let == "[" then
        loopLocations[loc] = true
    elseif let == "]" then
        local found = false
        for i = loc, 1, -1 do 
            if loopLocations[i] == true then
                loopLocations[i] = loc
                found = true
            end
        end
 
        if not found then
            print(fs.getName(path) .. ":" .. line .. ": No matching ']'")
        end
    end
 
    if let == "\n" then line = line + 1 end
    loc = loc + 1
end
 
-- Run
while true do
    local let = content:sub(instructionPointer, instructionPointer)
 
    if let == ">" then
        dataPointer = dataPointer + 1
        if not dataCells[tostring(dataPointer)] then dataCells[tostring(dataPointer)] = 0 end
    elseif let == "<" then
        dataPointer = dataPointer - 1
        if not dataCells[tostring(dataPointer)] then dataCells[tostring(dataPointer)] = 0 end
    elseif let == "+" then
        if not dataCells[tostring(dataPointer)] then dataCells[tostring(dataPointer)] = 0 end
        dataCells[tostring(dataPointer)] = dataCells[tostring(dataPointer)] + 1
    elseif let == "-" then
        if not dataCells[tostring(dataPointer)] then dataCells[tostring(dataPointer)] = 0 end
        dataCells[tostring(dataPointer)] = dataCells[tostring(dataPointer)] - 1
    elseif let == "." then
        if not dataCells[tostring(dataPointer)] then dataCells[tostring(dataPointer)] = 0 end
        if term.getCursorPos() >= w then print("") end
        write(string.char(dataCells[tostring(dataPointer)]))
    elseif let == "," then
        if not dataCells[tostring(dataPointer)] then dataCells[tostring(dataPointer)] = 0 end
        term.setCursorBlink(true)
        local e, but = os.pullEvent("char")
        term.setCursorBlink(false)
        dataCells[tostring(dataPointer)] = string.byte(but)
        if term.getCursorPos() >= w then print("") end
        write(but)
    elseif let == "/" then
        if not dataCells[tostring(dataPointer)] then dataCells[tostring(dataPointer)] = 0 end
        if term.getCursorPos() >= w then print("") end
        write(dataCells[tostring(dataPointer)])
    elseif let == "[" then
        if dataCells[tostring(dataPointer)] == 0 then
            for k, v in pairs(loopLocations) do
                if k == instructionPointer then instructionPointer = v end
            end
        end
    elseif let == "]" then
        for k, v in pairs(loopLocations) do
            if v == instructionPointer then instructionPointer = k - 1 end
        end
    end
 
    instructionPointer = instructionPointer + 1
    if instructionPointer > content:len() then print("") break end
end
