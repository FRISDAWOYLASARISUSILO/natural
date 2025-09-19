-- Warning Prevention System (NO CONFIRMATION TO SERVER)
-- Mencegah warning muncul tanpa pernah mengirim konfirmasi

local PlayerGui = game.Players.LocalPlayer.PlayerGui

-- CRITICAL: Block all warning-related server communication
local function blockWarningRemotes()
    local oldNamecall = getrawmetatable(game).__namecall
    setreadonly(getrawmetatable(game), false)
    
    getrawmetatable(game).__namecall = function(self, ...)
        local method = getnamecallmethod()
        
        if method == "FireServer" or method == "InvokeServer" then
            local remoteName = tostring(self)
            
            -- Block ANY warning-related remote to prevent server tracking
            if remoteName:lower():find("warning") or 
               remoteName:lower():find("violation") or 
               remoteName:lower():find("anticheat") or
               remoteName:lower():find("detect") then
                print("[BLOCKED] " .. remoteName .. " - Prevented server tracking")
                return -- Don't send to server (CRITICAL)
            end
        end
        
        return oldNamecall(self, ...)
    end
end

-- Hide function - UI only, NO server communication
local function hide()
    local w = PlayerGui:FindFirstChild("Warning")
    if w then 
        -- ONLY hide UI, never send confirmation
        if w:IsA("ScreenGui") then
            w.Enabled = false
        else
            w.Visible = false
        end
        
        -- Additional hiding methods
        pcall(function()
            w:Destroy() -- Nuclear option
        end)
        
        print("[HIDDEN] Warning UI removed (no server communication)")
    end
end

-- Prevent warning creation entirely
local function preventWarning()
    PlayerGui.ChildAdded:Connect(function(gui)
        if gui.Name == "Warning" then
            -- Immediately destroy before it can be shown
            gui:Destroy()
            print("[PREVENTED] Warning destroyed before appearing")
        end
    end)
end

-- Initialize prevention system
print("[WARNING PREVENTION] Starting stealth mode...")

-- 1. Block all warning remotes (most important)
pcall(blockWarningRemotes)

-- 2. Prevent warning GUI creation
pcall(preventWarning)

-- 3. Hide any warnings that slip through
game:GetService("RunService").Heartbeat:Connect(hide)

print("[WARNING PREVENTION] ✅ ACTIVE")
print("[IMPORTANT] No confirmations will be sent to server")
print("[IMPORTANT] This prevents ban accumulation")
