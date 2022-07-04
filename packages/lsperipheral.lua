for _, name in pairs(peripheral.getNames()) do
    print(name, peripheral.getType(name))
end