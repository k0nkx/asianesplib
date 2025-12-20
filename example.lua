-- Usage Example
local BoxESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/k0nkx/asianesplib/refs/heads/main/source.lua"))()

-- Create instance
local esp = BoxESP.new()

-- Initialize with default settings
esp:Initialize()

-- Or customize settings before initializing
esp:UpdateSettings({
    Keybind = Enum.KeyCode.F5,
    IgnoreTeam = true,
    Box = {
        Color = Color3.fromRGB(255, 0, 0),
        ColorTeam = false,
    },
    Healthbar = {
        Gradient = {
            Colors = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 0)),
            }),
            LerpAnimation = false,
        }
    }
}):Initialize()

-- Toggle ESP on/off
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F6 then
        esp:Toggle()
    end
end)

-- Update settings at runtime
esp:UpdateSettings({
    Nametag = {
        Enabled = false,
    },
    Distance = {
        Color = Color3.fromRGB(0, 255, 0),
    }
})

-- Get current settings
local currentSettings = esp:GetSettings()
print("ESP Enabled:", currentSettings.Enabled)

-- Refresh ESP (recreates all objects)
esp:Refresh()

-- Destroy ESP when done
-- esp:Destroy()
