-- BoxESP Library
-- A modular ESP library for Roblox with comprehensive features

local BoxESP = {}
BoxESP.__index = BoxESP

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Internal tables
BoxESP._connections = {}
BoxESP._drawings = {}
BoxESP._guis = {}
BoxESP._healthStates = {}
BoxESP._healthChanges = {}
BoxESP._lastHealthCheck = {}
BoxESP._players = {}
BoxESP._screenGui = nil

-- Default Settings
BoxESP.Settings = {
    Enabled = true,
    Keybind = Enum.KeyCode.Delete,
    LocalDebug = false,
    IgnoreTeam = false,

    Box = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1.5,
        Transparency = 1,
        Filled = false,
        FilledTransparency = 0.25,
        MaxSize = 300,
        ColorTeam = true,
    },

    Outline = {
        Enabled = true,
        Color = Color3.fromRGB(0, 0, 0),
        Thickness = 3,
        Transparency = 1,
    },

    Healthbar = {
        Enabled = true,
        Width = 3,
        Background = Color3.fromRGB(40, 40, 40),
        BackgroundTransparency = 0,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        OutlineTransparency = 0,

        Gradient = {
            Colors = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 97, 242)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(137, 87, 255)),
            }),
            LerpAnimation = true,
            LerpSpeed = 0.028,
        },
    },

    HealthChange = {
        Enabled = true,
        Font = Enum.Font.DenkOne,
        Size = 11,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0,
        ShowOutline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Duration = 2.3,
        FadeSpeed = 1,
        StackOffset = 11,
        CheckInterval = 0.18,
    },

    Nametag = {
        Enabled = true,
        Font = Enum.Font.SourceSansBold,
        Size = 13,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0,
        UseDisplayName = false,
        Offset = Vector2.new(0, -15),
        ShowOutline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
    },

    Distance = {
        Enabled = true,
        Font = Enum.Font.SourceSansBold,
        Size = 13,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0,
        Offset = Vector2.new(0, 0),
        ShowOutline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
    },

    Velocity = {
        Enabled = true,
        Font = Enum.Font.SourceSansBold,
        Size = 13,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0,
        ShowOutline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
    },

    Highlight = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 1,
        OutlineColor = Color3.fromRGB(255, 255, 255),
        OutlineTransparency = 0.92,
    },

    Character = {
        MaxPartDistance = 5,
        R6Parts = {
            'Head',
            'Torso',
            'Left Arm',
            'Right Arm',
            'Left Leg',
            'Right Leg',
        },
        R15Parts = {
            'HumanoidRootPart',
            'UpperTorso',
            'LowerTorso',
            'Head',
            'LeftUpperArm',
            'LeftLowerArm',
            'LeftHand',
            'RightUpperArm',
            'RightLowerArm',
            'RightHand',
            'LeftUpperLeg',
            'LeftLowerLeg',
            'LeftFoot',
            'RightUpperLeg',
            'RightLowerLeg',
            'RightFoot',
        },
    },
}

-- Utility Functions
local function NewDrawing(class, props)
    local obj = Drawing.new(class)
    for i, v in pairs(props) do
        obj[i] = v
    end
    return obj
end

local function SafeDestroy(obj)
    pcall(function()
        if obj:IsA("Instance") then
            obj:Destroy()
        elseif obj.Remove then
            obj:Remove()
        end
    end)
end

-- 3D Bounding Box Calculation
function BoxESP:_Get3DBounds(character)
    local parts = {}
    
    -- Collect R6 parts
    for _, name in ipairs(self.Settings.Character.R6Parts) do
        local p = character:FindFirstChild(name)
        if p and p:IsA('BasePart') then
            table.insert(parts, p)
        end
    end
    
    -- Collect R15 parts
    for _, name in ipairs(self.Settings.Character.R15Parts) do
        local p = character:FindFirstChild(name)
        if p and p:IsA('BasePart') then
            table.insert(parts, p)
        end
    end
    
    if #parts == 0 then
        return nil, nil
    end

    local min = Vector3.new(math.huge, math.huge, math.huge)
    local max = Vector3.new(-math.huge, -math.huge, -math.huge)

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA('BasePart') and not part.Parent:IsA('Accessory') then
            local include = false
            for _, mp in ipairs(parts) do
                if (part.Position - mp.Position).Magnitude <= self.Settings.Character.MaxPartDistance then
                    include = true
                    break
                end
            end
            if not include then
                continue
            end

            local size = part.Size / 2
            local cf = part.CFrame
            local corners = {
                cf * Vector3.new(size.X, size.Y, size.Z),
                cf * Vector3.new(size.X, size.Y, -size.Z),
                cf * Vector3.new(size.X, -size.Y, size.Z),
                cf * Vector3.new(size.X, -size.Y, -size.Z),
                cf * Vector3.new(-size.X, size.Y, size.Z),
                cf * Vector3.new(-size.X, size.Y, -size.Z),
                cf * Vector3.new(-size.X, -size.Y, size.Z),
                cf * Vector3.new(-size.X, -size.Y, -size.Z),
            }
            
            for _, c in ipairs(corners) do
                min = Vector3.new(
                    math.min(min.X, c.X),
                    math.min(min.Y, c.Y),
                    math.min(min.Z, c.Z)
                )
                max = Vector3.new(
                    math.max(max.X, c.X),
                    math.max(max.Y, c.Y),
                    math.max(max.Z, c.Z)
                )
            end
        end
    end
    
    return min, max
end

function BoxESP:_GetBoxCorners(character)
    local min3D, max3D = self:_Get3DBounds(character)
    if not min3D or not max3D then
        return nil
    end

    local points = {
        Vector3.new(min3D.X, max3D.Y, min3D.Z),
        Vector3.new(min3D.X, max3D.Y, max3D.Z),
        Vector3.new(max3D.X, max3D.Y, min3D.Z),
        Vector3.new(max3D.X, max3D.Y, max3D.Z),
        Vector3.new(min3D.X, min3D.Y, min3D.Z),
        Vector3.new(min3D.X, min3D.Y, max3D.Z),
        Vector3.new(max3D.X, min3D.Y, min3D.Z),
        Vector3.new(max3D.X, min3D.Y, max3D.Z),
    }

    local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
    local camera = workspace.CurrentCamera
    
    for _, p in ipairs(points) do
        local screen = camera:WorldToViewportPoint(p)
        if screen.Z > 0 then
            minX, maxX = math.min(minX, screen.X), math.max(maxX, screen.X)
            minY, maxY = math.min(minY, screen.Y), math.max(maxY, screen.Y)
        end
    end
    
    if minX == math.huge then
        return nil
    end

    local w = math.min(maxX - minX, self.Settings.Box.MaxSize)
    local h = math.min(maxY - minY, self.Settings.Box.MaxSize)
    local cx, cy = (minX + maxX) / 2, (minY + maxY) / 2
    local hw, hh = w / 2, h / 2

    return {
        topLeft = Vector2.new(cx - hw, cy - hh),
        topRight = Vector2.new(cx + hw, cy - hh),
        bottomRight = Vector2.new(cx + hw, cy + hh),
        bottomLeft = Vector2.new(cx - hw, cy + hh)
    }, w, h
end

-- ESP Creation and Management
function BoxESP:_CreateESP(player)
    if self._drawings[player] then
        return
    end

    -- Create Drawing objects
    local outline = NewDrawing('Quad', {
        Thickness = self.Settings.Outline.Thickness,
        Color = self.Settings.Outline.Color,
        Filled = false,
        Transparency = self.Settings.Outline.Transparency,
        Visible = false,
    })

    local box = NewDrawing('Quad', {
        Thickness = self.Settings.Box.Thickness,
        Color = self.Settings.Box.Color,
        Filled = false,
        Transparency = self.Settings.Box.Transparency,
        Visible = false,
    })

    local fill = NewDrawing('Quad', {
        Color = self.Settings.Box.Color,
        Filled = true,
        Transparency = self.Settings.Box.FilledTransparency,
        Visible = false,
    })

    -- Create GUI objects
    local healthbarOutline = Instance.new('Frame')
    healthbarOutline.BackgroundColor3 = self.Settings.Healthbar.OutlineColor
    healthbarOutline.BackgroundTransparency = self.Settings.Healthbar.OutlineTransparency
    healthbarOutline.BorderSizePixel = 0
    healthbarOutline.Visible = false
    healthbarOutline.Parent = self._screenGui

    local barBG = Instance.new('Frame')
    barBG.BackgroundColor3 = self.Settings.Healthbar.Background
    barBG.BackgroundTransparency = self.Settings.Healthbar.BackgroundTransparency
    barBG.BorderSizePixel = 0
    barBG.Position = UDim2.fromOffset(1, 1)
    barBG.Parent = healthbarOutline

    local barFill = Instance.new('Frame')
    barFill.BorderSizePixel = 0
    barFill.Parent = barBG
    
    local gradient = Instance.new('UIGradient')
    gradient.Color = self.Settings.Healthbar.Gradient.Colors
    gradient.Rotation = 90
    gradient.Parent = barFill

    -- Health change tags
    local healthChangeTags = {}
    for i = 1, 3 do
        local tag = Instance.new('TextLabel')
        tag.Font = self.Settings.HealthChange.Font
        tag.TextSize = self.Settings.HealthChange.Size
        tag.TextColor3 = self.Settings.HealthChange.Color
        tag.TextTransparency = 1
        tag.TextStrokeTransparency = 1
        tag.TextStrokeColor3 = self.Settings.HealthChange.OutlineColor
        tag.TextXAlignment = Enum.TextXAlignment.Right
        tag.BackgroundTransparency = 1
        tag.Visible = false
        tag.Parent = self._screenGui
        table.insert(healthChangeTags, tag)
    end

    -- Nametag
    local nameTag = Instance.new('TextLabel')
    nameTag.Font = self.Settings.Nametag.Font
    nameTag.TextSize = self.Settings.Nametag.Size
    nameTag.TextColor3 = self.Settings.Nametag.Color
    nameTag.TextTransparency = self.Settings.Nametag.Transparency
    nameTag.TextStrokeTransparency = self.Settings.Nametag.ShowOutline and 0 or 1
    nameTag.TextStrokeColor3 = self.Settings.Nametag.OutlineColor
    nameTag.TextXAlignment = Enum.TextXAlignment.Center
    nameTag.BackgroundTransparency = 1
    nameTag.Visible = false
    nameTag.Parent = self._screenGui

    -- Distance tag
    local distanceTag = Instance.new('TextLabel')
    distanceTag.Font = self.Settings.Distance.Font
    distanceTag.TextSize = self.Settings.Distance.Size
    distanceTag.TextColor3 = self.Settings.Distance.Color
    distanceTag.TextTransparency = self.Settings.Distance.Transparency
    distanceTag.TextStrokeTransparency = self.Settings.Distance.ShowOutline and 0 or 1
    distanceTag.TextStrokeColor3 = self.Settings.Distance.OutlineColor
    distanceTag.TextXAlignment = Enum.TextXAlignment.Center
    distanceTag.BackgroundTransparency = 1
    distanceTag.Visible = false
    distanceTag.Parent = self._screenGui

    -- Velocity tag
    local velocityTag = Instance.new('TextLabel')
    velocityTag.Font = self.Settings.Velocity.Font
    velocityTag.TextSize = self.Settings.Velocity.Size
    velocityTag.TextColor3 = self.Settings.Velocity.Color
    velocityTag.TextTransparency = self.Settings.Velocity.Transparency
    velocityTag.TextStrokeTransparency = self.Settings.Velocity.ShowOutline and 0 or 1
    velocityTag.TextStrokeColor3 = self.Settings.Velocity.OutlineColor
    velocityTag.TextXAlignment = Enum.TextXAlignment.Left
    velocityTag.BackgroundTransparency = 1
    velocityTag.Visible = false
    velocityTag.Parent = self._screenGui

    -- Highlight
    local highlight = Instance.new('Highlight')
    highlight.FillColor = self.Settings.Highlight.Color
    highlight.FillTransparency = self.Settings.Highlight.Transparency
    highlight.OutlineColor = self.Settings.Highlight.OutlineColor
    highlight.OutlineTransparency = self.Settings.Highlight.OutlineTransparency
    highlight.Enabled = false
    highlight.Parent = self._screenGui

    -- Store references
    self._drawings[player] = {outline, box, fill}
    self._guis[player] = {
        healthbarOutline,
        barBG,
        barFill,
        healthChangeTags,
        nameTag,
        distanceTag,
        velocityTag,
        highlight,
    }
    self._healthStates[player] = 1
    self._healthChanges[player] = {}
    self._lastHealthCheck[player] = {
        health = 1,
        time = tick(),
    }
end

function BoxESP:_RemoveESP(player)
    -- Remove drawings
    if self._drawings[player] then
        for _, drawing in ipairs(self._drawings[player]) do
            SafeDestroy(drawing)
        end
        self._drawings[player] = nil
    end
    
    -- Remove GUI objects
    if self._guis[player] then
        for _, guiObj in ipairs(self._guis[player]) do
            if type(guiObj) == 'table' then
                for _, tag in ipairs(guiObj) do
                    SafeDestroy(tag)
                end
            else
                SafeDestroy(guiObj)
            end
        end
        self._guis[player] = nil
    end
    
    -- Clean up other data
    self._healthStates[player] = nil
    self._healthChanges[player] = nil
    self._lastHealthCheck[player] = nil
    self._players[player] = nil
end

function BoxESP:_CleanupAllESP()
    for player, _ in pairs(self._drawings) do
        self:_RemoveESP(player)
    end
    
    self._connections = {}
    self._drawings = {}
    self._guis = {}
    self._healthStates = {}
    self._healthChanges = {}
    self._lastHealthCheck = {}
    self._players = {}
end

-- Player Management
function BoxESP:_ShouldShowESP(player)
    local localPlayer = Players.LocalPlayer
    
    if player == localPlayer then
        return self.Settings.LocalDebug
    end
    
    if self.Settings.IgnoreTeam then
        return player.Team ~= localPlayer.Team
    end
    
    return true
end

function BoxESP:_HandlePlayerAdded(player)
    self:_RemoveESP(player)
    
    if not self:_ShouldShowESP(player) then
        return
    end
    
    self:_CreateESP(player)
    self._players[player] = true
    
    -- Update nametag
    local guis = self._guis[player]
    if guis then
        local nameTag = guis[5] -- index 5 is nametag
        nameTag.Text = self.Settings.Nametag.UseDisplayName and player.DisplayName or player.Name
    end
    
    -- Character added connection
    local charAddedConn
    charAddedConn = player.CharacterAdded:Connect(function(character)
        if not self.Settings.Enabled then return end
        
        local humanoid = character:FindFirstChildOfClass('Humanoid')
        if humanoid then
            self._lastHealthCheck[player] = {
                health = humanoid.Health / humanoid.MaxHealth,
                time = tick(),
            }
        end
    end)
    
    table.insert(self._connections, charAddedConn)
    
    -- Character removing connection
    local charRemovingConn
    charRemovingConn = player.CharacterRemoving:Connect(function()
        local guis = self._guis[player]
        if not guis then return end
        
        for _, guiObj in ipairs(guis) do
            if type(guiObj) == 'table' then
                for _, tag in ipairs(guiObj) do
                    tag.Visible = false
                end
            elseif guiObj:IsA("TextLabel") or guiObj:IsA("Frame") then
                guiObj.Visible = false
            elseif guiObj:IsA("Highlight") then
                guiObj.Enabled = false
            end
        end
        
        local drawings = self._drawings[player]
        if drawings then
            for _, drawing in ipairs(drawings) do
                drawing.Visible = false
            end
        end
    end)
    
    table.insert(self._connections, charRemovingConn)
    
    -- Team changed connection
    local teamChangedConn
    teamChangedConn = player:GetPropertyChangedSignal("Team"):Connect(function()
        if self:_ShouldShowESP(player) then
            if not self._drawings[player] then
                self:_CreateESP(player)
                local guis = self._guis[player]
                if guis then
                    local nameTag = guis[5]
                    nameTag.Text = self.Settings.Nametag.UseDisplayName and player.DisplayName or player.Name
                end
            end
        else
            self:_RemoveESP(player)
        end
    end)
    
    table.insert(self._connections, teamChangedConn)
    
    -- Handle existing character
    if player.Character then
        charAddedConn:Fire(player.Character)
    end
end

function BoxESP:_HandlePlayerRemoving(player)
    self:_RemoveESP(player)
end

-- Health Change System
function BoxESP:_ShowHealthChange(player, change)
    if not self._healthChanges[player] then
        self._healthChanges[player] = {}
    end
    
    table.insert(self._healthChanges[player], 1, {
        text = change > 0 and "+" .. change or tostring(change),
        startTime = tick(),
        transparency = 0,
        color = change > 0 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0),
    })
    
    -- Limit stack size
    if #self._healthChanges[player] > 3 then
        table.remove(self._healthChanges[player], 4)
    end
end

function BoxESP:_UpdateHealthChange(player, healthChangeTags, healthbarX, healthbarY, height)
    if not self._healthChanges[player] then
        return
    end
    
    local currentTime = tick()
    local activeChanges = {}
    
    -- Filter and update health changes
    for i = #self._healthChanges[player], 1, -1 do
        local healthChange = self._healthChanges[player][i]
        local elapsed = currentTime - healthChange.startTime
        
        if elapsed > self.Settings.HealthChange.Duration then
            table.remove(self._healthChanges[player], i)
        else
            local progress = elapsed / self.Settings.HealthChange.Duration
            healthChange.transparency = progress * self.Settings.HealthChange.FadeSpeed
            table.insert(activeChanges, 1, healthChange)
        end
    end
    
    -- Update tags
    for i, tag in ipairs(healthChangeTags) do
        if i <= #activeChanges then
            local healthChange = activeChanges[i]
            local verticalOffset = (i - 1) * self.Settings.HealthChange.StackOffset
            
            tag.Text = healthChange.text
            tag.TextColor3 = healthChange.color
            tag.TextTransparency = healthChange.transparency
            tag.TextStrokeTransparency = self.Settings.HealthChange.ShowOutline and healthChange.transparency or 1
            tag.Visible = true
            
            tag.Position = UDim2.fromOffset(
                healthbarX - 48,
                healthbarY - 6 + verticalOffset
            )
            tag.Size = UDim2.fromOffset(45, 20)
        else
            tag.Visible = false
        end
    end
end

-- Main Update Loop
function BoxESP:_UpdateESP()
    if not self.Settings.Enabled then
        for player, drawings in pairs(self._drawings) do
            for _, drawing in ipairs(drawings) do
                drawing.Visible = false
            end
            
            local guis = self._guis[player]
            if not guis then continue end
            
            for _, guiObj in ipairs(guis) do
                if type(guiObj) == 'table' then
                    for _, tag in ipairs(guiObj) do
                        tag.Visible = false
                    end
                elseif guiObj:IsA("TextLabel") or guiObj:IsA("Frame") then
                    guiObj.Visible = false
                elseif guiObj:IsA("Highlight") then
                    guiObj.Enabled = false
                end
            end
        end
        return
    end
    
    local camera = workspace.CurrentCamera
    local localPlayer = Players.LocalPlayer
    local localCharacter = localPlayer.Character
    local localHRP = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    
    for player, drawings in pairs(self._drawings) do
        local outline, box, fill = drawings[1], drawings[2], drawings[3]
        local guis = self._guis[player]
        
        if not guis or not self:_ShouldShowESP(player) then
            for _, drawing in ipairs(drawings) do
                drawing.Visible = false
            end
            continue
        end
        
        local healthbarOutline, barBG, barFill, healthChangeTags, nameTag, distanceTag, velocityTag, highlight = 
            unpack(guis)
        
        if not player.Character then
            for _, drawing in ipairs(drawings) do
                drawing.Visible = false
            end
            continue
        end
        
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            for _, drawing in ipairs(drawings) do
                drawing.Visible = false
            end
            continue
        end
        
        local screenPos = camera:WorldToViewportPoint(hrp.Position)
        if screenPos.Z <= 0 then
            for _, drawing in ipairs(drawings) do
                drawing.Visible = false
            end
            continue
        end
        
        -- Get box corners
        local corners, width, height = self:_GetBoxCorners(player.Character)
        if not corners then
            for _, drawing in ipairs(drawings) do
                drawing.Visible = false
            end
            continue
        end
        
        -- Update box and outline
        if self.Settings.Box.Enabled then
            local boxColor = self.Settings.Box.ColorTeam and player.Team and player.TeamColor.Color or self.Settings.Box.Color
            
            box.Visible = true
            box.Color = boxColor
            box.Thickness = self.Settings.Box.Thickness
            box.PointA = corners.topLeft
            box.PointB = corners.topRight
            box.PointC = corners.bottomRight
            box.PointD = corners.bottomLeft
            
            if self.Settings.Outline.Enabled then
                outline.Visible = true
                outline.PointA = corners.topLeft
                outline.PointB = corners.topRight
                outline.PointC = corners.bottomRight
                outline.PointD = corners.bottomLeft
            else
                outline.Visible = false
            end
            
            -- Update fill
            if self.Settings.Box.Filled then
                fill.Visible = true
                fill.Color = boxColor
                fill.PointA = corners.topLeft
                fill.PointB = corners.topRight
                fill.PointC = corners.bottomRight
                fill.PointD = corners.bottomLeft
                fill.Transparency = self.Settings.Box.FilledTransparency
            else
                fill.Visible = false
            end
        else
            box.Visible = false
            outline.Visible = false
            fill.Visible = false
        end
        
        -- Update healthbar
        if self.Settings.Healthbar.Enabled then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local healthPerc = humanoid and math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1) or 0
            
            -- Healthbar position
            local healthbarX = corners.topLeft.X - self.Settings.Healthbar.Width - 4
            
            healthbarOutline.Visible = true
            healthbarOutline.Position = UDim2.fromOffset(healthbarX, corners.topLeft.Y - 1)
            healthbarOutline.Size = UDim2.fromOffset(self.Settings.Healthbar.Width + 2, height + 2)
            
            barBG.Size = UDim2.fromOffset(self.Settings.Healthbar.Width, height)
            
            -- Animate healthbar
            if self._healthStates[player] then
                local targetHeight = height * healthPerc
                
                if self.Settings.Healthbar.Gradient.LerpAnimation then
                    self._healthStates[player] = self._healthStates[player] + 
                        (healthPerc - self._healthStates[player]) * self.Settings.Healthbar.Gradient.LerpSpeed
                    targetHeight = height * self._healthStates[player]
                else
                    self._healthStates[player] = healthPerc
                end
                
                barFill.Size = UDim2.fromOffset(self.Settings.Healthbar.Width, targetHeight)
                barFill.Position = UDim2.fromOffset(0, height - targetHeight)
            end
            
            -- Check for health changes
            if self.Settings.HealthChange.Enabled then
                local currentTime = tick()
                local lastCheck = self._lastHealthCheck[player]
                
                if lastCheck and (currentTime - lastCheck.time) >= self.Settings.HealthChange.CheckInterval then
                    local healthChange = math.floor((healthPerc - lastCheck.health) * 100)
                    
                    if math.abs(healthChange) >= 1 then
                        self:_ShowHealthChange(player, healthChange)
                    end
                    
                    self._lastHealthCheck[player] = {
                        health = healthPerc,
                        time = currentTime,
                    }
                end
                
                self:_UpdateHealthChange(player, healthChangeTags, healthbarX, corners.topLeft.Y, height)
            end
        else
            healthbarOutline.Visible = false
        end
        
        -- Update nametag
        if self.Settings.Nametag.Enabled then
            nameTag.Visible = true
            nameTag.Text = self.Settings.Nametag.UseDisplayName and player.DisplayName or player.Name
            nameTag.Position = UDim2.fromOffset(
                (corners.topLeft.X + corners.topRight.X) / 2 - 30,
                corners.topLeft.Y + self.Settings.Nametag.Offset.Y
            )
        else
            nameTag.Visible = false
        end
        
        -- Update distance tag
        if self.Settings.Distance.Enabled and localHRP then
            distanceTag.Visible = true
            local distance = math.floor((localHRP.Position - hrp.Position).Magnitude)
            distanceTag.Text = "[" .. distance .. "m]"
            distanceTag.Position = UDim2.fromOffset(
                (corners.bottomLeft.X + corners.bottomRight.X) / 2 - 30,
                corners.bottomLeft.Y + self.Settings.Distance.Offset.Y
            )
        else
            distanceTag.Visible = false
        end
        
        -- Update velocity tag
        if self.Settings.Velocity.Enabled then
            velocityTag.Visible = true
            local velocity = math.floor(hrp.Velocity.Magnitude)
            velocityTag.Text = "V:" .. velocity
            velocityTag.Position = UDim2.fromOffset(corners.topRight.X + 5, corners.topRight.Y - 3)
        else
            velocityTag.Visible = false
        end
        
        -- Update highlight
        if self.Settings.Highlight.Enabled then
            highlight.Enabled = true
            highlight.Adornee = player.Character
        else
            highlight.Enabled = false
        end
    end
end

-- Public API
function BoxESP:Toggle()
    self.Settings.Enabled = not self.Settings.Enabled
    return self.Settings.Enabled
end

function BoxESP:SetEnabled(state)
    self.Settings.Enabled = state
    return self
end

function BoxESP:IsEnabled()
    return self.Settings.Enabled
end

function BoxESP:UpdateSettings(newSettings)
    for category, settings in pairs(newSettings) do
        if self.Settings[category] and type(settings) == "table" then
            for key, value in pairs(settings) do
                if self.Settings[category][key] ~= nil then
                    self.Settings[category][key] = value
                end
            end
        elseif self.Settings[category] ~= nil then
            self.Settings[category] = settings
        end
    end
    return self
end

function BoxESP:GetSettings()
    return self.Settings
end

function BoxESP:Refresh()
    self:_CleanupAllESP()
    self:Initialize()
    return self
end

function BoxESP:Destroy()
    -- Disconnect all connections
    for _, connection in ipairs(self._connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    
    -- Clean up all ESP objects
    self:_CleanupAllESP()
    
    -- Destroy ScreenGui
    if self._screenGui then
        SafeDestroy(self._screenGui)
        self._screenGui = nil
    end
    
    -- Clear all tables
    self._connections = {}
    self._drawings = {}
    self._guis = {}
    self._healthStates = {}
    self._healthChanges = {}
    self._lastHealthCheck = {}
    self._players = {}
    
    return nil
end

-- Initialization
function BoxESP:Initialize()
    -- Clean up existing instance
    if self._screenGui then
        self:Destroy()
    end
    
    -- Create ScreenGui
    self._screenGui = Instance.new("ScreenGui")
    self._screenGui.Name = "BoxESPScreenGui"
    self._screenGui.IgnoreGuiInset = true
    self._screenGui.ResetOnSpawn = false
    self._screenGui.Parent = CoreGui
    
    -- Set up player tracking
    local localPlayer = Players.LocalPlayer
    
    -- Local player team change
    table.insert(self._connections, 
        localPlayer:GetPropertyChangedSignal("Team"):Connect(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer then
                    self:_HandlePlayerAdded(player)
                end
            end
        end)
    )
    
    -- Add existing players
    for _, player in ipairs(Players:GetPlayers()) do
        self:_HandlePlayerAdded(player)
    end
    
    -- Player added/removed events
    table.insert(self._connections,
        Players.PlayerAdded:Connect(function(player)
            self:_HandlePlayerAdded(player)
        end)
    )
    
    table.insert(self._connections,
        Players.PlayerRemoving:Connect(function(player)
            self:_HandlePlayerRemoving(player)
        end)
    )
    
    -- Keybind
    table.insert(self._connections,
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == self.Settings.Keybind then
                self:Toggle()
            end
        end)
    )
    
    -- Main render loop
    table.insert(self._connections,
        RunService.RenderStepped:Connect(function()
            self:_UpdateESP()
        end)
    )
    
    return self
end

-- Create new instance
function BoxESP.new()
    local self = setmetatable({}, BoxESP)
    return self
end

return BoxESP
