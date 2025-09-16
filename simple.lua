--// Services
local cloneref = cloneref or function(obj) return obj end -- Fallback if cloneref doesn't exist
local Players = cloneref(game:GetService('Players'))
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local RunService = cloneref(game:GetService('RunService'))
local GuiService = cloneref(game:GetService('GuiService'))
local VirtualInputManager = cloneref(game:GetService("VirtualInputManager"))

--// Variables
local flags = {}
local lp = Players.LocalPlayer
flags.autocastmode = "Legit" -- Default mode
flags.autocastdelay = 1 -- Default delay in seconds
flags.ragebobberDistance = -250 -- Default close distance for instant bobber (negative = close to character)
flags.legitrandompower = false -- Random power bar for Legit mode
flags.legitpowermin = 70 -- Minimum power percentage (70-100%)
flags.legitpowermax = 100 -- Maximum power percentage
flags.legitholdmin = 0.3 -- Minimum hold duration in seconds
flags.legitholdmax = 1.2 -- Maximum hold duration in seconds

print("[SIMPLE FISCH] Script starting... Loading UI...")

--// Functions
FindChildOfClass = function(parent, classname)
    return parent:FindFirstChildOfClass(classname)
end
FindChild = function(parent, child)
    return parent:FindFirstChild(child)
end
FindChildOfType = function(parent, childname, classname)
    child = parent:FindFirstChild(childname)
    if child and child.ClassName == classname then
        return child
    end
end
CheckFunc = function(func)
    return typeof(func) == 'function'
end

--// Custom Functions
getchar = function()
    return lp.Character or lp.CharacterAdded:Wait()
end
gethrp = function()
    return getchar():WaitForChild('HumanoidRootPart')
end
gethum = function()
    return getchar():WaitForChild('Humanoid')
end
FindRod = function()
    if FindChildOfClass(getchar(), 'Tool') and FindChild(FindChildOfClass(getchar(), 'Tool'), 'values') then
        return FindChildOfClass(getchar(), 'Tool')
    else
        return nil
    end
end

-- Function to get target power percentage for Legit mode
getTargetPower = function()
    if flags.legitrandompower then
        local minPower = math.max(50, flags.legitpowermin or 70) -- Minimum 50%
        local maxPower = math.min(100, flags.legitpowermax or 100) -- Maximum 100%
        
        -- Ensure min is not greater than max
        if minPower > maxPower then
            minPower, maxPower = maxPower, minPower
        end
        
        local randomPower = math.random(minPower, maxPower)
        return randomPower / 100 -- Convert to decimal (0.7 = 70%)
    else
        return 1.0 -- Full power (100%)
    end
end

-- Function to get random hold duration for Legit mode
getHoldDuration = function()
    local minHold = math.max(0.1, flags.legitholdmin or 0.3) -- Minimum 0.1 seconds
    local maxHold = math.min(3.0, flags.legitholdmax or 1.2) -- Maximum 3.0 seconds
    
    -- Ensure min is not greater than max
    if minHold > maxHold then
        minHold, maxHold = maxHold, minHold
    end
    
    -- Generate random float between min and max
    local randomHold = minHold + (math.random() * (maxHold - minHold))
    return randomHold
end

--// Load Kavo UI Library from GitHub
local Kavo
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/DESRIYANDA/SimpleAJA/main/kavo.lua"))()
end)

if success and result then
    Kavo = result
    print("[SIMPLE FISCH] Kavo UI loaded successfully from GitHub")
else
    -- Fallback jika gagal load dari GitHub
    warn("[SIMPLE FISCH] Failed to load Kavo from GitHub, using fallback...")
    local fallbackSuccess, fallbackResult = pcall(function()
        return loadstring(game:HttpGet("https://pastebin.com/raw/vff1bQ9F"))()
    end)
    
    if fallbackSuccess and fallbackResult then
        Kavo = fallbackResult
        print("[SIMPLE FISCH] Kavo UI loaded from fallback")
    else
        error("[SIMPLE FISCH] Failed to load Kavo UI from both GitHub and fallback sources!")
        return
    end
end

--// UI Creation
if not Kavo then
    error("[SIMPLE FISCH] Kavo UI library failed to load!")
    return
end

local window = Kavo.CreateLib("Simple Fisch")
local mainTab = window:NewTab("Main Features")
local mainSection = mainTab:NewSection("Fishing Automation")

-- Create toggles for the main features
mainSection:NewToggle("Auto Cast", "Automatically cast your fishing rod", function(state)
    flags.autocast = state
end)

mainSection:NewDropdown("Auto Cast Mode", "Choose between Legit and Rage mode", {"Legit", "Rage"}, function(mode)
    flags.autocastmode = mode
end)

mainSection:NewSlider("Auto Cast Delay", "Delay before auto casting (seconds)", 10, 0, function(value)
    flags.autocastdelay = value
end)

mainSection:NewSlider("Rage Bobber Distance", "Distance for Rage mode bobber (-500 = very close)", 2, -500, function(value)
    flags.ragebobberDistance = value
end)

mainSection:NewToggle("Legit Random Power", "Use random power instead of always full bar", function(state)
    flags.legitrandompower = state
end)

mainSection:NewSlider("Legit Min Power %", "Minimum power percentage for random mode", 100, 50, function(value)
    flags.legitpowermin = value
end)

mainSection:NewSlider("Legit Max Power %", "Maximum power percentage for random mode", 100, 70, function(value)
    flags.legitpowermax = value
end)

mainSection:NewSlider("Legit Hold Min (s)", "Minimum hold duration in seconds", 30, 1, function(value)
    flags.legitholdmin = value / 10 -- Convert to decimal (30 = 3.0 seconds)
end)

mainSection:NewSlider("Legit Hold Max (s)", "Maximum hold duration in seconds", 30, 3, function(value)
    flags.legitholdmax = value / 10 -- Convert to decimal (30 = 3.0 seconds)
end)

mainSection:NewToggle("Auto Shake", "Automatically shake when fish bites", function(state)
    flags.autoshake = state
end)

mainSection:NewToggle("Auto Reel", "Automatically reel in your catch", function(state)
    flags.autoreel = state
end)

mainSection:NewToggle("Perfect Cast", "Always cast with 100% power", function(state)
    flags.perfectcast = state
end)

mainSection:NewToggle("Always Catch", "Never lose a fish when reeling", function(state)
    flags.alwayscatch = state
end)

mainSection:NewToggle("Always Catch v2", "Smart auto-complete minigame with natural timing", function(state)
    flags.alwayscatchv2 = state
end)

mainSection:NewToggle("Super Instant Reel", "Skip reel animation and instantly catch fish", function(state)
    flags.superinstantreel = state
end)

--// Main Logic Loops
local lastShakeTime = 0

-- Auto Shake (Simple implementation like coba.lua)
RunService.Heartbeat:Connect(function()
    if flags.autoshake then
        if lp.PlayerGui:FindFirstChild('shakeui') and 
           lp.PlayerGui.shakeui:FindFirstChild('safezone') and 
           lp.PlayerGui.shakeui.safezone:FindFirstChild('button') then
            GuiService.SelectedObject = lp.PlayerGui.shakeui.safezone.button
            if GuiService.SelectedObject == lp.PlayerGui.shakeui.safezone.button then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            end
        end
    end
end)

-- Enhanced AutoCast Event Listeners
local autoCastConnection1, autoCastConnection2

local function setupAutoCastListeners()
    -- Connection 1: When tool is equipped
    autoCastConnection1 = getchar().ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child:FindFirstChild("events") and child.events:FindFirstChild("cast") and flags.autocast then
            task.wait(flags.autocastdelay or 1) -- Use configurable delay
            
            if flags.autocastmode == "Legit" then
                -- Legit Mode: With random power and hold duration
                local holdDuration = getHoldDuration() -- Get random hold duration
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, lp, 0)
                task.wait(holdDuration) -- Wait for random duration
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, lp, 0)
            elseif flags.autocastmode == "Rage" then
                -- Rage Mode: Hold mouse briefly then instant cast
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, lp, 0)
                task.wait(0.5) -- Hold mouse for 0.5 seconds
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, lp, 0)
                task.wait(0.1) -- Small delay before cast
                child.events.cast:FireServer(100, flags.ragebobberDistance or -250)
            end
        end
    end)
    
    -- Connection 2: When reel GUI is removed (for continuous casting)
    autoCastConnection2 = lp.PlayerGui.ChildRemoved:Connect(function(gui)
        if gui.Name == "reel" and flags.autocast then
            local tool = getchar():FindFirstChildOfClass("Tool") -- Use same method as king.lua
            if tool and tool:FindFirstChild("events") and tool.events:FindFirstChild("cast") then
                task.wait(flags.autocastdelay or 1) -- Use configurable delay
                
                if flags.autocastmode == "Legit" then
                    -- Legit Mode: With random power and hold duration (same as Connection 1)
                    local holdDuration = getHoldDuration() -- Get random hold duration
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, lp, 0)
                    task.wait(holdDuration) -- Wait for random duration
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, lp, 0)
                elseif flags.autocastmode == "Rage" then
                    -- Rage Mode: Must click mouse first, then instant cast (same as Connection 1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, lp, 0)
                    task.wait(0.5) -- Hold mouse for 0.5 seconds  
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, lp, 0)
                    task.wait(0.1) -- Small delay before cast
                    tool.events.cast:FireServer(100, flags.ragebobberDistance or -250)
                end
            end
        end
    end)
end

-- Setup AutoCast listeners
task.spawn(setupAutoCastListeners)

-- Always Catch v2 - Event-Based System (Fixed from RunService)
lp.PlayerGui.ChildAdded:Connect(function(gui)
    if gui.Name == "reel" and flags.alwayscatchv2 then
        print("[ALWAYS CATCH V2] REEL GUI DETECTED! Starting auto-completion...")
        
        task.spawn(function()
            local minigameDuration = math.random(50, 150) / 100 -- Reduced from 200-400 to 50-150 (0.5-1.5s)
            local completionRate = math.random(85, 95) -- Increased from 65-88 to 85-95
            
            print("[ALWAYS CATCH V2] Waiting " .. minigameDuration .. " seconds for natural timing...")
            task.wait(minigameDuration)
            
            -- Complete minigame if GUI still exists
            if gui and gui.Parent then
                print("[ALWAYS CATCH V2] Firing reelfinished with rate: " .. completionRate)
                ReplicatedStorage.events.reelfinished:FireServer(completionRate, true)
                
                -- Try to hide GUI
                pcall(function() 
                    gui.Enabled = false 
                    print("[ALWAYS CATCH V2] GUI hidden successfully")
                end)
            else
                print("[ALWAYS CATCH V2] GUI disappeared before completion")
            end
        end)
    end
end)

RunService.Heartbeat:Connect(function()
    -- Auto Reel
    if flags.autoreel then
        local rod = FindRod()
        if rod ~= nil and rod['values']['lure'].Value == 100 and task.wait(.5) then
            ReplicatedStorage.events.reelfinished:FireServer(100, true)
        end
    end
    
    -- Super Instant Reel
    if flags.superinstantreel then
        local rod = FindRod()
        if rod ~= nil and rod['values']['lure'].Value == 100 then
            -- Instantly complete the reel without animation
            task.spawn(function()
                ReplicatedStorage.events.reelfinished:FireServer(100, true)
                -- Force reset lure value to prepare for next cast
                task.wait(0.1)
                if rod and rod['values'] and rod['values']['lure'] then
                    rod['values']['lure'].Value = 0
                end
            end)
        end
        
        -- Skip reel UI if it appears
        if FindChild(lp.PlayerGui, 'reel') then
            local reelGui = lp.PlayerGui['reel']
            if reelGui.Enabled then
                reelGui.Enabled = false
                ReplicatedStorage.events.reelfinished:FireServer(100, true)
            end
        end
    end
    
    -- Always Catch v2 - MOVED TO EVENT-BASED SYSTEM (will be added to GUI event listener)
    -- This section intentionally empty - logic moved to ChildAdded event below
    end
end)

--// Hooks for Perfect Cast and Always Catch
if CheckFunc(hookmetamethod) then
    print("[SIMPLE FISCH] Setting up hooks...")
    local hookSuccess, hookError = pcall(function()
        local old; old = hookmetamethod(game, "__namecall", function(self, ...)
            local method, args = getnamecallmethod(), {...}
            
            -- Perfect Cast Hook
            if method == 'FireServer' and self.Name == 'cast' and flags.perfectcast then
                args[1] = 100
                return old(self, unpack(args))
            -- Always Catch Hook
            elseif method == 'FireServer' and self.Name == 'reelfinished' and flags.alwayscatch then
                args[1] = 100
                args[2] = true
                return old(self, unpack(args))
            -- Always Catch v2 Hook (loading bar bypass)
            elseif method == 'FireServer' and self.Name == 'reelfinished' and flags.alwayscatchv2 then
                -- Simulate normal minigame completion without perfect catch
                -- Use random success rate that looks natural (60-90%)
                local naturalRate = math.random(60, 90)
                args[1] = naturalRate -- Natural success rate (not 100%)
                args[2] = true -- Force caught = true (bypass loading bar requirement)
                return old(self, unpack(args))
            -- Super Instant Reel Hook
            elseif method == 'FireServer' and self.Name == 'reelfinished' and flags.superinstantreel then
                args[1] = 100
                args[2] = true
                return old(self, unpack(args))
            end
            return old(self, ...)
        end)
    end)
    
    if hookSuccess then
        print("[SIMPLE FISCH] Hooks setup successfully")
    else
        warn("[SIMPLE FISCH] Failed to setup hooks: " .. tostring(hookError))
    end
else
    warn("[SIMPLE FISCH] hookmetamethod is not available in this executor")
end