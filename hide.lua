-- Smart Warning System (Confirm Once + Block Future)
-- Strategi: Konfirmasi pertama untuk unlock game, block selanjutnya

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PlayerGui = Players.LocalPlayer.PlayerGui

local hasConfirmedOnce = false -- Track konfirmasi pertama
local preventionActive = false -- Track prevention system

-- Konfirmasi warning pertama (diperlukan untuk unlock game)
local function confirmFirstWarning(warningGui)
    if hasConfirmedOnce then return false end
    
    print("[Smart Warning] 🔓 Confirming first warning to unlock game...")
    
    -- Find and click "I UNDERSTAND" button
    for _, child in pairs(warningGui:GetDescendants()) do
        if child:IsA("TextButton") then
            local text = child.Text or ""
            if text:find("UNDERSTAND") or text:find("13") or text:lower():find("understand") then
                -- Human-like interaction
                GuiService.SelectedObject = child
                task.wait(0.3)
                
                -- Fire button events
                for _, connection in pairs(getconnections(child.MouseButton1Click)) do
                    connection:Fire()
                end
                
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                
                hasConfirmedOnce = true
                print("[Smart Warning] ✅ First confirmation sent - game unlocked!")
                return true
            end
        end
    end
    
    return false
end

-- Setup prevention system (setelah konfirmasi pertama)
local function setupPrevention()
    if preventionActive then return end
    
    local oldNamecall = getrawmetatable(game).__namecall
    setreadonly(getrawmetatable(game), false)
    
    getrawmetatable(game).__namecall = function(self, ...)
        local method = getnamecallmethod()
        
        if method == "FireServer" or method == "InvokeServer" then
            local remoteName = tostring(self):lower()
            
            -- Block future warning remotes
            if hasConfirmedOnce and (remoteName:find("warning") or 
               remoteName:find("violation") or 
               remoteName:find("detect")) then
                print("[Smart Warning] 🚫 Blocked future warning remote")
                return -- Block remote
            end
        end
        
        return oldNamecall(self, ...)
    end
    
    preventionActive = true
    print("[Smart Warning] 🛡️ Prevention system activated")
end

-- Main handler
local function handleWarning()
    local w = PlayerGui:FindFirstChild("Warning")
    if w then 
        if not hasConfirmedOnce then
            -- First warning: Confirm to unlock game
            confirmFirstWarning(w)
        else
            -- Future warnings: Just hide/destroy
            if w:IsA("ScreenGui") then
                w.Enabled = false
            else
                w.Visible = false
            end
            print("[Smart Warning] 🚫 Future warning hidden")
        end
    end
end

-- Monitor warnings
game:GetService("RunService").Heartbeat:Connect(handleWarning)

-- Handle new warnings
PlayerGui.ChildAdded:Connect(function(gui)
    if gui.Name == "Warning" then
        task.wait(0.2)
        
        if not hasConfirmedOnce then
            print("[Smart Warning] 🔔 First warning - confirming...")
            if confirmFirstWarning(gui) then
                -- Setup prevention after successful confirmation
                task.spawn(function()
                    task.wait(2)
                    setupPrevention()
                end)
            end
        else
            print("[Smart Warning] 🚫 Blocking future warning")
            gui:Destroy()
        end
    end
end)

print("[Smart Warning] 🧠 Intelligent warning system loaded!")
print("[Smart Warning] Strategy: Confirm first → Block future")
print("[Smart Warning] ✅ Safe for bot usage!")
