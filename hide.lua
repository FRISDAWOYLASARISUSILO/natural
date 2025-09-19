-- Ultra Simple Warning Hider (Fixed)
-- Hanya menyembunyikan warning UI, tidak ada komunikasi server

local PlayerGui = game.Players.LocalPlayer.PlayerGui

-- Hide function - no server communication
local function hide()
    local w = PlayerGui:FindFirstChild("Warning")
    if w then 
        -- ScreenGui uses Enabled, not Visible
        if w:IsA("ScreenGui") then
            w.Enabled = false
        else
            w.Visible = false
        end
    end
end

-- Real-time hiding
game:GetService("RunService").Heartbeat:Connect(hide)

-- Block new warnings
PlayerGui.ChildAdded:Connect(function(gui)
    if gui.Name == "Warning" then
        if gui:IsA("ScreenGui") then
            gui.Enabled = false
        else
            gui.Visible = false
        end
    end
end)

print("Warning Hider: ON (Fixed)")
