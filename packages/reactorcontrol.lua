---@diagnostic disable: lowercase-global
--  BigReactor Control
--  by jaranvil aka jared314, and carrot :)
--
--  feel free to use and/or modify this code
--
-----------------------------------------------
-- Reactor Control - Version History
--
--  Version 3.0 - March 04/03/2022
--      fixed the infinite  parallel threads bug, 
--      because jaranvil though it was a great idea 
--      to call a parallel method, which calls itself :-)
--      recursive parallel = bad
-----------------------------------------------
local version = 2.3
-- is auto power enabled
local auto_string = false
-- auto on value
local on = 0
-- auto off value
local off = 99
-- is auto control rods enabled 
local auto_rods = false
-- control rod auto value
local auto_rf = 0

-- peripherals
local reactor
local mon

-- monitor size
local monX
local monY

term.clear()
-------------------FORMATTING-------------------------------
function cls()
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setCursorPos(1, 1)
end

-- display text on computer's terminal screen
function gfxprint_term(x, y, text, text_color, bg_color)
    term.setTextColor(text_color)
    term.setBackgroundColor(bg_color)
    term.setCursorPos(x, y)
    write(text)
end

-- display text text on monitor, "mon" peripheral
function gfxprint(x, y, text, text_color, bg_color)
    mon.setBackgroundColor(bg_color)
    mon.setTextColor(text_color)
    mon.setCursorPos(x, y)
    mon.write(text)
end

-- draw line on computer terminal
function gfxline(x, y, length, color)
    mon.setBackgroundColor(color)
    mon.setCursorPos(x, y)
    mon.write(string.rep(" ", length))
end

-- draw line on computer terminal
function gfxline_term(x, y, length, color)
    term.setBackgroundColor(color)
    term.setCursorPos(x, y)
    term.write(string.rep(" ", length))
end

-- draws two overlapping lines
-- background line of bg_color 
-- main line of bar_color as a percentage of minVal/maxVal
function gfx_progbar(x, y, length, minVal, maxVal, bar_color, bg_color)
    gfxline(x, y, length, bg_color) -- backgoround bar
    local barSize = math.floor((minVal / maxVal) * length)
    gfxline(x, y, barSize, bar_color) -- progress so far
end

-- same as above but on the computer terminal
function gfx_progbar_term(x, y, length, minVal, maxVal, bar_color, bg_color)
    gfxline_term(x, y, length, bg_color) -- backgoround bar
    local barSize = math.floor((minVal / maxVal) * length)
    gfxline_term(x, y, barSize, bar_color) -- progress so far
end

-- create button on monitor
function gfxbtn(x, y, length, text, txt_color, bg_color)
    gfxline(x, y, length, bg_color)
    gfxprint((x + 2), y, text, txt_color, bg_color)
end

-- header and footer bars on monitor
function drawMenuBar()
    gfxline(1, 1, monX, colors.blue)
    gfxprint(2, 1, "Power    Tools    Settings", colors.white, colors.blue)
    gfxline(1, 19, monX, colors.blue)
    gfxprint(2, 19, "     Reactor Control", colors.white, colors.blue)
end

-- dropdown menu for power options
function drawPowerMenu()
    gfxline(1, 2, 9, colors.gray)
    gfxline(1, 3, 9, colors.gray)
    gfxline(1, 4, 9, colors.gray)
    if active then
        gfxprint(2, 2, "ON", colors.lightGray, colors.gray)
        gfxprint(2, 3, "OFF", colors.white, colors.gray)
    else
        gfxprint(2, 2, "ON", colors.white, colors.gray)
        gfxprint(2, 3, "OFF", colors.lightGray, colors.gray)
    end
    gfxprint(2, 4, "Auto", colors.white, colors.gray)
end

-- dropbox menu for tools
function drawToolMenu()
    gfxline(10, 2, 14, colors.gray)
    gfxline(10, 3, 14, colors.gray)
    gfxline(10, 4, 14, colors.gray)
    gfxline(10, 5, 14, colors.gray)
    gfxprint(11, 2, "Control Rods", colors.white, colors.gray)
    gfxprint(11, 3, "Efficiency", colors.white, colors.gray)
    gfxprint(11, 4, "Fuel", colors.white, colors.gray)
    gfxprint(11, 5, "Waste", colors.white, colors.gray)
end

-- dropdown menu for settings
function drawSettingsMenu()
    gfxline(12, 2, 18, colors.gray)
    gfxline(12, 3, 18, colors.gray)
    gfxprint(13, 2, "Check for Updates", colors.white, colors.gray)
    gfxprint(13, 3, "Reset peripherals", colors.white, colors.gray)
end

-- basic popup screen with title bar and exit button 
function drawPopupScreen(y, title, height)
    cls()
    drawMenuBar()

    gfxline(4, y, 22, colors.blue)
    gfxline(25, y, 1, colors.red)

    for counter = y + 1, height + y do
        gfxline(4, counter, 22, colors.white)
    end

    gfxprint(25, y, "X", colors.white, colors.red)
    gfxprint(5, y, title, colors.white, colors.blue)
end

-- write settings to config file
function save_conf()
    sw = fs.open("config.txt", "w")
    sw.writeLine(version)
    sw.writeLine(auto_string)
    sw.writeLine(on)
    sw.writeLine(off)
    sw.writeLine(auto_rods)
    sw.writeLine(auto_rf)
    sw.close()
end

-- read settings from file
function load_conf()
    sr = fs.open("config.txt", "r")
    version = tonumber(sr.readLine())
    auto_string = sr.readLine()
    on = tonumber(sr.readLine())
    off = tonumber(sr.readLine())
    auto_rods = sr.readLine()
    auto_rf = tonumber(sr.readLine())
    sr.close()
end

------------------------END FORMATTING--------------------------

--
function homepage()
    while true do
        cls()
        drawMenuBar()
        terminfo()

        energy_stored = reactor.getEnergyStored()

        --------POWER STAT--------------
        gfxprint(2, 3, "Power:", colors.yellow, colors.black)
        active = reactor.getActive()
        if active then
            gfxprint(10, 3, "ONLINE", colors.lime, colors.black)
        else
            gfxprint(10, 3, "OFFLINE", colors.red, colors.black)
        end

        -----------FUEL---------------------
        gfxprint(2, 5, "Fuel Level:", colors.yellow, colors.black)
        local maxVal = reactor.getFuelAmountMax()
        local minVal = reactor.getFuelAmount()
        local percent = math.floor((minVal / maxVal) * 100)
        gfxprint(15, 5, percent .. "%", colors.white, colors.black)

        if percent < 25 then
            gfx_progbar(2, 6, monX - 2, minVal, maxVal, colors.red, colors.gray)
        else
            if percent < 50 then
                gfx_progbar(2, 6, monX - 2, minVal, maxVal, colors.orange, colors.gray)
            else
                if percent < 75 then
                    gfx_progbar(2, 6, monX - 2, minVal, maxVal, colors.yellow, colors.gray)
                else
                    if percent <= 100 then
                        gfx_progbar(2, 6, monX - 2, minVal, maxVal, colors.lime, colors.gray)
                    end
                end
            end
        end

        -----------ROD HEAT---------------
        gfxprint(2, 8, "Fuel Temp:", colors.yellow, colors.black)
        local maxVal = 2000
        local minVal = math.floor(reactor.getFuelTemperature())

        if minVal < 500 then
            gfx_progbar(2, 9, monX - 2, minVal, maxVal, colors.lime, colors.gray)
        else
            if minVal < 1000 then
                gfx_progbar(2, 9, monX - 2, minVal, maxVal, colors.yellow, colors.gray)
            else
                if minVal < 1500 then
                    gfx_progbar(2, 9, monX - 2, minVal, maxVal, colors.orange, colors.gray)
                else
                    if minVal < 2000 then
                        gfx_progbar(2, 9, monX - 2, minVal, maxVal, colors.red, colors.gray)
                    else
                        if minVal >= 2000 then
                            gfx_progbar(2, 9, monX - 2, 2000, maxVal, colors.red, colors.gray)
                        end
                    end
                end
            end
        end

        gfxprint(15, 8, math.floor(minVal) .. "/" .. maxVal, colors.white, colors.black)

        -----------CASING HEAT---------------
        gfxprint(2, 11, "Casing Temp:", colors.yellow, colors.black)
        local maxVal = 2000
        local minVal = math.floor(reactor.getCasingTemperature())
        if minVal < 500 then
            gfx_progbar(2, 12, monX - 2, minVal, maxVal, colors.lime, colors.gray)
        else
            if minVal < 1000 then
                gfx_progbar(2, 12, monX - 2, minVal, maxVal, colors.yellow, colors.gray)
            else
                if minVal < 1500 then
                    gfx_progbar(2, 12, monX - 2, minVal, maxVal, colors.orange, colors.gray)
                else
                    if minVal < 2000 then
                        gfx_progbar(2, 12, monX - 2, minVal, maxVal, colors.red, colors.gray)
                    else
                        if minVal >= 2000 then
                            gfx_progbar(2, 12, monX - 2, 2000, maxVal, colors.red, colors.gray)
                        end
                    end
                end
            end
        end
        gfxprint(15, 11, math.floor(minVal) .. "/" .. maxVal, colors.white, colors.black)

        -------------OUTPUT-------------------
        if reactor.isActivelyCooled() then

            gfxprint(2, 14, "mB/tick:", colors.yellow, colors.black)
            mbt = math.floor(reactor.getHotFluidProducedLastTick())
            gfxprint(13, 14, mbt .. " mB/t", colors.white, colors.black)

        else

            gfxprint(2, 14, "RF/tick:", colors.yellow, colors.black)
            rft = math.floor(reactor.getEnergyProducedLastTick())
            gfxprint(13, 14, rft .. " RF/T", colors.white, colors.black)

        end

        ------------STORAGE------------
        if reactor.isActivelyCooled() then

            gfxprint(2, 15, "mB Stored:", colors.yellow, colors.black)
            fluid_stored = reactor.getHotFluidAmount()
            fluid_max = reactor.getHotFluidAmountMax()
            fluid_stored_percent = math.floor((fluid_stored / fluid_max) * 100)
            gfxprint(13, 15, fluid_stored_percent .. "% (" .. fluid_stored .. " mB)", colors.white, colors.black)

        else

            gfxprint(2, 15, "RF Stored:", colors.yellow, colors.black)
            energy_stored_percent = math.floor((energy_stored / 10000000) * 100)
            gfxprint(13, 15, energy_stored_percent .. "% (" .. energy_stored .. " RF)", colors.white, colors.black)

        end

        -------------AUTO CONTROL RODS-----------------------
        auto_rods_bool = auto_rods == "true"
        insertion_percent = reactor.getControlRodLevel(0)

        if reactor.isActivelyCooled() then
            gfxprint(2, 16, "Control Rods:", colors.yellow, colors.black)
            gfxprint(16, 16, insertion_percent .. "%", colors.white, colors.black)
        else

            if auto_rods_bool then
                if active then
                    if rft > auto_rf + 50 then
                        reactor.setAllControlRodLevels(insertion_percent + 1)
                    else
                        if rft < auto_rf - 50 then
                            reactor.setAllControlRodLevels(insertion_percent - 1)
                        end
                    end
                end

                gfxprint(2, 16, "Control Rods:", colors.yellow, colors.black)
                gfxprint(16, 16, insertion_percent .. "%", colors.white, colors.black)
                gfxprint(21, 16, "(Auto)", colors.red, colors.black)

            else
                gfxprint(2, 16, "Control Rods:", colors.yellow, colors.black)
                gfxprint(16, 16, insertion_percent .. "%", colors.white, colors.black)
            end
        end

        -------------AUTO SHUTOFF--------------------------
        if reactor.isActivelyCooled() then

            -- i dont know what I should do here

        else
            auto = auto_string == "true"
            if auto then
                if active then
                    gfxprint(2, 17, "Auto off:", colors.yellow, colors.black)
                    gfxprint(13, 17, off .. "% RF Stored", colors.white, colors.black)
                    if energy_stored_percent >= off then
                        reactor.setActive(false)
                        stop_function = "recursive"
                        return
                    end
                else
                    gfxprint(2, 17, "Auto on:", colors.yellow, colors.black)
                    gfxprint(13, 17, on .. "% RF Stored", colors.white, colors.black)
                    if energy_stored_percent <= on then
                        reactor.setActive(true)
                        stop_function = "recursive"
                        return
                    end
                end
            else
                gfxprint(2, 17, "Auto power:", colors.yellow, colors.black)
                gfxprint(14, 17, "disabled", colors.red, colors.black)
            end
        end

        sleep(0.5)
    end
end

--------------MENU SCREENS--------------

-- auto power menu
function auto_off()

    auto = auto_string == "true"
    if auto then -- auto power enabled

        drawPopupScreen(3, "Auto Power", 11)
        gfxprint(5, 5, "Enabled", colors.lime, colors.white)
        gfxprint(15, 5, " disable ", colors.white, colors.black)

        gfxprint(5, 7, "ON when storage =", colors.gray, colors.white)
        gfxprint(5, 8, " - ", colors.white, colors.black)
        gfxprint(13, 8, on .. "% RF", colors.black, colors.white)
        gfxprint(22, 8, " + ", colors.white, colors.black)

        gfxprint(5, 10, "OFF when storage =", colors.gray, colors.white)
        gfxprint(5, 11, " - ", colors.white, colors.black)
        gfxprint(13, 11, off .. "% RF", colors.black, colors.white)
        gfxprint(22, 11, " + ", colors.white, colors.black)

        gfxprint(11, 13, " Save ", colors.white, colors.black)

        local event, side, xPos, yPos = os.pullEvent("monitor_touch")

        -- disable auto
        if yPos == 5 then
            if xPos >= 15 and xPos <= 21 then
                auto_string = "false"
                save_conf()
                auto_off()
            else
                auto_off()
            end
        end

        -- increase/decrease auto on %
        if yPos == 8 then
            if xPos >= 5 and xPos <= 8 then
                previous_on = on
                on = on - 1
            end
            if xPos >= 22 and xPos <= 25 then
                previous_on = on
                on = on + 1
            end
        end

        -- increase/decrease auto off %
        if yPos == 11 then
            if xPos >= 5 and xPos <= 8 then
                previous_off = off
                off = off - 1
            end
            if xPos >= 22 and xPos <= 25 then
                previous_off = off
                off = off + 1
            end
        end

        if on < 0 then
            on = 0
        end
        if off > 99 then
            off = 99
        end

        if on == off or on > off then
            on = previous_on
            off = previous_off
            drawPopupScreen(5, "Error", 6)
            gfxprint(5, 7, "Auto On value must be", colors.black, colors.white)
            gfxprint(5, 8, "lower then auto off", colors.black, colors.white)
            gfxprint(11, 10, "Okay", colors.white, colors.black)
            local event, side, xPos, yPos = os.pullEvent("monitor_touch")

            auto_off()
        end

        -- Okay button
        if yPos == 13 and xPos >= 11 and xPos <= 17 then
            save_conf()
            run_app()
        end

        -- Exit button
        if yPos == 3 and xPos == 25 then
            run_app()
        end

        auto_off()
    else
        drawPopupScreen(3, "Auto Power", 5)
        gfxprint(5, 5, "Disabled", colors.red, colors.white)
        gfxprint(15, 5, " enable ", colors.white, colors.gray)
        gfxprint(11, 7, "Okay", colors.white, colors.black)

        local event, side, xPos, yPos = os.pullEvent("monitor_touch")

        -- Okay button
        if yPos == 7 and xPos >= 11 and xPos <= 17 then
            run_app()
        end

        if yPos == 5 then
            if xPos >= 15 and xPos <= 21 then
                auto_string = "true"
                save_conf()
                auto_off()
            else
                auto_off()
            end
        else
            auto_off()
        end
    end
end

-- efficiency menu
function efficiency()
    drawPopupScreen(3, "Efficiency", 12)
    fuel_usage = reactor.getFuelConsumedLastTick()
    rft = math.floor(reactor.getEnergyProducedLastTick())

    rfmb = rft / fuel_usage

    gfxprint(5, 5, "Fuel Consumption: ", colors.lime, colors.white)
    gfxprint(5, 6, fuel_usage .. " mB/t", colors.black, colors.white)
    gfxprint(5, 8, "Energy per mB: ", colors.lime, colors.white)
    gfxprint(5, 9, rfmb .. " RF/mB", colors.black, colors.white)

    gfxprint(5, 11, "RF/tick:", colors.lime, colors.white)
    gfxprint(5, 12, rft .. " RF/T", colors.black, colors.white)

    gfxprint(11, 14, " Okay ", colors.white, colors.black)

    local event, side, xPos, yPos = os.pullEvent("monitor_touch")

    -- Okay button
    if yPos == 14 and xPos >= 11 and xPos <= 17 then
        run_app()
    end

    -- Exit button
    if yPos == 3 and xPos == 25 then
        run_app()
    end

    efficiency()
end

function fuel()
    drawPopupScreen(3, "Fuel", 9)

    fuel_max = reactor.getFuelAmountMax()
    fuel_level = reactor.getFuelAmount()
    fuel_reactivity = math.floor(reactor.getFuelReactivity())

    gfxprint(5, 5, "Fuel Level: ", colors.lime, colors.white)
    gfxprint(5, 6, fuel_level .. "/" .. fuel_max, colors.black, colors.white)

    gfxprint(5, 8, "Reactivity: ", colors.lime, colors.white)
    gfxprint(5, 9, fuel_reactivity .. "%", colors.black, colors.white)

    gfxprint(11, 11, " Okay ", colors.white, colors.black)

    local event, side, xPos, yPos = os.pullEvent("monitor_touch")

    -- Okay button
    if yPos == 11 and xPos >= 11 and xPos <= 17 then
        run_app()
    end

    -- Exit button
    if yPos == 3 and xPos == 25 then
        run_app()
    end

    fuel()
end

function waste()
    drawPopupScreen(3, "Waste", 8)

    waste_amount = reactor.getWasteAmount()
    gfxprint(5, 5, "Waste Amount: ", colors.lime, colors.white)
    gfxprint(5, 6, waste_amount .. " mB", colors.black, colors.white)
    gfxprint(8, 8, " Eject Waste ", colors.white, colors.red)
    gfxprint(11, 10, " Close ", colors.white, colors.black)

    local event, side, xPos, yPos = os.pullEvent("monitor_touch")

    -- eject button
    if yPos == 8 and xPos >= 8 and xPos <= 21 then
        reactor.doEjectWaste()
        drawPopupScreen(5, "Waste Eject", 5)
        gfxprint(5, 7, "Waste Ejeceted.", colors.black, colors.white)
        gfxprint(11, 9, " Close ", colors.white, colors.black)
        local event, side, xPos, yPos = os.pullEvent("monitor_touch")
        -- Okay button
        if yPos == 7 and xPos >= 11 and xPos <= 17 then
            run_app()
        end

        -- Exit button
        if yPos == 3 and xPos == 25 then
            run_app()
        end
    end

    -- Okay button
    if yPos == 10 and xPos >= 11 and xPos <= 17 then
        run_app()
    end

    -- Exit button
    if yPos == 3 and xPos == 25 then
        run_app()
    end
    waste()
end

function set_auto_rf()
    drawPopupScreen(5, "Auto Adjust", 11)
    gfxprint(5, 7, "Try to maintain:", colors.black, colors.white)

    gfxprint(13, 9, " ^ ", colors.white, colors.gray)
    gfxprint(10, 11, auto_rf .. " RF/t", colors.black, colors.white)
    gfxprint(13, 13, " v ", colors.white, colors.gray)
    gfxprint(11, 15, " Okay ", colors.white, colors.gray)

    local event, side, xPos, yPos = os.pullEvent("monitor_touch")

    -- increase button
    if yPos == 9 then
        auto_rf = auto_rf + 100
        save_conf()
        set_auto_rf()
    end

    -- decrease button
    if yPos == 13 then
        auto_rf = auto_rf - 100
        if auto_rf < 0 then
            auto_rf = 0
        end
        save_conf()
        set_auto_rf()
    end

    if yPos == 15 then
        control_rods()
    end

    set_auto_rf()
end

function control_rods()

    if reactor.isActivelyCooled() then

        drawPopupScreen(3, "Control Rods", 13)
        insertion_percent = reactor.getControlRodLevel(0)

        gfxprint(5, 5, "Inserted: " .. insertion_percent .. "%", colors.black, colors.white)
        gfx_progbar(5, 7, 20, insertion_percent, 100, colors.yellow, colors.gray)

        gfxprint(5, 9, " << ", colors.white, colors.black)
        gfxprint(10, 9, " < ", colors.white, colors.black)
        gfxprint(17, 9, " > ", colors.white, colors.black)
        gfxprint(21, 9, " >> ", colors.white, colors.black)

        gfxprint(5, 11, "Auto:", colors.black, colors.white)
        gfxprint(5, 13, "unavilable for", colors.red, colors.white)
        gfxprint(5, 14, "active cooling", colors.red, colors.white)

        gfxprint(11, 16, " Close ", colors.white, colors.gray)

        local event, side, xPos, yPos = os.pullEvent("monitor_touch")

        if yPos == 9 and xPos >= 5 and xPos <= 15 then
            reactor.setAllControlRodLevels(insertion_percent - 10)
        end

        if yPos == 9 and xPos >= 10 and xPos <= 13 then
            reactor.setAllControlRodLevels(insertion_percent - 1)
        end

        if yPos == 9 and xPos >= 17 and xPos <= 20 then
            reactor.setAllControlRodLevels(insertion_percent + 1)
        end

        if yPos == 9 and xPos >= 21 and xPos <= 25 then
            reactor.setAllControlRodLevels(insertion_percent + 10)
        end

        ------Close button-------
        if yPos == 16 and xPos >= 11 and xPos <= 17 then
            run_app()
        end

        ------Exit button------------
        if yPos == 5 and xPos == 25 then
            run_app()
        end
        control_rods()

    else

        drawPopupScreen(3, "Control Rods", 13)
        insertion_percent = reactor.getControlRodLevel(0)

        gfxprint(5, 5, "Inserted: " .. insertion_percent .. "%", colors.black, colors.white)
        gfx_progbar(5, 7, 20, insertion_percent, 100, colors.yellow, colors.gray)

        gfxprint(5, 9, " << ", colors.white, colors.black)
        gfxprint(10, 9, " < ", colors.white, colors.black)
        gfxprint(17, 9, " > ", colors.white, colors.black)
        gfxprint(21, 9, " >> ", colors.white, colors.black)

        gfxprint(5, 11, "Auto:", colors.black, colors.white)
        gfxprint(16, 11, " disable ", colors.white, colors.black)

        auto_rods_bool = auto_rods == "true"
        if auto_rods_bool then

            gfxprint(5, 13, "RF/t: " .. auto_rf, colors.black, colors.white)
            gfxprint(18, 13, " set ", colors.white, colors.black)
        else
            gfxprint(16, 11, " enable ", colors.white, colors.black)
            gfxprint(5, 13, "disabled", colors.red, colors.white)
        end

        gfxprint(11, 15, " Close ", colors.white, colors.gray)

        local event, side, xPos, yPos = os.pullEvent("monitor_touch")

        -----manual adjust buttons------------
        if yPos == 9 and xPos >= 5 and xPos <= 15 then
            reactor.setAllControlRodLevels(insertion_percent - 10)
        end

        if yPos == 9 and xPos >= 10 and xPos <= 13 then
            reactor.setAllControlRodLevels(insertion_percent - 1)
        end

        if yPos == 9 and xPos >= 17 and xPos <= 20 then
            reactor.setAllControlRodLevels(insertion_percent + 1)
        end

        if yPos == 9 and xPos >= 21 and xPos <= 25 then
            reactor.setAllControlRodLevels(insertion_percent + 10)
        end

        ------auto buttons-----------------
        if yPos == 11 and xPos >= 16 then
            if auto_rods_bool then
                auto_rods = "false"
                save_conf()
                control_rods()
            else
                auto_rods = "true"
                save_conf()
                control_rods()
            end
        end

        if yPos == 13 and xPos >= 18 then
            set_auto_rf()
        end

        ------Close button-------
        if yPos == 15 and xPos >= 11 and xPos <= 17 then
            run_app()
        end

        ------Exit button------------
        if yPos == 5 and xPos == 25 then
            run_app()
        end
        control_rods()

    end
end

-----------------------Settings--------------------------------

function rf_mode()
    wait = read()
end

function steam_mode()
    wait = read()
end

function install_update(program, pastebin)
    cls()
    gfxline(4, 5, 22, colors.blue)

    for counter = 6, 10 do
        gfxline(4, counter, 22, colors.white)
    end

    gfxprint(5, 5, "Updating...", colors.white, colors.blue)
    gfxprint(5, 7, "Open computer", colors.black, colors.white)
    gfxprint(5, 8, "terminal.", colors.black, colors.white)

    if fs.exists("install") then
        fs.delete("install")
    end
    shell.run("pastebin get p4zeq7Ma install")
    shell.run("install")
end

function update()
    drawPopupScreen(5, "Updates", 4)
    gfxprint(5, 7, "Connecting to", colors.black, colors.white)
    gfxprint(5, 8, "pastebin...", colors.black, colors.white)

    sleep(0.5)

    shell.run("pastebin get MkF2QQjH current_version.txt")
    sr = fs.open("current_version.txt", "r")
    current_version = tonumber(sr.readLine())
    sr.close()
    fs.delete("current_version.txt")
    terminfo()

    if current_version > version then

        drawPopupScreen(5, "Updates", 7)
        gfxprint(5, 7, "Update Available!", colors.black, colors.white)
        gfxprint(11, 9, " Install ", colors.white, colors.black)
        gfxprint(11, 11, " Ignore ", colors.white, colors.black)

        local event, side, xPos, yPos = os.pullEvent("monitor_touch")

        -- Instatll button
        if yPos == 9 and xPos >= 11 and xPos <= 17 then
            install_update()
        end

        -- Exit button
        if yPos == 5 and xPos == 25 then
            stop_function = "updated"
            return
        end

        stop_function = "updated"
        return

    else
        drawPopupScreen(5, "Updates", 5)
        gfxprint(5, 7, "You are up to date!", colors.black, colors.white)
        gfxprint(11, 9, " Okay ", colors.white, colors.black)

        local event, side, xPos, yPos = os.pullEvent("monitor_touch")

        -- Okay button
        if yPos == 9 and xPos >= 11 and xPos <= 17 then
            stop_function = "updated"
            return
        end

        -- Exit button
        if yPos == 5 and xPos == 25 then
            stop_function = "updated"
            return
        end
        
        stop_function = "updated"
        return
    end

end

function reset_peripherals()
    cls()
    gfxline(4, 5, 22, colors.blue)

    for counter = 6, 10 do
        gfxline(4, counter, 22, colors.white)
    end

    gfxprint(5, 5, "Reset Peripherals", colors.white, colors.blue)
    gfxprint(5, 7, "Open computer", colors.black, colors.white)
    gfxprint(5, 8, "terminal.", colors.black, colors.white)
    setup_wizard()
end

-- stop running status screen if monitors was touched
function stop()
    while true do
        local event, side, xPos, yPos = os.pullEvent("monitor_touch")
        x = xPos
        y = yPos
        stop_function = "monitor_touch"
        return
    end
end

function mon_touch()
    -- when the monitor is touch on the homepage
    if y == 1 then
        if x < monX / 3 then
            drawPowerMenu()
            local event, side, xPos, yPos = os.pullEvent("monitor_touch")
            if xPos < 9 then
                if yPos == 2 then
                    reactor.setActive(true)
                    timer = 0 -- reset anytime the reactor is turned on/off
                    stop_function = "touched"
                    return
                else
                    if yPos == 3 then
                        reactor.setActive(false)
                        timer = 0 -- reset anytime the reactor is turned on/off
                        stop_function = "touched"
                        return
                    else
                        if yPos == 4 then
                            auto_off()
                        else
                            stop_function = "touched"
                            return
                        end
                    end
                end
            else
                stop_function = "touched"
                return
            end

        else
            if x < 20 then
                drawToolMenu()
                local event, side, xPos, yPos = os.pullEvent("monitor_touch")
                if xPos < 25 and xPos > 10 then
                    if yPos == 2 then
                        control_rods()
                    else
                        if yPos == 3 then
                            efficiency()
                        else
                            if yPos == 4 then
                                fuel()
                            else
                                if yPos == 5 then
                                    waste()
                                else
                                    stop_function = "touched"
                                    return
                                end
                            end
                        end
                    end
                else
                    stop_function = "touched"
                    return
                end
            else
                if x < monX then
                    drawSettingsMenu()
                    local event, side, xPos, yPos = os.pullEvent("monitor_touch")
                    if xPos > 13 then
                        if yPos == 2 then
                            update()
                            if (stop_function == "updated") then
                                return
                            end
                        else
                            if yPos == 3 then
                                reset_peripherals()
                            else
                                stop_function = "touched"
                                return
                            end
                        end
                    else
                        stop_function = "touched"
                        return
                    end
                end
            end
        end
    else
        stop_function = "touched"
        return
    end
end

function terminfo()
    term.clear()
    gfxline_term(1, 1, 55, colors.blue)
    gfxprint_term(13, 1, "BigReactor Controls", colors.white, colors.blue)
    gfxline_term(1, 19, 55, colors.blue)
    gfxprint_term(6, 19, "by jaranvil aka jared314, and carrot :)", colors.white, colors.blue)

    gfxprint_term(1, 3, "Current program:", colors.white, colors.black)
    gfxprint_term(1, 4, "Reactor Control v3.0", colors.blue, colors.black)

    gfxprint_term(1, 6, "Please give me your feedback, suggestions,", colors.white, colors.black)
    gfxprint_term(1, 7, "and errors!", colors.white, colors.black)
end

-- run both homepage() and stop() until one returns
function run_app()
    while true do
        cls()
        parallel.waitForAny(homepage, stop)
    
        if stop_function == "terminal_screen" then
            stop_function = "nothing"
            setup_wizard()
        elseif stop_function == "monitor_touch" then
            stop_function = "nothing"
            mon_touch()
            if (stop_function == "touched") then
                stop_function = "nothing"
            end
        elseif stop_function == "recursive" then
            stop_function = "nothing"
        end 
    end
end

-- test if the entered monitor and reactor can be wrapped
function init_app()
    term.clear()

    gfxline_term(1, 1, 55, colors.blue)
    gfxprint_term(10, 1, "BigReactors Controls", colors.white, colors.blue)

    gfxline_term(1, 19, 55, colors.blue)
    gfxprint_term(3, 19, "by jaranvil aka jared314, and carrot :)", colors.white, colors.blue)
    
    gfxprint_term(1, 3, "Searching for a peripherals...", colors.white, colors.black)
    reactor = find_reactor()
    gfxprint_term(2, 5, "Connecting to reactor... ", colors.white, colors.black)
    while (reactor == nil) do
        gfxprint_term(1, 8, "Error:", colors.red, colors.black)
        gfxprint_term(1, 9, "Could not connect to reactor", colors.red, colors.black)
        gfxprint_term(1, 10, "Reactor must be connected with networking cable", colors.white, colors.black)
        gfxprint_term(1, 11, "and modems or the computer is directly beside", colors.white, colors.black)
        gfxprint_term(1, 12, "the reactors computer port.", colors.white, colors.black)
        gfxprint_term(1, 14, "Press Enter to continue...", colors.gray, colors.black)
        wait = read()
        reactor = find_reactor()
    end

    gfxprint_term(27, 5, "success", colors.lime, colors.black)
    sleep(0.5)

    gfxprint_term(2, 6, "Connecting to monitor...", colors.white, colors.black)
    sleep(0.5)
    mon = find_mon()
    while (mon == nil) do
        gfxprint_term(1, 7, "Error:", colors.red, colors.black)
        gfxprint_term(1, 8, "Could not connect to a monitor. Place a 3x3 advanced monitor", colors.red, colors.black)
        gfxprint_term(1, 11, "Press Enter to continue...", colors.gray, colors.black)
        wait = read()
        mon = find_mon()
    end

    monX, monY = mon.getSize()
    gfxprint_term(27, 6, "success", colors.lime, colors.black)
    sleep(0.5)
    gfxprint_term(2, 7, "saving configuration...", colors.white, colors.black)

    save_conf()

    sleep(0.1)
    gfxprint_term(1, 9, "Setup Complete!", colors.lime, colors.black)
    sleep(1)

    auto = auto_string == "true"
    run_app()
end
----------------SETUP-------------------------------

function setup_wizard()
    term.clear()

    gfxprint_term(1, 1, "BigReactor Controls v" .. version, colors.lime, colors.black)
    gfxprint_term(1, 2, "Peripheral setup", colors.white, colors.black)
    gfxprint_term(1, 4, "Step 1:", colors.lime, colors.black)
    gfxprint_term(1, 5, "-Place 3x3 advanced monitors next to computer.", colors.white, colors.black)
    gfxprint_term(1, 7, "Step 2:", colors.lime, colors.black)
    gfxprint_term(1, 8, "-Place a wired modem on this computer and on the ", colors.white, colors.black)
    gfxprint_term(1, 9, " computer port of the reactor.", colors.white, colors.black)
    gfxprint_term(1, 10, "-connect modems with network cable.", colors.white, colors.black)
    gfxprint_term(1, 11, "-right click modems to activate.", colors.white, colors.black)
    gfxprint_term(1, 13, "Press Enter when ready...", colors.gray, colors.black)

    wait = read()
    init_app()
end

function find_reactor()
    local names = peripheral.getNames()
    local i, name
    for i, name in pairs(names) do
        if peripheral.getType(name) == "BigReactors-Reactor" then
            return peripheral.wrap(name)
        else
            -- return nil
        end
    end
end

function find_mon()
    local names = peripheral.getNames()
    local i, name
    for i, name in pairs(names) do
        if peripheral.getType(name) == "monitor" then
            test = name
            return peripheral.wrap(name)
        else
            -- return nil
        end
    end
end

function start()
    -- if configs exists, load values and test
    if fs.exists("config.txt") then
        load_conf()
        init_app()
    else
        setup_wizard()
    end
end

start()