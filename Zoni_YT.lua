--[[
    Zoni_YT Control Hub
    Roblox Studio LocalScript
    UI: dark charcoal + gold sidebar layout.

    This is the single-file client LocalScript for Zoni_YT.
    God Mode uses the earlier local client-side implementation.
    Auto Heal is an additional survival toggle.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

--// CONFIG
local CONFIG = {
    Name = "Zoni_YT",
    PanelSize = UDim2.fromOffset(850, 570),
    Accent = Color3.fromRGB(110, 204, 158),
    AccentLight = Color3.fromRGB(168, 227, 197),
    AccentDark = Color3.fromRGB(32, 54, 44),
    Background = Color3.fromRGB(12, 13, 17),
    Sidebar = Color3.fromRGB(14, 15, 20),
    Card = Color3.fromRGB(24, 25, 31),
    CardAlt = Color3.fromRGB(34, 35, 42),
    Text = Color3.fromRGB(246, 245, 241),
    Muted = Color3.fromRGB(186, 192, 205),
    Green = Color3.fromRGB(93, 198, 137),
    Red = Color3.fromRGB(211, 91, 88),
}

--// CLEAN OLD GUI
local oldGui = PlayerGui:FindFirstChild("Zoni_YT_ControlHub")
if oldGui then
    oldGui:Destroy()
end

--// HELPERS
local function addCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = object
    return corner
end

local function addStroke(object, color, transparency, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(55, 55, 58)
    stroke.Transparency = transparency or 0
    stroke.Thickness = thickness or 1
    stroke.Parent = object
    return stroke
end

local function addGradient(object, topColor, bottomColor, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, topColor),
        ColorSequenceKeypoint.new(1, bottomColor),
    })
    gradient.Rotation = rotation or 90
    gradient.Parent = object
    return gradient
end

local function makeText(parent, text, size, color, font)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.TextColor3 = color or CONFIG.Text
    label.TextSize = size or 14
    label.Font = font or Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

local function makeButton(parent, text, size, position, color)
    local button = Instance.new("TextButton")
    button.AutoButtonColor = false
    button.Text = text or ""
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = color or CONFIG.CardAlt
    button.TextColor3 = CONFIG.Text
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 12
    button.Parent = parent
    addCorner(button, 8)
    addStroke(button, Color3.fromRGB(109, 91, 58), 0.72, 1)
    return button
end

local function tween(object, properties, duration)
    TweenService:Create(
        object,
        TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        properties
    ):Play()
end

local function getCharacter()
    return Player.Character
end

local function getRoot(character)
    character = character or getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(character)
    character = character or getCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

local statusLabel

local function notify(message)
    if statusLabel then
        statusLabel.Text = message
        statusLabel.TextTransparency = 0
        task.delay(2.5, function()
            if statusLabel and statusLabel.Parent then
                tween(statusLabel, {TextTransparency = 0.35}, 0.3)
            end
        end)
    end
end

--// GUI ROOT
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Zoni_YT_ControlHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false
ScreenGui.DisplayOrder = 50
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = CONFIG.PanelSize
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.BackgroundColor3 = CONFIG.Background
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui
addCorner(Main, 16)
addStroke(Main, Color3.fromRGB(111, 88, 49), 0.28, 1)
addGradient(Main, Color3.fromRGB(22, 23, 29), Color3.fromRGB(11, 12, 16), 35)

-- Scale down on smaller screens
local UIScale = Instance.new("UIScale")
UIScale.Parent = Main
local function updateScale()
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
    if viewport then
        UIScale.Scale = math.clamp(math.min(viewport.X / 900, viewport.Y / 610), 0.1, 1)
    end
end
updateScale()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

--// SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 178, 1, 0)
Sidebar.BackgroundColor3 = CONFIG.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
addCorner(Sidebar, 16)
addGradient(Sidebar, Color3.fromRGB(19, 20, 26), Color3.fromRGB(12, 13, 18), 90)

local SideCover = Instance.new("Frame")
SideCover.Size = UDim2.new(0, 12, 1, 0)
SideCover.Position = UDim2.new(1, -12, 0, 0)
SideCover.BackgroundColor3 = CONFIG.Sidebar
SideCover.BorderSizePixel = 0
SideCover.Parent = Sidebar

local SideDivider = Instance.new("Frame")
SideDivider.Size = UDim2.new(0, 1, 1, -30)
SideDivider.Position = UDim2.new(1, 0, 0, 15)
SideDivider.BackgroundColor3 = Color3.fromRGB(48, 47, 44)
SideDivider.BorderSizePixel = 0
SideDivider.Parent = Sidebar

do
    for i, color in ipairs({Color3.fromRGB(235,100,103), Color3.fromRGB(233,187,91), CONFIG.Accent}) do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(7,7)
        dot.Position = UDim2.fromOffset(15+(i-1)*11,10)
        dot.BackgroundColor3 = color
        dot.BorderSizePixel = 0
        dot.Parent = Sidebar
        addCorner(dot,4)
    end
    local brand = makeText(Sidebar,"ZONI",21,CONFIG.Text,Enum.Font.GothamBold)
    brand.Position = UDim2.fromOffset(15,21)
    brand.Size = UDim2.fromOffset(140,26)
    local subtitle = makeText(Sidebar,"CONTROL MENU",9,CONFIG.Muted,Enum.Font.Gotham)
    subtitle.Position = UDim2.fromOffset(16,47)
    subtitle.Size = UDim2.fromOffset(140,14)
end

local SideLine = Instance.new("Frame")
SideLine.Size = UDim2.new(1, -28, 0, 1)
SideLine.Position = UDim2.fromOffset(14, 66)
SideLine.BackgroundColor3 = Color3.fromRGB(48, 47, 44)
SideLine.BorderSizePixel = 0
SideLine.Parent = Sidebar

local NavHolder = Instance.new("ScrollingFrame")
NavHolder.CanvasSize = UDim2.new()
NavHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
NavHolder.ScrollingDirection = Enum.ScrollingDirection.Y
NavHolder.ScrollBarThickness = 3
NavHolder.ScrollBarImageColor3 = CONFIG.Accent
NavHolder.BorderSizePixel = 0
NavHolder.BackgroundTransparency = 1
NavHolder.Position = UDim2.fromOffset(10, 82)
NavHolder.Size = UDim2.new(1, -20, 1, -146)
NavHolder.Parent = Sidebar

local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 5)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Parent = NavHolder

local SideFooter = makeText(Sidebar, "RIGHT CTRL  •  PANEL TOGGLE", 8, CONFIG.Muted, Enum.Font.GothamMedium)
SideFooter.Position = UDim2.new(0, 64, 1, -25)
SideFooter.Size = UDim2.new(1, -68, 0, 18)
SideFooter.TextTransparency = 0.2

do
    local portrait = Instance.new("ImageLabel")
    portrait.Name = "Avatar"
    portrait.Size = UDim2.fromOffset(48,48)
    portrait.Position = UDim2.new(0,10,1,-54)
    portrait.BackgroundColor3 = CONFIG.Card
    portrait.BorderSizePixel = 0
    portrait.Image = "rbxthumb://type=Avatar&id=" .. Player.UserId .. "&w=150&h=150"
    portrait.Parent = Sidebar
    addCorner(portrait,8)
    local name = makeText(Sidebar,Player.DisplayName,13,CONFIG.Text,Enum.Font.GothamBold)
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.Position = UDim2.new(0,64,1,-48)
    name.Size = UDim2.new(1,-70,0,22)
end

--// MAIN CONTENT AREA
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Position = UDim2.fromOffset(198, 0)
ContentArea.Size = UDim2.new(1, -210, 1, 0)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = Main

local Header = Instance.new("Frame")
Header.BackgroundTransparency = 1
Header.Position = UDim2.fromOffset(0, 13)
Header.Size = UDim2.new(1, 0, 0, 67)
Header.Parent = ContentArea

local PageTitle = makeText(Header, "Home", 29, CONFIG.Text, Enum.Font.GothamBlack)
PageTitle.Position = UDim2.fromOffset(0, 0)
PageTitle.Size = UDim2.new(1, -10, 0, 36)

local PageSubtitle = makeText(Header, "Your personal control and movement tools", 11, CONFIG.Muted, Enum.Font.Gotham)
PageSubtitle.Position = UDim2.fromOffset(1, 37)
PageSubtitle.Size = UDim2.new(1, -10, 0, 20)

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -2, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, -1)
HeaderLine.BackgroundColor3 = Color3.fromRGB(62, 55, 42)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

local PageHolder = Instance.new("Frame")
PageHolder.Position = UDim2.fromOffset(0, 91)
PageHolder.Size = UDim2.new(1, 0, 1, -146)
PageHolder.BackgroundTransparency = 1
PageHolder.Parent = ContentArea

local Status = makeText(ContentArea, "Ready", 9, CONFIG.Muted, Enum.Font.Gotham)
Status.Position = UDim2.new(0, 0, 1, -25)
Status.Size = UDim2.new(1, -4, 0, 16)
Status.TextTransparency = 0.35
statusLabel = Status

--// DRAG WINDOW
local dragging = false
local dragInput
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

--// PAGES / NAVIGATION
local pages = {}
local navButtons = {}
local activePage = nil

local function createPage(name, subtitle)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = CONFIG.Accent
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new()
    page.Visible = false
    page.Parent = PageHolder

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 3)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 5)
    padding.Parent = page

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    pages[name] = {
        Frame = page,
        Subtitle = subtitle,
    }
    return page
end

local function selectPage(name)
    local pageData = pages[name]
    if not pageData then return end

    for pageName, data in pairs(pages) do
        data.Frame.Visible = pageName == name
    end

    for buttonName, button in pairs(navButtons) do
        local selected = buttonName == name
        button.BackgroundColor3 = selected and CONFIG.AccentDark or CONFIG.Sidebar
        button.NavLabel.TextColor3 = selected and CONFIG.Text or CONFIG.Muted
        local iconChip = button:FindFirstChild("NavIcon")
        if iconChip then
            iconChip.BackgroundColor3 = selected and CONFIG.Accent or Color3.fromRGB(42, 35, 25)
            iconChip.TextColor3 = selected and Color3.fromRGB(24, 22, 18) or CONFIG.AccentLight
        end
        local marker = button:FindFirstChild("ActiveMarker")
        if marker then marker.Visible = selected end
    end

    PageTitle.Text = name
    PageSubtitle.Text = pageData.Subtitle
    activePage = name
end

local function createNav(name, symbol, order)
    local button = Instance.new("TextButton")
    button.Name = name .. "Nav"
    button.Size = UDim2.new(1, -6, 0, 36)
    button.BackgroundColor3 = CONFIG.Sidebar
    button.AutoButtonColor = false
    button.Text = ""
    button.LayoutOrder = order
    button.Parent = NavHolder
    addCorner(button, 7)

    local marker = Instance.new("Frame")
    marker.Name = "ActiveMarker"
    marker.Size = UDim2.new(0, 3, 1, -10)
    marker.Position = UDim2.fromOffset(0, 5)
    marker.BackgroundColor3 = CONFIG.Accent
    marker.BorderSizePixel = 0
    marker.Visible = false
    marker.Parent = button
    addCorner(marker, 2)

    local icon = makeText(button, symbol, 15, CONFIG.Muted, Enum.Font.GothamBold)
    icon.Name = "NavIcon"
    icon.Size = UDim2.fromOffset(27, 24)
    icon.Position = UDim2.fromOffset(8, 6)
    icon.BackgroundTransparency = 0
    icon.BackgroundColor3 = Color3.fromRGB(42, 35, 25)
    icon.TextColor3 = CONFIG.AccentLight
    icon.TextSize = 9
    icon.TextXAlignment = Enum.TextXAlignment.Center
    addCorner(icon, 6)

    local label = makeText(button, name, 11, CONFIG.Muted, Enum.Font.GothamMedium)
    label.Name = "NavLabel"
    label.Position = UDim2.fromOffset(42, 0)
    label.Size = UDim2.new(1, -50, 1, 0)

    button.MouseEnter:Connect(function()
        if activePage ~= name then
            tween(button, {BackgroundColor3 = CONFIG.Card}, 0.12)
        end
    end)
    button.MouseLeave:Connect(function()
        if activePage ~= name then
            tween(button, {BackgroundColor3 = CONFIG.Sidebar}, 0.12)
        end
    end)
    button.MouseButton1Click:Connect(function()
        selectPage(name)
    end)

    navButtons[name] = button
end

--// CARD / ROW BUILDERS
local function createSection(parent, title, description)
    local section = Instance.new("Frame")
    section.BackgroundTransparency = 1
    section.Size = UDim2.new(1, -8, 0, 32)
    section.Parent = parent

    local line = Instance.new("Frame")
    line.Size = UDim2.fromOffset(3, 25)
    line.Position = UDim2.fromOffset(0, 2)
    line.BackgroundColor3 = CONFIG.Accent
    line.BorderSizePixel = 0
    line.Parent = section
    addCorner(line, 2)

    local titleLabel = makeText(section, title:upper(), 9, CONFIG.AccentLight, Enum.Font.GothamBlack)
    titleLabel.Position = UDim2.fromOffset(10, 0)
    titleLabel.Size = UDim2.new(1, -10, 0, 14)

    if description then
        local desc = makeText(section, description, 9, CONFIG.Muted, Enum.Font.Gotham)
        desc.Position = UDim2.fromOffset(10, 14)
        desc.Size = UDim2.new(1, -10, 0, 14)
    end
    return section
end

local ROW_ICONS = {
    ["Welcome to Zoni_YT"] = "ZY", ["God Mode"] = "GM", ["Auto Heal"] = "HP",
    ["Reset Character"] = "RST", ["Fly"] = "FLY", ["Noclip"] = "NCL",
    ["Walk Speed"] = "SPD", ["Jump Power"] = "JMP", ["Fly Speed"] = "AIR",
    ["World Gravity"] = "GRV", ["Coordinate Input"] = "XYZ", ["Copy Coordinates"] = "CPY",
    ["Teleport to Coordinates"] = "TP", ["Tap TP"] = "TAP", ["Saved Farm Spot"] = "AFK",
    ["Teleport to Farm"] = "FARM", ["AFK Farm"] = "AFK", ["Treadmill Auto Run"] = "RUN",
    ["Treadmill Boost"] = "BST", ["Treadmill Boost Speed"] = "SPD", ["Run Direction"] = "DIR",
    ["Return After Respawn"] = "RSP", ["Anti-AFK Monitor"] = "MON", ["Reward limitation"] = "INFO",
    ["Idle limitation"] = "IDLE", ["Hide Panel"] = "UI", ["Reset Movement"] = "RST",
    ["Disable Active Tools"] = "ALL", ["Save Position"] = "SAVE", ["Return to Saved Position"] = "BACK",
    ["Fullbright"] = "LIT", ["Camera Field of View"] = "FOV", ["Rejoin Current Server"] = "JOIN",
    ["My Profile"] = "ME", ["Copy Place ID"] = "ID", ["Find Roblox Username"] = "FIND",
    ["Current Server Filter"] = "SRV", ["Players Online"] = "USR", ["Open Profile"] = "PRO",
}

local function getRowIcon(title)
    if ROW_ICONS[title] then return ROW_ICONS[title] end
    local clean = string.upper(title:gsub("[^%w]", ""))
    return clean:sub(1, math.min(3, #clean))
end

local function createRow(parent, title, description, height)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, height or 66)
    row.BackgroundColor3 = Color3.new(1, 1, 1)
    row.BorderSizePixel = 0
    row.Parent = parent
    addCorner(row, 11)
    addStroke(row, Color3.fromRGB(96, 76, 43), 0.58, 1)
    addGradient(row, Color3.fromRGB(37, 43, 55), Color3.fromRGB(21, 25, 34), 0)

    local accentRail = Instance.new("Frame")
    accentRail.Name = "AccentRail"
    accentRail.Size = UDim2.new(0, 3, 1, -22)
    accentRail.Position = UDim2.fromOffset(0, 11)
    accentRail.BackgroundColor3 = CONFIG.Accent
    accentRail.BorderSizePixel = 0
    accentRail.Parent = row
    addCorner(accentRail, 3)

    local iconBox = Instance.new("Frame")
    iconBox.Name = "IconBadge"
    iconBox.Size = UDim2.fromOffset(29, 29)
    iconBox.Position = UDim2.fromOffset(10, math.max(8, ((height or 66) - 29) / 2))
    iconBox.BackgroundColor3 = Color3.fromRGB(53, 42, 25)
    iconBox.BorderSizePixel = 0
    iconBox.Parent = row
    addCorner(iconBox, 8)
    addStroke(iconBox, Color3.fromRGB(154, 116, 55), 0.38, 1)

    local iconLabel = makeText(iconBox, getRowIcon(title), 9, CONFIG.AccentLight, Enum.Font.GothamBlack)
    iconLabel.Size = UDim2.fromScale(1, 1)
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center

    local titleLabel = makeText(row, title, 14, CONFIG.Text, Enum.Font.GothamMedium)
    titleLabel.Name = "RowTitle"
    titleLabel.Position = UDim2.fromOffset(48, 10)
    titleLabel.Size = UDim2.new(1, -184, 0, 20)

    local descLabel = makeText(row, description or "", 11, CONFIG.Muted, Enum.Font.Gotham)
    descLabel.Name = "RowDescription"
    descLabel.Position = UDim2.fromOffset(48, 29)
    descLabel.Size = UDim2.new(1, -184, 0, 27)
    descLabel.TextWrapped = true

    return row
end

local function createActionRow(parent, title, description, buttonText, callback, color)
    local row = createRow(parent, title, description, 66)
    local button = makeButton(row, buttonText, UDim2.fromOffset(112, 32), UDim2.new(1, -146, 0.5, -16), color or CONFIG.AccentDark)
    addGradient(button, Color3.new(1, 1, 1), Color3.fromRGB(225, 221, 212), 90)
    button.TextColor3 = (color == CONFIG.Accent) and Color3.fromRGB(25, 23, 18) or CONFIG.Text
    button.MouseEnter:Connect(function()
        tween(button, {BackgroundColor3 = CONFIG.Accent}, 0.12)
        button.TextColor3 = Color3.fromRGB(25, 23, 18)
    end)
    button.MouseLeave:Connect(function()
        tween(button, {BackgroundColor3 = color or CONFIG.AccentDark}, 0.12)
        button.TextColor3 = (color == CONFIG.Accent) and Color3.fromRGB(25, 23, 18) or CONFIG.Text
    end)
    button.MouseButton1Click:Connect(callback)
    return row, button
end

local function createToggleRow(parent, title, description, initial, callback)
    local row = createRow(parent, title, description, 66)
    local enabled = initial == true
    local toggle = makeButton(
        row,
        enabled and "ON" or "OFF",
        UDim2.fromOffset(76, 31),
        UDim2.new(1, -90, 0.5, -15),
        enabled and CONFIG.Accent or CONFIG.CardAlt
    )
    local toggleGradient = addGradient(toggle,
        enabled and CONFIG.AccentLight or Color3.fromRGB(49, 50, 59),
        enabled and CONFIG.Accent or Color3.fromRGB(30, 31, 38), 90)
    toggle.TextColor3 = enabled and Color3.fromRGB(26, 23, 17) or CONFIG.Muted

    local function update(value, fireCallback)
        enabled = value
        toggle.Text = enabled and "ON" or "OFF"
        tween(toggle, {
            BackgroundColor3 = enabled and CONFIG.Accent or CONFIG.CardAlt,
        }, 0.12)
        toggleGradient.Color = enabled
            and ColorSequence.new(CONFIG.AccentLight, CONFIG.Accent)
            or ColorSequence.new(Color3.fromRGB(49, 50, 59), Color3.fromRGB(30, 31, 38))
        toggle.TextColor3 = enabled and Color3.fromRGB(26, 23, 17) or CONFIG.Muted
        if fireCallback and callback then
            callback(enabled)
        end
    end

    toggle.MouseButton1Click:Connect(function()
        update(not enabled, true)
    end)

    return row, function(value)
        update(value, false)
    end, function()
        return enabled
    end
end

local function createSliderRow(parent, title, description, minimum, maximum, defaultValue, callback)
    local row = createRow(parent, title, description, 78)
    local valueLabel = makeText(row, tostring(defaultValue), 11, CONFIG.Accent, Enum.Font.GothamBold)
    valueLabel.Position = UDim2.new(1, -104, 0, 8)
    valueLabel.Size = UDim2.fromOffset(88, 23)
    valueLabel.BackgroundColor3 = Color3.fromRGB(47, 39, 25)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    addCorner(valueLabel, 6)
    addStroke(valueLabel, Color3.fromRGB(116, 91, 49), 0.5, 1)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -28, 0, 5)
    bar.Position = UDim2.fromOffset(14, 59)
    bar.BackgroundColor3 = Color3.fromRGB(51, 52, 60)
    bar.BorderSizePixel = 0
    bar.Parent = row
    addCorner(bar, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultValue - minimum) / (maximum - minimum), 0, 1, 0)
    fill.BackgroundColor3 = CONFIG.Accent
    fill.BorderSizePixel = 0
    fill.Parent = bar
    addCorner(fill, 4)
    addGradient(fill, CONFIG.AccentLight, CONFIG.Accent, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(13, 13)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((defaultValue - minimum) / (maximum - minimum), 0, 0.5, 0)
    knob.BackgroundColor3 = CONFIG.Text
    knob.BorderSizePixel = 0
    knob.Parent = bar
    addCorner(knob, 7)
    addStroke(knob, CONFIG.Accent, 0.1, 1)

    local currentValue = defaultValue
    local isDragging = false

    local function setValue(value)
        currentValue = math.clamp(math.floor(value + 0.5), minimum, maximum)
        local percent = (currentValue - minimum) / (maximum - minimum)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, 0, 0.5, 0)
        valueLabel.Text = tostring(currentValue)
        if callback then callback(currentValue) end
    end

    local function setValueFromX(x)
        local width = math.max(bar.AbsoluteSize.X, 1)
        local percent = math.clamp((x - bar.AbsolutePosition.X) / width, 0, 1)
        setValue(minimum + (maximum - minimum) * percent)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            setValueFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setValueFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    return row, function()
        return currentValue
    end, setValue
end

--// PAGE CONSTRUCTION
local homePage = createPage("Home", "Welcome back • your control hub is ready")
local playerPage = createPage("Player", "Character protection and player actions")
local movementPage = createPage("Movement", "Movement controls, speed and jump settings")
local teleportPage = createPage("Teleport", "Coordinate tools and click-to-teleport")
local playersPage = createPage("Players", "Players currently connected to this server")
local afkPage = createPage("AFK Farm", "Farm location, return behavior and idle monitoring")
local utilitiesPage = createPage("Utilities", "Saved positions and return tools")
local treadmillPage = createPage("Treadmill", "Enable AFK Farm to use the running controls")
local visualsPage = createPage("Visuals", "Camera and lighting")
local sessionPage = createPage("Session", "Server and profile tools")
local settingsPage = createPage("Settings", "Panel preferences and customizable keybinds")

createNav("Home", "HM", 1)
createNav("Player", "PL", 2)
createNav("Movement", "MV", 3)
createNav("Teleport", "TP", 4)
createNav("Players", "US", 5)
createNav("AFK Farm", "AF", 6)
createNav("Treadmill", "TR", 7)
createNav("Utilities", "UT", 8)
createNav("Visuals", "FX", 9)
createNav("Session", "SV", 10)
createNav("Settings", "ST", 11)

--// STATE
local flyEnabled = false
local noclipEnabled = false
local tapTeleportEnabled = false
local flySpeed = 5000
local walkSpeed = 5000
local jumpPower = 50
local selectedGravity = workspace.Gravity
local originalGravity = workspace.Gravity
local savedPositionCFrame = nil
local fullbrightEnabled = false
local savedLightingState = nil
local dashboardSessionCard = nil
local CoordBox = nil
local flyToggleSetter, noclipToggleSetter = nil, nil
local walkSpeedSetter, jumpPowerSetter, flySpeedSetter, gravitySetter = nil, nil, nil, nil
local tapToggleSetter = nil
local afkFarmToggleSetter, afkAutoRunToggleSetter = nil, nil
local antiAfkToggleSetter, returnFarmToggleSetter = nil, nil

--// ORIGINAL LOCAL GOD MODE + AUTO HEAL
-- These are client-side features. Server-owned/custom damage systems can
-- override local health changes; add checks to your own server damage code
-- when you need protection that is authoritative for the whole experience.
local godModeEnabled = false
local godModeHealthConnection = nil
local godToggleSetter = nil

local function removeLocalGodMode(character)
    if godModeHealthConnection then
        godModeHealthConnection:Disconnect()
        godModeHealthConnection = nil
    end

    local targetCharacter = character or getCharacter()
    if targetCharacter then
        local forceField = targetCharacter:FindFirstChild("ZoniYT_GodModeForceField")
        if forceField then
            forceField:Destroy()
        end
    end
end

local function applyLocalGodMode(character)
    if not godModeEnabled or not character then return end

    local humanoid = getHumanoid(character) or character:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    local forceField = character:FindFirstChild("ZoniYT_GodModeForceField")
    if not forceField then
        forceField = Instance.new("ForceField")
        forceField.Name = "ZoniYT_GodModeForceField"
        forceField.Visible = false
        forceField.Parent = character
    end

    if godModeHealthConnection then
        godModeHealthConnection:Disconnect()
        godModeHealthConnection = nil
    end

    humanoid.Health = humanoid.MaxHealth
    godModeHealthConnection = humanoid.HealthChanged:Connect(function(health)
        if godModeEnabled and humanoid.Parent and health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end

local function setGodMode(enabled)
    godModeEnabled = enabled == true
    if godModeEnabled then
        applyLocalGodMode(getCharacter())
        notify("God Mode ON")
    else
        removeLocalGodMode(getCharacter())
        notify("God Mode OFF")
    end
end

local autoHealEnabled = false
local autoHealConnection = nil
local autoHealToggleSetter = nil

local function stopAutoHeal()
    if autoHealConnection then
        autoHealConnection:Disconnect()
        autoHealConnection = nil
    end
end

local function startAutoHeal(character)
    if not autoHealEnabled or not character then return end

    stopAutoHeal()
    local humanoid = getHumanoid(character) or character:WaitForChild("Humanoid", 5)
    if not humanoid then
        notify("Auto Heal: character not ready")
        return
    end

    -- Heal immediately when enabled, then restore health whenever it drops
    -- while the Humanoid is still alive.
    if humanoid.Health > 0 then
        humanoid.Health = humanoid.MaxHealth
    end

    autoHealConnection = humanoid.HealthChanged:Connect(function(health)
        if not autoHealEnabled or not humanoid.Parent then return end
        if health > 0 and health < humanoid.MaxHealth then
            task.defer(function()
                if autoHealEnabled and humanoid.Parent and humanoid.Health > 0 then
                    humanoid.Health = humanoid.MaxHealth
                end
            end)
        end
    end)
end

local function setAutoHeal(enabled)
    autoHealEnabled = enabled == true
    if autoHealEnabled then
        startAutoHeal(getCharacter())
        notify("Auto Heal ON")
    else
        stopAutoHeal()
        notify("Auto Heal OFF")
    end
end

--// AFK FARM / TREADMILL RUNNER / IDLE MONITOR
local AFK_FARM_POSITION = Vector3.new(-7748.99, 419.31, -2097.41)
local afkFarmEnabled = false
local afkAutoRunEnabled = true
local returnToFarmAfterRespawn = true
local antiAfkMonitorEnabled = false
local antiAfkConnection = nil
local lastIdleNotice = 0
local afkRunConnection = nil
local afkDirectionButton = nil
local treadmillBoostEnabled = false
local treadmillBoostSpeed = 5000
local treadmillBoostToggleSetter = nil
local treadmillBoostSpeedSetter = nil
local applyMovementSettings -- forward declaration used by AFK controls above the movement section

-- Direction is relative to the character's facing direction, so the player
-- can test which way the treadmill faces without us inspecting the game.
local afkRunDirections = {
    {Name = "Forward", Vector = function(root) return root.CFrame.LookVector end},
    {Name = "Backward", Vector = function(root) return -root.CFrame.LookVector end},
    {Name = "Left", Vector = function(root) return -root.CFrame.RightVector end},
    {Name = "Right", Vector = function(root) return root.CFrame.RightVector end},
}
local afkRunDirectionIndex = 1

local function stopAfkRunning()
    if afkRunConnection then
        afkRunConnection:Disconnect()
        afkRunConnection = nil
    end
    local humanoid = getHumanoid()
    if humanoid then
        humanoid:Move(Vector3.zero, false)
    end
end

local function startAfkRunning()
    if not afkFarmEnabled or not afkAutoRunEnabled then return false end

    if afkRunConnection then
        afkRunConnection:Disconnect()
        afkRunConnection = nil
    end

    local character = getCharacter()
    local humanoid = getHumanoid(character)
    if not character or not humanoid or humanoid.Health <= 0 then
        notify("Treadmill Auto Run: character not ready")
        return false
    end

    afkRunConnection = RunService.Heartbeat:Connect(function()
        if not afkFarmEnabled or not afkAutoRunEnabled then
            stopAfkRunning()
            return
        end

        local currentCharacter = getCharacter()
        local currentHumanoid = getHumanoid(currentCharacter)
        local root = getRoot(currentCharacter)
        if not currentHumanoid or not root or currentHumanoid.Health <= 0 then
            return
        end

        -- Treadmill Boost changes the local Humanoid movement speed while
        -- AFK Farm is active. The experience's server still decides rewards.
        if treadmillBoostEnabled then
            currentHumanoid.WalkSpeed = treadmillBoostSpeed
        end

        local directionData = afkRunDirections[afkRunDirectionIndex]
        local direction = directionData.Vector(root)
        direction = Vector3.new(direction.X, 0, direction.Z)
        if direction.Magnitude > 0.01 then
            currentHumanoid:Move(direction.Unit, false)
        end
    end)

    notify("Treadmill Auto Run ON • " .. afkRunDirections[afkRunDirectionIndex].Name)
    return true
end

local function setAfkAutoRun(enabled)
    afkAutoRunEnabled = enabled == true
    if afkAutoRunEnabled and afkFarmEnabled then
        startAfkRunning()
    else
        stopAfkRunning()
    end
    notify(afkAutoRunEnabled and "Treadmill Auto Run ON" or "Treadmill Auto Run OFF")
end

local function setTreadmillBoost(enabled)
    treadmillBoostEnabled = enabled == true
    if afkFarmEnabled and treadmillBoostEnabled then
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = treadmillBoostSpeed
        end
        notify("Treadmill Boost ON • WalkSpeed " .. tostring(treadmillBoostSpeed))
    else
        applyMovementSettings()
        notify(treadmillBoostEnabled
            and "Treadmill Boost ready • enable AFK Farm to apply"
            or "Treadmill Boost OFF")
    end
end

local function setTreadmillBoostSpeed(value)
    treadmillBoostSpeed = math.clamp(math.floor(value + 0.5), 16, 5000)
    if treadmillBoostEnabled and afkFarmEnabled then
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = treadmillBoostSpeed
        end
    end
end

local function cycleAfkRunDirection()
    afkRunDirectionIndex = (afkRunDirectionIndex % #afkRunDirections) + 1
    local directionName = afkRunDirections[afkRunDirectionIndex].Name
    if afkDirectionButton then
        afkDirectionButton.Text = directionName:upper()
    end
    notify("Treadmill direction: " .. directionName)
end

local function teleportToFarmSpot()
    local root = getRoot()
    if not root then
        notify("AFK Farm: character not ready")
        return false
    end

    root.CFrame = CFrame.new(AFK_FARM_POSITION)
    notify("Teleported to AFK Farm spot")
    return true
end

local function setAfkFarm(enabled)
    afkFarmEnabled = enabled == true
    if afkFarmEnabled then
        if teleportToFarmSpot() and afkAutoRunEnabled then
            task.delay(0.2, startAfkRunning)
        end
        notify("AFK Farm ON • Auto Run: " .. (afkAutoRunEnabled and "ON" or "OFF"))
    else
        stopAfkRunning()
        applyMovementSettings()
        notify("AFK Farm OFF")
    end
end

-- Roblox's Idled event can report idle state, but a normal Studio LocalScript
-- cannot cancel the platform's automatic 20-minute idle disconnect.
local function setAntiAfkMonitor(enabled)
    antiAfkMonitorEnabled = enabled == true
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end

    if antiAfkMonitorEnabled then
        antiAfkConnection = Player.Idled:Connect(function(idleTime)
            if not antiAfkMonitorEnabled then return end
            local now = os.clock()
            if now - lastIdleNotice >= 25 then
                lastIdleNotice = now
                notify(string.format("Idle detected: %d sec • Roblox idle kick still applies", math.floor(idleTime)))
            end
        end)
        notify("Idle monitor ON • standard Roblox AFK kick cannot be disabled here")
    else
        notify("Idle monitor OFF")
    end
end

--// FLY
local flyVelocity = nil
local flyGyro = nil
local flyConnection = nil
local flyHumanoid = nil
local previousPlatformStand = false
local previousAutoRotate = true

local function stopFly()
    flyEnabled = false

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if flyVelocity then
        flyVelocity:Destroy()
        flyVelocity = nil
    end
    if flyGyro then
        flyGyro:Destroy()
        flyGyro = nil
    end
    if flyHumanoid and flyHumanoid.Parent then
        flyHumanoid.PlatformStand = previousPlatformStand
        flyHumanoid.AutoRotate = previousAutoRotate
    end
    flyHumanoid = nil
end

local function startFly()
    local character = getCharacter()
    local root = getRoot(character)
    local humanoid = getHumanoid(character)
    if not root or not humanoid then
        notify("Character is not ready")
        return false
    end

    stopFly()
    flyEnabled = true
    flyHumanoid = humanoid
    previousPlatformStand = humanoid.PlatformStand
    previousAutoRotate = humanoid.AutoRotate
    humanoid.PlatformStand = true
    humanoid.AutoRotate = false

    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.Name = "Zoni_YT_FlyVelocity"
    flyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyVelocity.P = 1e5
    flyVelocity.Velocity = Vector3.zero
    flyVelocity.Parent = root

    flyGyro = Instance.new("BodyGyro")
    flyGyro.Name = "Zoni_YT_FlyGyro"
    flyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyGyro.P = 1e5
    flyGyro.CFrame = Camera.CFrame
    flyGyro.Parent = root

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flyEnabled or not root.Parent then
            stopFly()
            return
        end

        Camera = workspace.CurrentCamera or Camera
        local direction = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then
            direction += Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            direction -= Vector3.new(0, 1, 0)
        end

        flyVelocity.Velocity = direction.Magnitude > 0 and direction.Unit * flySpeed or Vector3.zero
        flyGyro.CFrame = Camera.CFrame
    end)

    notify("Fly enabled • WASD + Space / Ctrl")
    return true
end

local function setFly(enabled)
    if enabled then
        startFly()
    else
        stopFly()
        notify("Fly disabled")
    end
end

--// NOCLIP
local noclipConnection = nil
local originalCollision = {}

local function setNoclip(enabled)
    noclipEnabled = enabled

    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end

    if enabled then
        table.clear(originalCollision)
        noclipConnection = RunService.Stepped:Connect(function()
            local character = getCharacter()
            if not character then return end

            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if originalCollision[part] == nil then
                        originalCollision[part] = part.CanCollide
                    end
                    part.CanCollide = false
                end
            end
        end)
        notify("Noclip enabled")
    else
        for part, canCollide in pairs(originalCollision) do
            if part and part.Parent then
                part.CanCollide = canCollide
            end
        end
        table.clear(originalCollision)
        notify("Noclip disabled")
    end
end

--// MOVEMENT SETTINGS
applyMovementSettings = function()
    local humanoid = getHumanoid()
    if humanoid then
        local appliedWalkSpeed = (afkFarmEnabled and treadmillBoostEnabled)
            and treadmillBoostSpeed or walkSpeed
        humanoid.WalkSpeed = appliedWalkSpeed
        humanoid.UseJumpPower = true
        humanoid.JumpPower = jumpPower
    end
    workspace.Gravity = selectedGravity
end

--// TELEPORT HELPERS
local function getCoordinates()
    local root = getRoot()
    if not root then return nil end
    local pos = root.Position
    return string.format("%.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z)
end

local function parseCoordinates(value)
    if type(value) ~= "string" then return nil end
    local x, y, z = value:match("^%s*([%+%-]?[%d%.]+)%s*,%s*([%+%-]?[%d%.]+)%s*,%s*([%+%-]?[%d%.]+)%s*$")
    x, y, z = tonumber(x), tonumber(y), tonumber(z)

    if not x or not y or not z then return nil end
    if x ~= x or y ~= y or z ~= z then return nil end
    if math.abs(x) > 1000000 or math.abs(y) > 1000000 or math.abs(z) > 1000000 then return nil end
    return Vector3.new(x, y, z)
end

do
--// HOME PAGE
createSection(homePage, "Overview", "Zoni_YT • premium control hub")

local sessionCard = createRow(homePage, "Live Session", "Place ID: " .. tostring(game.PlaceId) .. " • Server players: " .. tostring(#Players:GetPlayers()), 72)
dashboardSessionCard = sessionCard
local sessionBadge = makeText(sessionCard, "ONLINE", 9, Color3.fromRGB(159, 221, 178), Enum.Font.GothamBlack)
sessionBadge.Size = UDim2.fromOffset(58, 23)
sessionBadge.Position = UDim2.new(1, -73, 0.5, -11)
sessionBadge.BackgroundColor3 = Color3.fromRGB(25, 48, 36)
sessionBadge.TextXAlignment = Enum.TextXAlignment.Center
addCorner(sessionBadge, 6)

local welcome = createRow(homePage, "Welcome to Zoni_YT", "A premium collection of player, movement, teleport and session tools.", 72)
local welcomeTag = makeText(welcome, "V3", 10, Color3.fromRGB(25, 23, 18), Enum.Font.GothamBlack)
welcomeTag.Size = UDim2.fromOffset(37, 23)
welcomeTag.Position = UDim2.new(1, -51, 0.5, -11)
welcomeTag.BackgroundColor3 = CONFIG.Accent
welcomeTag.TextXAlignment = Enum.TextXAlignment.Center
addCorner(welcomeTag, 6)

createSection(homePage, "Quick Actions", "Frequently used controls")
createActionRow(homePage, "Treadmill", "Auto Run, boost speed and running direction.", "OPEN", function()
    selectPage("Treadmill")
end)
createActionRow(homePage, "God Mode", "Earlier local God Mode toggle.", "OPEN", function()
    selectPage("Player")
end)
createActionRow(homePage, "Movement", "Fly, noclip, speed and jump.", "OPEN", function()
    selectPage("Movement")
end)
createActionRow(homePage, "Coordinates", "Copy your position or teleport to coordinates.", "OPEN", function()
    selectPage("Teleport")
end)
createActionRow(homePage, "Player Finder", "Find a Roblox user by username and join when their server is joinable.", "OPEN", function()
    selectPage("Players")
end)
createActionRow(homePage, "Utilities", "Save your position or return to it.", "OPEN", function()
    selectPage("Utilities")
end)

--// PLAYER PAGE
createSection(playerPage, "Character", "Character protection and survival")
godToggleSetter = select(2, createToggleRow(
    playerPage,
    "God Mode",
    "Restore the earlier local ForceField and health-recovery behavior.",
    false,
    setGodMode
))

autoHealToggleSetter = select(2, createToggleRow(
    playerPage,
    "Auto Heal",
    "Automatically restores health while your character is still alive.",
    false,
    setAutoHeal
))

createActionRow(playerPage, "Reset Character", "Respawn your character in the current experience.", "RESET", function()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.Health = 0
        notify("Character reset")
    else
        notify("Character not ready")
    end
end, CONFIG.Red)

--// MOVEMENT PAGE
createSection(movementPage, "Movement", "Fly controls: WASD, Space/E to rise, Ctrl/Q to descend")
flyToggleSetter = select(2, createToggleRow(movementPage, "Fly", "Move freely using your camera direction.", false, setFly))
noclipToggleSetter = select(2, createToggleRow(movementPage, "Noclip", "Walk through parts while enabled.", false, setNoclip))

createSection(movementPage, "Player Settings", "Changes are applied to your current character")
walkSpeedSetter = select(3, createSliderRow(movementPage, "Walk Speed", "Maximum 5000 • very high values may cause physics issues.", 16, 5000, 5000, function(value)
    walkSpeed = value
    applyMovementSettings()
end))
jumpPowerSetter = select(3, createSliderRow(movementPage, "Jump Power", "Requires UseJumpPower to be enabled.", 50, 250, 50, function(value)
    jumpPower = value
    applyMovementSettings()
end))
flySpeedSetter = select(3, createSliderRow(movementPage, "Fly Speed", "Maximum 5000 • controls how quickly Fly moves.", 20, 5000, 5000, function(value)
    flySpeed = value
end))
gravitySetter = select(3, createSliderRow(movementPage, "World Gravity", "Changes local workspace gravity.", 0, 196, math.floor(originalGravity), function(value)
    selectedGravity = value
    applyMovementSettings()
end))

--// TELEPORT PAGE
createSection(teleportPage, "Coordinates", "Use the format X, Y, Z")
local coordRow = createRow(teleportPage, "Coordinate Input", "Paste or type a position below.", 88)

CoordBox = Instance.new("TextBox")
CoordBox.Name = "CoordinateInput"
CoordBox.Size = UDim2.new(1, -28, 0, 30)
CoordBox.Position = UDim2.fromOffset(14, 49)
CoordBox.BackgroundColor3 = Color3.fromRGB(17, 17, 19)
CoordBox.BorderSizePixel = 0
CoordBox.Text = ""
CoordBox.PlaceholderText = "Example: 125.5, 12, -80"
CoordBox.PlaceholderColor3 = CONFIG.Muted
CoordBox.TextColor3 = CONFIG.Text
CoordBox.Font = Enum.Font.Gotham
CoordBox.TextSize = 11
CoordBox.ClearTextOnFocus = false
CoordBox.Parent = coordRow
addCorner(CoordBox, 6)
addStroke(CoordBox, Color3.fromRGB(60, 58, 53), 0.4, 1)

createActionRow(teleportPage, "Copy Coordinates", "Put your current X, Y, Z position into the field.", "COPY COORD", function()
    local coords = getCoordinates()
    if not coords then
        notify("Character not ready")
        return
    end
    CoordBox.Text = coords

    -- Clipboard APIs are not available to normal Roblox LocalScripts.
    -- This optional call works only in environments that explicitly expose setclipboard.
    local copied = false
    if typeof(setclipboard) == "function" then
        copied = pcall(setclipboard, coords)
    end
    notify(copied and "Coordinates copied" or "Coordinates placed in the field • Ctrl+C to copy")
end, CONFIG.Accent)

createActionRow(teleportPage, "Teleport to Coordinates", "Move your character to the entered position.", "TELEPORT", function()
    local position = parseCoordinates(CoordBox.Text)
    local root = getRoot()
    if not position then
        notify("Invalid coordinates • use X, Y, Z")
        return
    end
    if not root then
        notify("Character not ready")
        return
    end
    root.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
    notify("Teleported to coordinates")
end, CONFIG.Accent)

tapToggleSetter = select(2, createToggleRow(
    teleportPage,
    "Tap TP",
    "Click a point in the 3D world to teleport there.",
    false,
    function(enabled)
        tapTeleportEnabled = enabled
        notify(enabled and "Tap TP enabled • click the world" or "Tap TP disabled")
    end
))

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not tapTeleportEnabled then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

    -- Do not teleport when clicking inside the Zoni_YT panel.
    local mousePosition = UserInputService:GetMouseLocation()
    local guiObjects = GuiService:GetGuiObjectsAtPosition(mousePosition.X, mousePosition.Y)
    for _, object in ipairs(guiObjects) do
        if object:IsDescendantOf(Main) then
            return
        end
    end

    Camera = workspace.CurrentCamera or Camera
    if not Camera then return end

    local ray = Camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {getCharacter()}

    local result = workspace:Raycast(ray.Origin, ray.Direction * 1500, params)
    local root = getRoot()
    if result and root then
        root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
        notify("Tap TP complete")
    end
end)

--// AFK FARM PAGE
createSection(afkPage, "Farm Location", "Your saved AFK farm coordinates")
local farmInfo = createRow(afkPage, "Saved Farm Spot", "X: -7748.99    Y: 419.31    Z: -2097.41", 72)
local farmTag = makeText(farmInfo, "SAVED", 9, Color3.fromRGB(25, 23, 18), Enum.Font.GothamBold)
farmTag.Size = UDim2.fromOffset(54, 23)
farmTag.Position = UDim2.new(1, -68, 0.5, -11)
farmTag.BackgroundColor3 = CONFIG.Accent
farmTag.TextXAlignment = Enum.TextXAlignment.Center
addCorner(farmTag, 6)

createActionRow(afkPage, "Teleport to Farm", "Move to the exact coordinates you provided.", "TELEPORT", teleportToFarmSpot, CONFIG.Accent)
afkFarmToggleSetter = select(2, createToggleRow(afkPage, "AFK Farm", "Teleport to the saved spot and keep treadmill farming active.", false, setAfkFarm))

createSection(treadmillPage, "Running", "Set your pace and direction")
afkAutoRunToggleSetter = select(2, createToggleRow(treadmillPage, "Treadmill Auto Run", "Continuously move in the selected direction while AFK Farm is enabled.", true, setAfkAutoRun))

treadmillBoostToggleSetter = select(2, createToggleRow(
    treadmillPage,
    "Treadmill Boost",
    "Use a separate higher local WalkSpeed while AFK Farm is active. The game server controls reward amounts.",
    false,
    setTreadmillBoost
))

treadmillBoostSpeedSetter = select(3, createSliderRow(
    treadmillPage,
    "Treadmill Boost Speed",
    "Local movement speed override • 16 to 5000. Very high values may cause physics issues.",
    16,
    5000,
    5000,
    setTreadmillBoostSpeed
))

afkDirectionButton = select(2, createActionRow(treadmillPage, "Run Direction", "Choose the direction that matches your treadmill. Try Forward first.", "FORWARD", cycleAfkRunDirection, CONFIG.AccentDark))

returnFarmToggleSetter = select(2, createToggleRow(afkPage, "Return After Respawn", "When enabled, AFK Farm teleports you back and restarts Auto Run after respawn.", true, function(enabled)
    returnToFarmAfterRespawn = enabled
    notify(enabled and "Return after respawn ON" or "Return after respawn OFF")
end))

antiAfkToggleSetter = select(2, createToggleRow(afkPage, "Anti-AFK Monitor", "Reports Roblox idle events. It cannot cancel the platform's automatic 20-minute disconnect.", false, setAntiAfkMonitor))

createSection(afkPage, "Important", "AFK farming itself depends on the mechanics of your Roblox experience.")
createRow(treadmillPage, "Reward limitation", "Treadmill Boost changes local movement speed only. The game server decides how much Speed or currency is awarded, so extra rewards are not guaranteed.", 78)
createRow(afkPage, "Idle limitation", "A regular Roblox LocalScript cannot reliably bypass Roblox's built-in idle disconnect.", 72)
end

local playerActions = {}
do
--// PLAYERS PAGE
createSection(playersPage, "Join By Username", "Enter an exact Roblox username • joining is subject to privacy and server availability")

local usernameRow = createRow(playersPage, "Roblox Username", "Find a user even when they are not in this server.", 96)
local UsernameBox = Instance.new("TextBox")
UsernameBox.Name = "UsernameLookup"
UsernameBox.Size = UDim2.new(1, -244, 0, 31)
UsernameBox.Position = UDim2.fromOffset(48, 55)
UsernameBox.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
UsernameBox.BorderSizePixel = 0
UsernameBox.Text = ""
UsernameBox.PlaceholderText = "Type username (not display name)"
UsernameBox.PlaceholderColor3 = CONFIG.Muted
UsernameBox.TextColor3 = CONFIG.Text
UsernameBox.Font = Enum.Font.Gotham
UsernameBox.TextSize = 11
UsernameBox.ClearTextOnFocus = false
UsernameBox.Parent = usernameRow
addCorner(UsernameBox, 7)
addStroke(UsernameBox, Color3.fromRGB(112, 87, 48), 0.4, 1)

local profileByNameButton = makeButton(usernameRow, "PROFILE", UDim2.fromOffset(84, 31), UDim2.new(1, -190, 0, 55), CONFIG.AccentDark)
profileByNameButton.TextColor3 = CONFIG.AccentLight
local joinByNameButton = makeButton(usernameRow, "JOIN", UDim2.fromOffset(84, 31), UDim2.new(1, -96, 0, 55), CONFIG.Accent)
joinByNameButton.TextColor3 = Color3.fromRGB(25, 23, 18)

local function resolveUsername()
    local username = UsernameBox.Text:match("^%s*(.-)%s*$")
    if username == "" then
        notify("Enter a Roblox username first")
        return nil
    end

    local ok, userIdOrError = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    if not ok or type(userIdOrError) ~= "number" then
        notify("Username not found • check spelling")
        return nil
    end
    return userIdOrError
end

local function openProfileByUsername()
    task.spawn(function()
        notify("Looking up username...")
        local userId = resolveUsername()
        if not userId then return end
        local ok, err = pcall(function()
            GuiService:InspectPlayerFromUserId(userId)
        end)
        if ok then
            notify("Opened Roblox profile • UserId " .. tostring(userId))
        else
            notify("Could not open profile: " .. tostring(err))
        end
    end)
end

local function joinUsernameServer()
    task.spawn(function()
        notify("Finding the user's current server...")
        local userId = resolveUsername()
        if not userId then return end

        local lookupOk, userInExperience, lookupError, placeId, jobId = pcall(function()
            return TeleportService:GetPlayerPlaceInstanceAsync(userId)
        end)

        if not lookupOk then
            notify("Server lookup failed: " .. tostring(userInExperience))
            return
        end
        if not userInExperience or type(placeId) ~= "number" or type(jobId) ~= "string" or jobId == "" then
            notify(tostring(lookupError or "User is not in a joinable server of this experience"))
            return
        end

        local teleportOk, teleportError = pcall(function()
            -- Client-side TeleportToPlaceInstance defaults to LocalPlayer.
            TeleportService:TeleportToPlaceInstance(placeId, jobId)
        end)
        if not teleportOk then
            notify("Join failed: " .. tostring(teleportError))
        else
            notify("Joining " .. UsernameBox.Text .. "...")
        end
    end)
end

profileByNameButton.MouseButton1Click:Connect(openProfileByUsername)
joinByNameButton.MouseButton1Click:Connect(joinUsernameServer)

createSection(playersPage, "Current Server", "Search people already connected to this server")
local filterRow = createRow(playersPage, "Filter Server Players", "Filter by username or display name.", 83)
local ServerFilterBox = Instance.new("TextBox")
ServerFilterBox.Name = "ServerPlayerFilter"
ServerFilterBox.Size = UDim2.new(1, -62, 0, 30)
ServerFilterBox.Position = UDim2.fromOffset(48, 46)
ServerFilterBox.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
ServerFilterBox.BorderSizePixel = 0
ServerFilterBox.Text = ""
ServerFilterBox.PlaceholderText = "Search current server..."
ServerFilterBox.PlaceholderColor3 = CONFIG.Muted
ServerFilterBox.TextColor3 = CONFIG.Text
ServerFilterBox.Font = Enum.Font.Gotham
ServerFilterBox.TextSize = 11
ServerFilterBox.ClearTextOnFocus = false
ServerFilterBox.Parent = filterRow
addCorner(ServerFilterBox, 7)
addStroke(ServerFilterBox, Color3.fromRGB(80, 75, 61), 0.45, 1)

local playerList = Instance.new("Frame")
playerList.Size = UDim2.new(1, -8, 0, 0)
playerList.AutomaticSize = Enum.AutomaticSize.Y
playerList.BackgroundTransparency = 1
playerList.Parent = playersPage

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Padding = UDim.new(0, 7)
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Parent = playerList

local function refreshPlayerList()
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local filterText = string.lower(ServerFilterBox.Text or "")
    local count = 0
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= Player then
            local matches = filterText == ""
                or string.find(string.lower(target.Name), filterText, 1, true)
                or string.find(string.lower(target.DisplayName), filterText, 1, true)

            if matches then
                count += 1
                local row = Instance.new("Frame")
                row.Name = "Player_" .. target.UserId
                row.Size = UDim2.new(1, 0, 0, 62)
                row.BackgroundColor3 = Color3.new(1, 1, 1)
                row.BorderSizePixel = 0
                row.Parent = playerList
                addCorner(row, 10)
                addStroke(row, Color3.fromRGB(96, 76, 43), 0.1, 1)

                local avatar = Instance.new("ImageLabel")
                avatar.Size = UDim2.fromOffset(42, 42)
                avatar.Position = UDim2.fromOffset(10, 10)
                avatar.BackgroundColor3 = CONFIG.CardAlt
                avatar.BorderSizePixel = 0
                avatar.Image = ""
                avatar.Parent = row
                addCorner(avatar, 12)
                addStroke(avatar, Color3.fromRGB(138, 105, 54), 0.4, 1)
                task.spawn(function()
                    local ok, image = pcall(function()
                        return Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                    end)
                    if ok and avatar.Parent then
                        avatar.Image = image
                    end
                end)

                local display = makeText(row, target.DisplayName, 11, CONFIG.Text, Enum.Font.GothamMedium)
                display.Position = UDim2.fromOffset(62, 10)
                display.Size = UDim2.new(1, -245, 0, 19)

                local username = makeText(row, "@" .. target.Name .. "  •  ID " .. tostring(target.UserId), 9, CONFIG.Muted, Enum.Font.Gotham)
                username.Position = UDim2.fromOffset(62, 32)
                username.Size = UDim2.new(1, -245, 0, 16)

                local profileButton = makeButton(row, "PROFILE", UDim2.fromOffset(76, 30), UDim2.new(1, -166, 0.5, -15), CONFIG.AccentDark)
                profileButton.TextColor3 = CONFIG.AccentLight
                profileButton.MouseButton1Click:Connect(function()
                    local ok, err = pcall(function()
                        GuiService:InspectPlayerFromUserId(target.UserId)
                    end)
                    notify(ok and ("Opened " .. target.Name .. " profile") or ("Profile error: " .. tostring(err)))
                end)

                local tpButton = makeButton(row, "TELEPORT", UDim2.fromOffset(80, 30), UDim2.new(1, -82, 0.5, -15), CONFIG.Accent)
                tpButton.TextColor3 = Color3.fromRGB(25, 23, 18)
                tpButton.MouseButton1Click:Connect(function()
                    local targetRoot = getRoot(target.Character)
                    local root = getRoot()
                    if targetRoot and root then
                        root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 4)
                        notify("Moved beside " .. target.DisplayName)
                    else
                        notify("Player character not ready")
                    end
                end)
            end
        end
    end

    if count == 0 then
        local empty = createRow(playerList, "No matching players", "Try another name or wait for players to join this server.", 62)
        empty.LayoutOrder = 1
    end
end

ServerFilterBox:GetPropertyChangedSignal("Text"):Connect(refreshPlayerList)
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
Players.PlayerAdded:Connect(function()
    if dashboardSessionCard and dashboardSessionCard.Parent then
        local label = dashboardSessionCard:FindFirstChild("RowDescription")
        if label then label.Text = "Place ID: " .. tostring(game.PlaceId) .. " • Server players: " .. tostring(#Players:GetPlayers()) end
    end
end)
Players.PlayerRemoving:Connect(function()
    if dashboardSessionCard and dashboardSessionCard.Parent then
        local label = dashboardSessionCard:FindFirstChild("RowDescription")
        if label then label.Text = "Place ID: " .. tostring(game.PlaceId) .. " • Server players: " .. tostring(#Players:GetPlayers()) end
    end
end)
refreshPlayerList()

playerActions.openProfileByUsername = openProfileByUsername
playerActions.joinUsernameServer = joinUsernameServer

end

local utilityActions = {}
do
--// UTILITIES PAGE
createSection(utilitiesPage, "Position Tools", "Save a safe spot and return to it whenever you need")
createActionRow(utilitiesPage, "Save Position", "Remember your current character position for this session.", "SAVE SPOT", function()
    local root = getRoot()
    if not root then
        notify("Character not ready")
        return
    end
    savedPositionCFrame = root.CFrame
    notify("Position saved for this session")
end, CONFIG.Accent)
createActionRow(utilitiesPage, "Return to Saved Position", "Teleport back to the last position you saved.", "RETURN", function()
    local root = getRoot()
    if not root then
        notify("Character not ready")
        return
    end
    if not savedPositionCFrame then
        notify("No saved position yet • use Save Position first")
        return
    end
    root.CFrame = savedPositionCFrame
    notify("Returned to saved position")
end, CONFIG.Accent)

createSection(visualsPage, "Visuals", "Local camera and lighting preferences")
local fullbrightToggleSetter
local function setFullbright(enabled)
    fullbrightEnabled = enabled == true
    if fullbrightEnabled then
        if not savedLightingState then
            savedLightingState = {
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                GlobalShadows = Lighting.GlobalShadows,
                ExposureCompensation = Lighting.ExposureCompensation,
            }
        end
        Lighting.Ambient = Color3.fromRGB(205, 205, 205)
        Lighting.OutdoorAmbient = Color3.fromRGB(205, 205, 205)
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.ExposureCompensation = 0.15
        notify("Fullbright ON")
    else
        if savedLightingState then
            for property, value in pairs(savedLightingState) do
                pcall(function() Lighting[property] = value end)
            end
        end
        savedLightingState = nil
        notify("Fullbright OFF • original lighting restored")
    end
end
local _, setFullbrightToggle = createToggleRow(
    visualsPage,
    "Fullbright",
    "Brighten your local view. Original Lighting values are restored when disabled.",
    false,
    setFullbright
)
fullbrightToggleSetter = setFullbrightToggle

local cameraFOVDefault = (workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView) or 70
local _, _, setCameraFOV = createSliderRow(visualsPage, "Camera Field of View", "Adjust the local camera view from 50° to 120°.", 50, 120, math.clamp(math.floor(cameraFOVDefault), 50, 120), function(value)
    Camera = workspace.CurrentCamera or Camera
    if Camera then
        Camera.FieldOfView = value
    end
end)
createActionRow(visualsPage, "Reset Camera FOV", "Restore the standard 70° camera field of view.", "RESET FOV", function()
    Camera = workspace.CurrentCamera or Camera
    if Camera then
        Camera.FieldOfView = 70
        setCameraFOV(70)
        notify("Camera FOV reset to 70°")
    else
        notify("Camera not ready")
    end
end)

createSection(sessionPage, "Session", "Reconnect or inspect your Roblox profile")
local function rejoinCurrentServer()
    if game.JobId == "" then
        notify("Rejoin is unavailable in Studio test sessions")
        return
    end
    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end)
    if not ok then
        notify("Rejoin failed: " .. tostring(err))
    else
        notify("Rejoining current server...")
    end
end
createActionRow(sessionPage, "Rejoin Current Server", "Reconnect to this exact public server instance when supported.", "REJOIN", rejoinCurrentServer, CONFIG.Accent)
createActionRow(sessionPage, "My Roblox Profile", "Open your own Roblox avatar and profile inspection card.", "OPEN", function()
    local ok, err = pcall(function()
        GuiService:InspectPlayerFromUserId(Player.UserId)
    end)
    notify(ok and "Opened your Roblox profile" or ("Profile error: " .. tostring(err)))
end)
createActionRow(sessionPage, "Copy Place ID", "Place ID is useful when reporting issues or sharing the experience.", "COPY ID", function()
    local placeId = tostring(game.PlaceId)
    local copied = false
    if typeof(setclipboard) == "function" then
        copied = pcall(setclipboard, placeId)
    end
    notify(copied and ("Place ID copied: " .. placeId) or ("Place ID: " .. placeId))
end)
createRow(sessionPage, "Join by Username note", "The Join button looks up a Roblox username and attempts to join their current server in this same experience. Privacy, a full server, or unavailable server data can prevent joining.", 78)

utilityActions.toggleFullbright = function()
    setFullbright(not fullbrightEnabled)
    if fullbrightToggleSetter then fullbrightToggleSetter(fullbrightEnabled) end
end
utilityActions.rejoinCurrentServer = rejoinCurrentServer

end

do
local OpenButton
--// SETTINGS PAGE
createSection(settingsPage, "Interface", "Control how the panel opens and closes")
createActionRow(settingsPage, "Hide Panel", "Hide the window. Use your chosen Show / Hide Panel keybind to show it again.", "HIDE", function()
    Main.Visible = false
    OpenButton.Visible = true
    notify("Panel hidden")
end)
createActionRow(settingsPage, "Reset Movement", "Restore default speed, jump and gravity values.", "RESET", function()
    walkSpeedSetter(5000)
    flySpeedSetter(5000)
    jumpPowerSetter(50)
    gravitySetter(originalGravity)
    notify("Movement settings restored")
end)
createActionRow(settingsPage, "Disable Active Tools", "Turn off protection, movement, teleport and AFK controls.", "DISABLE ALL", function()
    if godToggleSetter then godToggleSetter(false) end
    setGodMode(false)
    if autoHealToggleSetter then autoHealToggleSetter(false) end
    setAutoHeal(false)
    if flyToggleSetter then flyToggleSetter(false) end
    setFly(false)
    if noclipToggleSetter then noclipToggleSetter(false) end
    setNoclip(false)
    tapTeleportEnabled = false
    if tapToggleSetter then tapToggleSetter(false) end
    setAfkFarm(false)
    if afkFarmToggleSetter then afkFarmToggleSetter(false) end
    stopAfkRunning()
    setTreadmillBoost(false)
    if treadmillBoostToggleSetter then treadmillBoostToggleSetter(false) end
    setAntiAfkMonitor(false)
    if antiAfkToggleSetter then antiAfkToggleSetter(false) end
    notify("All tools disabled")
end, CONFIG.Red)

--// CUSTOM KEYBINDS
-- Every toggle/action below can be assigned to a key chosen by the player.
local keybinds = {}
local keybindCallbacks = {}
local keybindButtons = {}
local waitingForBind = nil

local function registerKeybind(actionName, defaultKey, description, callback)
    keybinds[actionName] = defaultKey
    keybindCallbacks[actionName] = callback

    local row = createRow(settingsPage, actionName, description, 62)
    local bindButton = makeButton(
        row,
        defaultKey and defaultKey.Name or "UNBOUND",
        UDim2.fromOffset(116, 30),
        UDim2.new(1, -130, 0.5, -15),
        CONFIG.AccentDark
    )
    bindButton.TextColor3 = CONFIG.AccentLight
    bindButton.MouseButton1Click:Connect(function()
        waitingForBind = actionName
        bindButton.Text = "PRESS A KEY"
        notify("Choose a key for " .. actionName .. " • Esc cancels • Backspace clears")
    end)
    keybindButtons[actionName] = bindButton
end

createSection(settingsPage, "Keyboard Shortcuts", "Click a key label, then press the key you want to assign")
registerKeybind("God Mode", Enum.KeyCode.F1, "Toggle the existing local God Mode behavior.", function()
    setGodMode(not godModeEnabled)
    if godToggleSetter then godToggleSetter(godModeEnabled) end
end)
registerKeybind("Auto Heal", Enum.KeyCode.F2, "Toggle automatic health recovery.", function()
    setAutoHeal(not autoHealEnabled)
    if autoHealToggleSetter then autoHealToggleSetter(autoHealEnabled) end
end)
registerKeybind("Fly", Enum.KeyCode.F3, "Toggle Fly movement.", function()
    setFly(not flyEnabled)
    if flyToggleSetter then flyToggleSetter(flyEnabled) end
end)
registerKeybind("Noclip", Enum.KeyCode.F4, "Toggle Noclip collision mode.", function()
    setNoclip(not noclipEnabled)
    if noclipToggleSetter then noclipToggleSetter(noclipEnabled) end
end)
registerKeybind("Tap TP", Enum.KeyCode.F5, "Toggle click-to-teleport.", function()
    tapTeleportEnabled = not tapTeleportEnabled
    if tapToggleSetter then tapToggleSetter(tapTeleportEnabled) end
    notify(tapTeleportEnabled and "Tap TP enabled" or "Tap TP disabled")
end)
registerKeybind("AFK Farm", Enum.KeyCode.F6, "Toggle AFK Farm and teleport to the saved spot.", function()
    setAfkFarm(not afkFarmEnabled)
    if afkFarmToggleSetter then afkFarmToggleSetter(afkFarmEnabled) end
end)
registerKeybind("Treadmill Auto Run", Enum.KeyCode.KeypadMultiply, "Toggle continuous treadmill movement.", function()
    setAfkAutoRun(not afkAutoRunEnabled)
    if afkAutoRunToggleSetter then afkAutoRunToggleSetter(afkAutoRunEnabled) end
end)
registerKeybind("Treadmill Boost", Enum.KeyCode.B, "Toggle the local treadmill movement speed override.", function()
    setTreadmillBoost(not treadmillBoostEnabled)
    if treadmillBoostToggleSetter then treadmillBoostToggleSetter(treadmillBoostEnabled) end
end)
registerKeybind("Cycle Run Direction", Enum.KeyCode.Insert, "Switch Forward, Backward, Left and Right treadmill movement.", cycleAfkRunDirection)
registerKeybind("Anti-AFK Monitor", Enum.KeyCode.F7, "Toggle the Roblox idle-event monitor.", function()
    setAntiAfkMonitor(not antiAfkMonitorEnabled)
    if antiAfkToggleSetter then antiAfkToggleSetter(antiAfkMonitorEnabled) end
end)
registerKeybind("Return After Respawn", Enum.KeyCode.F8, "Toggle automatic return to the farm after respawn.", function()
    returnToFarmAfterRespawn = not returnToFarmAfterRespawn
    if returnFarmToggleSetter then returnFarmToggleSetter(returnToFarmAfterRespawn) end
    notify(returnToFarmAfterRespawn and "Return after respawn ON" or "Return after respawn OFF")
end)
registerKeybind("Teleport to Farm", Enum.KeyCode.F9, "Teleport to the saved AFK farm coordinates.", teleportToFarmSpot)
registerKeybind("Copy Coordinates", Enum.KeyCode.F10, "Copy your current coordinates into the coordinate field.", function()
    local coords = getCoordinates()
    if not coords then notify("Character not ready") return end
    CoordBox.Text = coords
    notify("Coordinates placed in the field • Ctrl+C to copy")
end)
registerKeybind("Teleport to Coordinates", Enum.KeyCode.F11, "Teleport using the coordinates in the Teleport page.", function()
    local position = parseCoordinates(CoordBox.Text)
    local root = getRoot()
    if not position then notify("Invalid coordinates • use X, Y, Z") return end
    if not root then notify("Character not ready") return end
    root.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
    notify("Teleported to coordinates")
end)
registerKeybind("Reset Character", Enum.KeyCode.F12, "Reset your character.", function()
    local humanoid = getHumanoid()
    if humanoid then humanoid.Health = 0 notify("Character reset") else notify("Character not ready") end
end)
registerKeybind("Reset Movement", Enum.KeyCode.Home, "Restore movement values to the script defaults.", function()
    walkSpeedSetter(5000)
    flySpeedSetter(5000)
    jumpPowerSetter(50)
    gravitySetter(originalGravity)
    notify("Movement settings restored")
end)
registerKeybind("Disable All Tools", Enum.KeyCode.End, "Turn off all active toggles.", function()
    if godToggleSetter then godToggleSetter(false) end
    setGodMode(false)
    if autoHealToggleSetter then autoHealToggleSetter(false) end
    setAutoHeal(false)
    if flyToggleSetter then flyToggleSetter(false) end
    setFly(false)
    if noclipToggleSetter then noclipToggleSetter(false) end
    setNoclip(false)
    tapTeleportEnabled = false
    if tapToggleSetter then tapToggleSetter(false) end
    setAfkFarm(false)
    if afkFarmToggleSetter then afkFarmToggleSetter(false) end
    stopAfkRunning()
    setTreadmillBoost(false)
    if treadmillBoostToggleSetter then treadmillBoostToggleSetter(false) end
    setAntiAfkMonitor(false)
    if antiAfkToggleSetter then antiAfkToggleSetter(false) end
    notify("All tools disabled")
end)
registerKeybind("Walk Speed +", Enum.KeyCode.Equals, "Increase Walk Speed by 250.", function()
    walkSpeedSetter(math.min(walkSpeed + 250, 5000))
end)
registerKeybind("Walk Speed -", Enum.KeyCode.Minus, "Decrease Walk Speed by 250.", function()
    walkSpeedSetter(math.max(walkSpeed - 250, 16))
end)
registerKeybind("Jump Power +", Enum.KeyCode.RightBracket, "Increase Jump Power by 10.", function()
    jumpPowerSetter(math.min(jumpPower + 10, 250))
end)
registerKeybind("Jump Power -", Enum.KeyCode.LeftBracket, "Decrease Jump Power by 10.", function()
    jumpPowerSetter(math.max(jumpPower - 10, 50))
end)
registerKeybind("Fly Speed +", Enum.KeyCode.Period, "Increase Fly Speed by 250.", function()
    flySpeedSetter(math.min(flySpeed + 250, 5000))
end)
registerKeybind("Fly Speed -", Enum.KeyCode.Comma, "Decrease Fly Speed by 250.", function()
    flySpeedSetter(math.max(flySpeed - 250, 20))
end)
registerKeybind("Gravity +", Enum.KeyCode.PageUp, "Increase gravity by 10.", function()
    gravitySetter(math.min(selectedGravity + 10, 196))
end)
registerKeybind("Gravity -", Enum.KeyCode.PageDown, "Decrease gravity by 10.", function()
    gravitySetter(math.max(selectedGravity - 10, 0))
end)
registerKeybind("Save Position", Enum.KeyCode.K, "Save your current position for this session.", function()
    local root = getRoot()
    if root then savedPositionCFrame = root.CFrame notify("Position saved") else notify("Character not ready") end
end)
registerKeybind("Return to Saved Position", Enum.KeyCode.L, "Return to your saved position.", function()
    local root = getRoot()
    if root and savedPositionCFrame then root.CFrame = savedPositionCFrame notify("Returned to saved position") else notify("No saved position") end
end)
registerKeybind("Open Players Page", Enum.KeyCode.P, "Open the player finder and server player list.", function()
    selectPage("Players")
end)
registerKeybind("Open Utilities Page", Enum.KeyCode.U, "Open the utilities page.", function()
    selectPage("Utilities")
end)
registerKeybind("Open AFK Farm Page", Enum.KeyCode.G, "Open the AFK Farm controls.", function()
    selectPage("AFK Farm")
end)
registerKeybind("Fullbright", Enum.KeyCode.V, "Toggle local Fullbright lighting.", utilityActions.toggleFullbright)
registerKeybind("Join Typed Username", Enum.KeyCode.J, "Attempt to join the typed username's server in this experience.", playerActions.joinUsernameServer)
registerKeybind("Open Typed Profile", Enum.KeyCode.O, "Open the Roblox profile for the typed username.", playerActions.openProfileByUsername)
registerKeybind("Rejoin Current Server", Enum.KeyCode.R, "Reconnect to the current server instance.", utilityActions.rejoinCurrentServer)
registerKeybind("Show / Hide Panel", Enum.KeyCode.RightControl, "Show or hide the Zoni_YT panel.", function()
    Main.Visible = not Main.Visible
    OpenButton.Visible = not Main.Visible
end)

local function handleKeybindInput(input)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    if waitingForBind then
        local actionName = waitingForBind
        waitingForBind = nil
        local button = keybindButtons[actionName]

        if input.KeyCode == Enum.KeyCode.Escape then
            if button then button.Text = keybinds[actionName] and keybinds[actionName].Name or "UNBOUND" end
            notify("Keybind unchanged")
            return
        end

        if input.KeyCode == Enum.KeyCode.Backspace then
            keybinds[actionName] = nil
            if button then button.Text = "UNBOUND" end
            notify(actionName .. " keybind cleared")
            return
        end

        for otherName, otherKey in pairs(keybinds) do
            if otherName ~= actionName and otherKey == input.KeyCode then
                notify(input.KeyCode.Name .. " is already used by " .. otherName)
                if button then button.Text = keybinds[actionName] and keybinds[actionName].Name or "UNBOUND" end
                return
            end
        end

        keybinds[actionName] = input.KeyCode
        if button then button.Text = input.KeyCode.Name end
        notify(actionName .. " bound to " .. input.KeyCode.Name)
        return
    end

    if UserInputService:GetFocusedTextBox() then return end
    for actionName, boundKey in pairs(keybinds) do
        if boundKey and boundKey == input.KeyCode then
            local callback = keybindCallbacks[actionName]
            if callback then callback() end
            return
        end
    end
end

--// OPEN / CLOSE BUTTON
OpenButton = makeButton(
    ScreenGui,
    "ZONI  •  OPEN",
    UDim2.fromOffset(128, 36),
    UDim2.new(0, 18, 1, -54),
    CONFIG.Accent
)
OpenButton.Name = "OpenButton"
OpenButton.TextColor3 = Color3.fromRGB(25, 23, 18)
OpenButton.Visible = false
addStroke(OpenButton, Color3.fromRGB(168, 227, 197), 0.18, 1)
addGradient(OpenButton, CONFIG.AccentLight, CONFIG.Accent, 90)

-- Compact header controls: live status + close/minimize button.
local ReadyChip = Instance.new("Frame")
ReadyChip.Size = UDim2.fromOffset(78, 25)
ReadyChip.Position = UDim2.new(1, -116, 0, 6)
ReadyChip.BackgroundColor3 = Color3.fromRGB(26, 43, 34)
ReadyChip.BorderSizePixel = 0
ReadyChip.Parent = Header
addCorner(ReadyChip, 7)
addStroke(ReadyChip, Color3.fromRGB(67, 121, 86), 0.55, 1)

local ReadyDot = Instance.new("Frame")
ReadyDot.Size = UDim2.fromOffset(6, 6)
ReadyDot.Position = UDim2.fromOffset(9, 9)
ReadyDot.BackgroundColor3 = CONFIG.Green
ReadyDot.BorderSizePixel = 0
ReadyDot.Parent = ReadyChip
addCorner(ReadyDot, 4)

local ReadyText = makeText(ReadyChip, "READY", 8, Color3.fromRGB(159, 221, 178), Enum.Font.GothamBold)
ReadyText.Position = UDim2.fromOffset(21, 0)
ReadyText.Size = UDim2.new(1, -25, 1, 0)

local HeaderHide = makeButton(Header, "×", UDim2.fromOffset(27, 27), UDim2.new(1, -27, 0, 5), Color3.fromRGB(57, 31, 30))
HeaderHide.TextSize = 19
HeaderHide.TextColor3 = Color3.fromRGB(244, 145, 137)
HeaderHide.MouseButton1Click:Connect(function()
    Main.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    Main.Visible = true
    OpenButton.Visible = false
end)
OpenButton.MouseEnter:Connect(function()
    tween(OpenButton, {BackgroundColor3 = CONFIG.AccentLight}, 0.12)
end)
OpenButton.MouseLeave:Connect(function()
    tween(OpenButton, {BackgroundColor3 = CONFIG.Accent}, 0.12)
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if waitingForBind then
        handleKeybindInput(input)
        return
    end
    if processed then return end
    handleKeybindInput(input)
end)
end

--// CHARACTER RESPAWN HANDLING
Player.CharacterAdded:Connect(function(character)
    -- Stop the previous character's movement loop; it is restarted below only
    -- when Return After Respawn is enabled and AFK Farm is still active.
    stopAfkRunning()

    if flyEnabled then
        stopFly()
        if flyToggleSetter then flyToggleSetter(false) end
    end

    if noclipEnabled then
        setNoclip(false)
        if noclipToggleSetter then noclipToggleSetter(false) end
    end

    task.wait(0.25)
    applyMovementSettings()

    if godModeEnabled then
        applyLocalGodMode(character)
    end
    if autoHealEnabled then
        startAutoHeal(character)
    end
    if afkFarmEnabled and returnToFarmAfterRespawn then
        task.wait(0.25)
        if teleportToFarmSpot() then
            applyMovementSettings()
            if afkAutoRunEnabled then
                task.wait(0.2)
                startAfkRunning()
            end
        end
        if afkFarmToggleSetter then afkFarmToggleSetter(true) end
    end
end)

-- Apply requested speed defaults if the character already exists when this LocalScript starts.
if getCharacter() then
    task.defer(applyMovementSettings)
end

--// DEFAULT PAGE
selectPage("Home")
notify("Zoni_YT loaded successfully")
