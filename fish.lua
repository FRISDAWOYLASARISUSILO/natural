-- Auto Fisch Script dengan Kavo UI
-- Fitur: Auto Cast Mode Legit dengan timing random

-- Load Kavo UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DESRIYANDA/natural/main/kavo.lua"))()

-- Services
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local autoCast = false
local autoCastDelay = 2
local autoShake = false
local isShaking = false
local alwaysCatch = false
local enableLoop = true
local enableAFK = false

-- AFK Mode Variables
local afkStartTime = 0
local isAFK = false
local afkDuration = 0
local nextAFKTime = 0

-- Helper Functions
local function FindChild(parent, child)
    if parent then
        return parent:FindFirstChild(child)
    end
    return nil
end
local function getchar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- AFK Mode Functions
local function initializeAFK()
    if enableAFK then
        -- Set waktu untuk AFK pertama (5-10 menit dari sekarang)
        local initialDelay = math.random(300, 600) -- 5-10 menit dalam detik
        nextAFKTime = tick() + initialDelay
        -- AFK initialized silently
    end
end

local function checkAFKMode()
    if not enableAFK then return false end
    
    local currentTime = tick()
    
    -- Cek apakah sudah waktunya untuk AFK
    if not isAFK and currentTime >= nextAFKTime then
        -- Mulai AFK
        isAFK = true
        afkStartTime = currentTime
        afkDuration = math.random(60, 180) -- 1-3 menit dalam detik
        -- Going AFK silently
        return true
    end
    
    -- Cek apakah AFK sudah selesai
    if isAFK and (currentTime - afkStartTime) >= afkDuration then
        -- Selesai AFK
        isAFK = false
        -- Set waktu AFK berikutnya (5-10 menit lagi)
        local nextDelay = math.random(300, 600)
        nextAFKTime = currentTime + nextDelay
        -- Back from AFK silently
        return false
    end
    
    return isAFK
end

local function FindRod()
    local character = getchar()
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("events") and tool.events:FindFirstChild("cast") then
            return tool
        end
    end
    return nil
end

-- Auto Cast Function dengan timing random
local function performAutoCast()
    if not autoCast then return end
    
    local rod = FindRod()
    if not rod then return end
    
    -- Generate random timing antara 1-3 detik
    local randomTiming = math.random(100, 300) / 100 -- 1.00 sampai 3.00 detik
    
    -- Start mouse hold (tekan mouse)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, LocalPlayer, 0)
    
    -- Wait dengan timing random
    wait(randomTiming)
    
    -- Release mouse hold (lepas mouse)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, LocalPlayer, 0)
end

-- Auto Shake Function dengan timing random
local function performAutoShake()
    if not autoShake or isShaking then return end
    
    local shakeUI = PlayerGui:FindFirstChild("shakeui")
    if not shakeUI then return end
    
    local safezone = shakeUI:FindFirstChild("safezone")
    if not safezone then return end
    
    local button = safezone:FindFirstChild("button")
    if not button or not button.Visible then return end
    
    isShaking = true
    -- Auto shake started
    
    task.spawn(function()
        while shakeUI.Parent and button.Visible and autoShake do
            -- Random timing lebih bervariasi: 0.3-2.8 detik (lebih natural seperti manusia)
            local minDelay = math.random(30, 80) / 100  -- 0.3-0.8 detik (reaction time)
            local maxDelay = math.random(150, 280) / 100 -- 1.5-2.8 detik (thinking time)
            local randomClickTiming = math.random() < 0.7 and minDelay or maxDelay -- 70% cepat, 30% lambat
            
            -- Random method selection untuk variasi
            local useGuiService = math.random() < 0.6 -- 60% gunakan GuiService, 40% langsung VirtualInput
            
            if useGuiService then
                -- Method 1: GuiService (seperti implementasi asli)
                GuiService.SelectedObject = button
                if GuiService.SelectedObject == button then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    task.wait(math.random(3, 8) / 100) -- Random brief delay 0.03-0.08 detik
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                end
            else
                -- Method 2: Direct VirtualInput (variasi)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                task.wait(math.random(4, 12) / 100) -- Random brief delay 0.04-0.12 detik
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            end
            
            -- Shake click executed
            
            -- Wait dengan timing random sebelum klik berikutnya
            task.wait(randomClickTiming)
        end
        isShaking = false
        -- Shake session ended
    end)
end

-- Always Catch Function dengan Natural Success/Fail Rate
local function performAlwaysCatch()
    if not alwaysCatch then return end
    
    local successChance = math.random(1, 100)
    local completionRate
    local isSpecialCatch = false
    local status
    
    if successChance <= 85 then -- 85% chance untuk SUCCESS
        -- SUCCESS: args[1] = 100
        completionRate = 100
        
        -- Tentukan jenis tangkapan untuk success
        local specialChance = math.random(1, 100)
        isSpecialCatch = specialChance <= 25 -- 25% chance untuk luar biasa
        
        status = "SUCCESS - " .. (isSpecialCatch and "LUAR BIASA" or "NORMAL")
    else -- 15% chance untuk FAIL
        -- FAIL: args[1] = random 10-99 (bervariasi)
        completionRate = math.random(10, 99)
        isSpecialCatch = false -- Tidak ada special catch jika fail
        
        status = "FAIL (" .. completionRate .. "%)"
    end
    
    -- Always catch executed
    ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(completionRate, isSpecialCatch)
    
    -- Setelah catch, tunggu delay random 1-4 detik lalu kembali ke auto cast
    if autoCast and enableLoop then
        task.spawn(function()
            local loopDelay = math.random(100, 400) / 100 -- 1.00 sampai 4.00 detik
            -- Waiting for next cast
            task.wait(loopDelay)
            
            -- Cek AFK mode sebelum melanjutkan
            if not checkAFKMode() and autoCast and enableLoop then
                task.spawn(function()
                    performAutoCast()
                end)
            end
        end)
    end
end

-- Create Main Window
local Window = Library.CreateLib("Auto Fisch Natural", "Ocean")

-- ===== SEMUA TOGGLE BUTTONS DI ATAS =====
local MainTab = Window:NewTab("🎣 Main Controls")
local ControlSection = MainTab:NewSection("⚙️ Toggle Controls")

-- Auto Cast Toggle
ControlSection:NewToggle("Enable Auto Cast", "Aktifkan auto cast dengan timing random natural", function(state)
    autoCast = state
    -- Toggle state changed silently
end)

-- Cast Delay Slider
ControlSection:NewSlider("Cast Delay", "Delay antar cast dalam detik", 5, 1, function(value)
    autoCastDelay = value
    -- Cast delay updated silently
end)

-- Auto Shake Toggle  
ControlSection:NewToggle("Enable Auto Shake", "Aktifkan auto shake dengan timing anti-detection", function(state)
    autoShake = state
    if not state then
        isShaking = false
    end
    -- Toggle state changed silently
end)

-- Always Catch Toggle
ControlSection:NewToggle("Enable Always Catch", "85% success rate dengan natural fail pattern", function(state)
    alwaysCatch = state
    -- Toggle state changed silently
end)

-- Loop Toggle
ControlSection:NewToggle("Enable Loop", "Otomatis repeat fishing cycle", function(state)
    enableLoop = state
    -- Loop mode toggled silently
end)

-- AFK Toggle
ControlSection:NewToggle("Enable AFK Mode", "Simulasi break realistis", function(state)
    enableAFK = state
    if state then
        initializeAFK()
    else
        isAFK = false
    end
    -- AFK mode toggled silently
end)

-- ===== SEMUA INFORMASI DI BAWAH =====
local InfoTab = Window:NewTab("📊 Information")
local AutoCastInfo = InfoTab:NewSection("🎯 Auto Cast Info")

AutoCastInfo:NewLabel("Auto Cast Mode Natural:")
AutoCastInfo:NewLabel("• Timing hold: 1-3 detik (random)")
AutoCastInfo:NewLabel("• Safe & Natural casting simulation")
AutoCastInfo:NewLabel("• Automatic rod detection")
AutoCastInfo:NewLabel("• Configurable delay between casts")

local AutoShakeInfo = InfoTab:NewSection("🔄 Auto Shake Info")

AutoShakeInfo:NewLabel("Auto Shake Mode Anti-Detection:")
AutoShakeInfo:NewLabel("• Timing: 0.3-2.8 detik (sangat random)")
AutoShakeInfo:NewLabel("• 70% cepat, 30% lambat (human-like)")
AutoShakeInfo:NewLabel("• Dual method: GuiService/Direct")
AutoShakeInfo:NewLabel("• Random key hold: 0.03-0.12 detik")
AutoShakeInfo:NewLabel("• No predictable patterns")

local AlwaysCatchInfo = InfoTab:NewSection("🎣 Always Catch Info")

AlwaysCatchInfo:NewLabel("Always Catch Mode (Natural Rate):")
AlwaysCatchInfo:NewLabel("• Success rate: 85% (catch fish)")
AlwaysCatchInfo:NewLabel("• Fail rate: 15% (random 10-99% completion)")
AlwaysCatchInfo:NewLabel("• Special catch: 25% luar biasa (on success)")
AlwaysCatchInfo:NewLabel("• Uses hookmetamethod for reliability")
AlwaysCatchInfo:NewLabel("• Natural human-like success/fail pattern")
AlwaysCatchInfo:NewLabel("• Variable fail completion rates")

local LoopAFKInfo = InfoTab:NewSection("⚡ Loop & AFK Info")

LoopAFKInfo:NewLabel("Loop Mode:")
LoopAFKInfo:NewLabel("• Auto repeats: Cast → Shake → Catch")
LoopAFKInfo:NewLabel("• Random delay: 1-4 seconds")
LoopAFKInfo:NewLabel("• Seamless fishing automation")

LoopAFKInfo:NewLabel("")
LoopAFKInfo:NewLabel("AFK Mode:")
LoopAFKInfo:NewLabel("• Active time: 5-10 minutes")
LoopAFKInfo:NewLabel("• Break time: 1-3 minutes")
LoopAFKInfo:NewLabel("• Realistic player simulation")

-- Auto Shake dengan Intelligent Heartbeat (tidak spam, ada delay)
local lastShakeTime = 0
local shakeClickDelay = 0 -- Dynamic delay untuk next click

RunService.Heartbeat:Connect(function()
    -- Cek AFK mode untuk autoshake juga
    if autoShake and not checkAFKMode() then
        local currentTime = tick()
        local shakeui = FindChild(PlayerGui, "shakeui")
        
        if shakeui then
            local safezone = FindChild(shakeui, "safezone")
            if safezone then
                local button = FindChild(safezone, "button")
                if button and button.Visible then
                    -- Cek apakah sudah waktunya untuk click berikutnya
                    if currentTime - lastShakeTime >= shakeClickDelay then
                        -- Generate random timing untuk click berikutnya
                        local minDelay = math.random(30, 80) / 100  -- 0.3-0.8 detik (reaction time)
                        local maxDelay = math.random(150, 280) / 100 -- 1.5-2.8 detik (thinking time)
                        shakeClickDelay = math.random() < 0.7 and minDelay or maxDelay -- 70% cepat, 30% lambat
                        
                        -- Random method selection
                        local useGuiService = math.random() < 0.6 -- 60% GuiService, 40% Direct
                        
                        if useGuiService then
                            GuiService.SelectedObject = button
                            if GuiService.SelectedObject == button then
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                            end
                        else
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        end
                        
                        -- Shake click executed
                        lastShakeTime = currentTime
                    end
                end
            end
        else
            -- Reset saat shakeui tidak ada
            lastShakeTime = 0
            shakeClickDelay = 0
        end
    end
end)

local lastCastTime = 0
local lastRodEquipped = nil

RunService.Heartbeat:Connect(function()
    -- Cek AFK mode terlebih dahulu
    if checkAFKMode() then return end
    if not autoCast then return end

    local currentTime = tick()
    local rod = FindRod()
    if rod then
        -- Cek apakah rod baru saja di-equip
        if lastRodEquipped ~= rod then
            lastRodEquipped = rod
            -- Cast langsung saat rod di-equip dan autoCast aktif
            if rod.values and rod.values:FindFirstChild("lure") then
                local lureValue = rod.values.lure.Value
                if lureValue <= 0.001 then
                    task.spawn(function()
                        performAutoCast()
                    end)
                    lastCastTime = currentTime
                end
            end
        end
        -- Cek interval autoCast seperti biasa
        if currentTime - lastCastTime >= autoCastDelay then
            if rod.values and rod.values:FindFirstChild("lure") then
                local lureValue = rod.values.lure.Value
                if lureValue <= 0.001 then
                    task.spawn(function()
                        performAutoCast()
                    end)
                    lastCastTime = currentTime
                end
            end
        end
    else
        lastRodEquipped = nil
    end
end)

local function onCharacterChildAdded(child)
    if child:IsA("Tool") and child:FindFirstChild("events") and child.events:FindFirstChild("cast") and autoCast then
        task.wait(autoCastDelay)
        -- Check lure value before casting (fix for bobber water detection)
        if child.values and child.values:FindFirstChild("lure") then
            local lureValue = child.values.lure.Value
            if lureValue <= 0.001 then -- Only cast if lure is not in water
                task.spawn(function()
                    performAutoCast()
                end)
                lastCastTime = tick()
            end
        end
    end
end

local function onCharacterAdded(character)
    character.ChildAdded:Connect(onCharacterChildAdded)
end

if getchar() then
    getchar().ChildAdded:Connect(onCharacterChildAdded)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

PlayerGui.ChildAdded:Connect(function(gui)
    if gui.Name == "shakeui" and autoShake and not checkAFKMode() then
        -- ShakeUI detected
        -- Heartbeat sekarang handle autoshake, ini hanya untuk log
    elseif gui.Name == "reel" and alwaysCatch and not checkAFKMode() then
        -- Reel GUI detected
        
        -- Natural always catch: random delay, random perfect catch (mengikuti simple.lua)
        task.spawn(function()
            local minigameDelay = math.random(50, 150) / 100 -- 0.5-1.5 detik
            -- Waiting for natural timing before catch
            task.wait(minigameDelay)
            
            -- Complete minigame if GUI still exists
            if gui and gui.Parent and alwaysCatch then
                performAlwaysCatch()
                
                -- Try to hide GUI (optional, mengikuti simple.lua)
                pcall(function() 
                    gui.Enabled = false 
                    -- GUI hidden
                end)
            else
                -- GUI not available
            end
        end)
    end
end)

--// Hooks for Always Catch (mengikuti implementasi simple.lua yang bekerja)
local function CheckFunc(func)
    return typeof(func) == 'function'
end

if CheckFunc(hookmetamethod) then
    -- Setting up hooks
    local hookSuccess, hookError = pcall(function()
        local old; old = hookmetamethod(game, "__namecall", function(self, ...)
            local method, args = getnamecallmethod(), {...}
            
            -- Always Catch Hook dengan Natural Success/Fail Rate
            if method == 'FireServer' and self.Name == 'reelfinished' and alwaysCatch then
                local successChance = math.random(1, 100)
                local completionRate
                local isSpecialCatch = false
                local status
                
                if successChance <= 85 then -- 85% chance untuk SUCCESS
                    -- SUCCESS: args[1] = 100
                    completionRate = 100
                    
                    -- Tentukan jenis tangkapan untuk success
                    local specialChance = math.random(1, 100)
                    isSpecialCatch = specialChance <= 25 -- 25% chance untuk luar biasa
                    
                    status = "SUCCESS - " .. (isSpecialCatch and "LUAR BIASA" or "NORMAL")
                else -- 15% chance untuk FAIL
                    -- FAIL: args[1] = random 10-99 (bervariasi)
                    completionRate = math.random(10, 99)
                    isSpecialCatch = false -- Tidak ada special catch jika fail
                    
                    status = "FAIL (" .. completionRate .. "%)"
                end
                
                args[1] = completionRate
                args[2] = isSpecialCatch
                
                -- Hook executed
                return old(self, unpack(args))
            end
            return old(self, ...)
        end)
    end)
    
    if hookSuccess then
        -- Hooks ready
    else
        -- Hook setup failed
    end
else
    -- Hookmetamethod not available, using fallback
end

-- Script loaded silently
-- Features available: Auto Cast, Auto Shake, Always Catch with natural anti-detection