
local BoxESPLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/k0nkx/asianesplib/refs/heads/main/source-xeno-no-drawing"))()

task.wait(0.1)

-- EXAMPLE 2: Modify Settings Before Use
BoxESPLib:SetSettings({
    Box = {
        Color = Color3.fromRGB(0, 255, 0), -- Green boxes
        Thickness = 2,
        Transparency = 0.3, -- Slightly transparent
        ColorTeam = true, -- Show team colors
    },
    Nametag = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255),
        UseDisplayName = true, -- Use Display Names instead of usernames
    },
    Distance = {
        Enabled = true,
        Color = Color3.fromRGB(150, 150, 255),
    },
    Healthbar = {
        Enabled = true,
        Gradient = {
            Colors = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), -- Red at 0%
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 0)), -- Yellow at 50%
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 0)), -- Green at 100%
            }),
            LerpAnimation = true,
            LerpSpeed = 0.05, -- Faster animation
        }
    },
    Highlight = {
        Enabled = false, -- Disable highlight if you want only boxes
    }
})
