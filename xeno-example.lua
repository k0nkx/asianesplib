-- Load the ESP library from GitHub
local BoxESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/k0nkx/asianesplib/refs/heads/main/source-xeno-no-drawing"))()

-- =========== EXAMPLE 2: CUSTOMIZE ALL SETTINGS ===========
BoxESP:SetSettings({
    -- Core Settings
    Keybind = Enum.KeyCode.F5, -- Change toggle key
    LocalDebug = false, -- Show ESP on yourself (debug)
    IgnoreTeam = false, -- Show/Hide teammates
    
    -- Box Settings
    Box = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255), -- White boxes
        Thickness = 2, -- Box line thickness
        Transparency = 0, -- Box transparency (0 = fully visible)
        Filled = false, -- Fill the box
        FilledTransparency = 0.3, -- Fill transparency if Filled = true
        MaxSize = 400, -- Maximum box size on screen
        ColorTeam = true, -- Use team colors for boxes
    },
    
    -- Outline Settings (black outline around box)
    Outline = {
        Enabled = true,
        Color = Color3.fromRGB(0, 0, 0), -- Black outline
        Thickness = 3, -- Outline thickness
        Transparency = 0, -- Outline transparency
    },
    
    -- Healthbar Settings
    Healthbar = {
        Enabled = true,
        Width = 4, -- Width of healthbar
        Background = Color3.fromRGB(40, 40, 40), -- Background color
        BackgroundTransparency = 0, -- Background transparency
        OutlineColor = Color3.fromRGB(0, 0, 0), -- Healthbar outline
        OutlineTransparency = 0, -- Outline transparency
        
        -- Gradient settings for healthbar
        Gradient = {
            Colors = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),     -- Red at 0% HP
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 0)), -- Yellow at 50% HP
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 0)),     -- Green at 100% HP
            }),
            LerpAnimation = true, -- Smooth healthbar animation
            LerpSpeed = 0.035, -- Animation speed
        },
    },
    
    -- Health Change Numbers
    HealthChange = {
        Enabled = true,
        Font = Enum.Font.DenkOne,
        Size = 12,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0,
        ShowOutline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Duration = 2.5, -- How long damage numbers stay visible
        FadeSpeed = 1, -- Fade speed
        StackOffset = 12, -- Vertical spacing between stacked numbers
        CheckInterval = 0.2, -- How often to check for health changes
    },
    
    -- Nametag Settings
    Nametag = {
        Enabled = true,
        Font = Enum.Font.GothamBold,
        Size = 14,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0,
        UseDisplayName = true, -- Use Display Name instead of Username
        Offset = Vector2.new(0, -18), -- Position above the box
        ShowOutline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
    },
    
    -- Distance Settings
    Distance = {
        Enabled = true,
        Font = Enum.Font.GothamBold,
        Size = 14,
        Color = Color3.fromRGB(150, 200, 255),
        Transparency = 0,
        Offset = Vector2.new(0, 0), -- Position below the box
        ShowOutline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
    },
    
    -- Velocity Settings
    Velocity = {
        Enabled = true,
        Font = Enum.Font.GothamBold,
        Size = 12,
        Color = Color3.fromRGB(255, 150, 150),
        Transparency = 0,
        ShowOutline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
    },
    
    -- Highlight Settings (Roblox Highlight object)
    Highlight = {
        Enabled = false, -- Can be performance heavy
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.8, -- Highlight transparency
        OutlineColor = Color3.fromRGB(255, 255, 255),
        OutlineTransparency = 0.5, -- Outline transparency
    },
    
    -- Character Detection Settings
    Character = {
        MaxPartDistance = 6, -- How far parts can be from main parts
        R6Parts = {'Head', 'Torso', 'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg'},
        R15Parts = {
            'HumanoidRootPart', 'UpperTorso', 'LowerTorso', 'Head',
            'LeftUpperArm', 'LeftLowerArm', 'LeftHand',
            'RightUpperArm', 'RightLowerArm', 'RightHand',
            'LeftUpperLeg', 'LeftLowerLeg', 'LeftFoot',
            'RightUpperLeg', 'RightLowerLeg', 'RightFoot'
        },
    },
})
